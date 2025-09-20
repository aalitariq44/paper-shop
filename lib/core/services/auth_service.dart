import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paper_shop/data/models/user_model.dart';

/// خدمة المصادقة باستخدام Firebase Auth
class AuthService {
  static AuthService? _instance;

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// stream للمستخدم الحالي
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// التحقق من حالة تسجيل الدخول
  bool get isSignedIn => currentUser != null;

  /// تسجيل الدخول باستخدام Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // إعداد Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // المستخدم ألغى تسجيل الدخول
        return null;
      }

      // الحصول على معلومات المصادقة
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // إنشاء credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // تسجيل الدخول في Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // إنشاء أو تحديث بيانات المستخدم في Firestore
        final userModel = await _createOrUpdateUser(user);
        print('✅ User signed in successfully: ${user.email}');
        return userModel;
      }

      return null;
    } catch (e) {
      print('❌ Error signing in with Google: $e');
      rethrow;
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        // إنشاء أو تحديث بيانات المستخدم في Firestore
        final userModel = await _createOrUpdateUser(user);
        print('✅ User signed in with email successfully: ${user.email}');
        return userModel;
      }

      return null;
    } catch (e) {
      print('❌ Error signing in with email: $e');
      rethrow;
    }
  }

  /// إنشاء حساب جديد بالبريد الإلكتروني وكلمة المرور
  Future<UserModel?> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        // تحديث اسم المستخدم إذا تم توفيره
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
          await user.reload();
        }

        // إنشاء بيانات المستخدم في Firestore
        final userModel = await _createOrUpdateUser(user);
        print('✅ User signed up with email successfully: ${user.email}');
        return userModel;
      }

      return null;
    } catch (e) {
      print('❌ Error signing up with email: $e');
      rethrow;
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully');
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      rethrow;
    }
  }

  /// إنشاء أو تحديث بيانات المستخدم في Firestore
  Future<UserModel> _createOrUpdateUser(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final now = DateTime.now();

      // قراءة البيانات الحالية للتحقق من وجود المستخدم
      final existingDoc = await userDoc.get();
      final isNewUser = !existingDoc.exists;

      // كتابة بدون قراءة مسبقة (upsert)
      final data = <String, dynamic>{
        'email': user.email ?? '',
        'displayName': user.displayName,
        'name':
            (user.displayName ?? (user.email?.split('@').first ?? user.uid)),
        'profileImageUrl': user.photoURL,
        'updatedAt': Timestamp.fromDate(now),
      };

      // إضافة createdAt فقط إذا كان المستخدم جديد
      if (isNewUser) {
        data['createdAt'] = Timestamp.fromDate(now);
      }

      await userDoc.set(data, SetOptions(merge: true));

      // قراءة البيانات المحدثة لإنشاء UserModel صحيح
      final updatedDoc = await userDoc.get();
      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      print('❌ Error creating/updating user: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      // تسجيل خروج من Google
      await _googleSignIn.signOut();

      // تسجيل خروج من Firebase
      await _auth.signOut();

      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// الحصول على بيانات المستخدم الحالي من Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (!isSignedIn) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }

      return null;
    } catch (e) {
      print('❌ Error getting current user data: $e');
      return null;
    }
  }

  /// تحديث بيانات المستخدم
  Future<UserModel?> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      if (!isSignedIn) return null;

      final uid = currentUser!.uid;
      final userDoc = _firestore.collection('users').doc(uid);

      // حاول تحديث عرض الاسم في Firebase Auth أيضًا ليبقى متزامنًا
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await currentUser!.updateDisplayName(displayName);
          await currentUser!.reload();
        } catch (_) {
          // تجاهل أخطاء تحديث عرض الاسم في Auth ولا تمنع استمرار التحديث في Firestore
        }
      }

      // قراءة البيانات الحالية لضمان اكتمال البيانات المطلوبة من قواعد الأمان
      final existingSnap = await userDoc.get();
      final existing = existingSnap.data() ?? <String, dynamic>{};

      // تجهيز البيانات المحدثة مع الحفاظ على الحقول المطلوبة من القواعد (email, name)
      final now = DateTime.now();
      final merged = <String, dynamic>{
        ...existing,
        'email': (existing['email'] as String?) ?? (currentUser!.email ?? ''),
        if ((displayName ?? '').isNotEmpty) ...{
          'displayName': displayName,
          'name': displayName, // keep name in sync for rules
        },
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': Timestamp.fromDate(now),
      };

      // حساب اكتمال الملف الشخصي بعد الدمج
      final mergedDisplayName = (merged['displayName'] as String?) ?? '';
      final mergedPhone = (merged['phoneNumber'] as String?) ?? '';
      final mergedAddress = (merged['address'] as String?) ?? '';
      final isComplete =
          mergedDisplayName.trim().isNotEmpty &&
          mergedPhone.trim().isNotEmpty &&
          mergedAddress.trim().isNotEmpty;
      merged['isProfileComplete'] = isComplete;

      // كتابة مدمجة للحفاظ على الحقول الأخرى (مثل fcmToken)
      await userDoc.set(merged, SetOptions(merge: true));

      // إعادة بناء نموذج المستخدم من البيانات المدمجة (دون حاجة لقراءة ثانية)
      final userModel = UserModel.fromMap(merged, uid).copyWith(updatedAt: now);
      return userModel;
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// حذف الحساب (اختياري)
  Future<void> deleteAccount() async {
    try {
      if (!isSignedIn) return;

      final uid = currentUser!.uid;

      // حذف بيانات المستخدم من Firestore
      await _firestore.collection('users').doc(uid).delete();

      // حذف الحساب من Firebase Auth
      await currentUser!.delete();

      // تسجيل خروج من Google
      await _googleSignIn.signOut();

      print('✅ Account deleted successfully');
    } catch (e) {
      print('❌ Error deleting account: $e');
      rethrow;
    }
  }

  /// stream لبيانات المستخدم الحالي
  Stream<UserModel?> get currentUserDataStream {
    if (!isSignedIn) return Stream.value(null);

    return _firestore.collection('users').doc(currentUser!.uid).snapshots().map(
      (doc) {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
        return null;
      },
    );
  }

  /// التحقق من صحة حالة المصادقة
  Future<bool> validateAuthState() async {
    try {
      if (!isSignedIn) return false;

      // التحقق من صحة الرمز المميز
      final idToken = await currentUser!.getIdToken(true);
      return idToken != null && idToken.isNotEmpty;
    } catch (e) {
      print('❌ Auth state validation failed: $e');
      return false;
    }
  }

  /// تحديث رمز FCM للإشعارات
  Future<void> updateFCMToken(String fcmToken) async {
    try {
      if (!isSignedIn) return;

      final uid = currentUser!.uid;
      final docRef = _firestore.collection('users').doc(uid);

      final String safeEmail = currentUser!.email ?? '';
      final String safeName =
          (currentUser!.displayName ??
          (safeEmail.isNotEmpty ? safeEmail.split('@').first : uid));

      // upsert بدون قراءة مسبقة
      await docRef.set({
        'fcmToken': fcmToken,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'email': safeEmail,
        'name': safeName,
      }, SetOptions(merge: true));

      print('✅ FCM token updated successfully');
    } catch (e) {
      print('❌ Error updating FCM token: $e');
    }
  }
}
