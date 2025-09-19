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

  /// إنشاء أو تحديث بيانات المستخدم في Firestore
  Future<UserModel> _createOrUpdateUser(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      final now = DateTime.now();

      if (docSnapshot.exists) {
        // المستخدم موجود - تحديث البيانات الأساسية فقط
        await userDoc.update({
          'email': user.email ?? '',
          'displayName': user.displayName,
          'profileImageUrl': user.photoURL,
          'updatedAt': Timestamp.fromDate(now),
        });

        // قراءة البيانات المحدثة
        final updatedDoc = await userDoc.get();
        return UserModel.fromFirestore(updatedDoc);
      } else {
        // مستخدم جديد - إنشاء ملف كامل
        final newUserModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          profileImageUrl: user.photoURL,
          createdAt: now,
          updatedAt: now,
          isProfileComplete: false,
        );

        await userDoc.set(newUserModel.toMap());
        return newUserModel;
      }
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

      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }

      // التحقق من اكتمال الملف الشخصي
      final currentDoc = await userDoc.get();
      if (currentDoc.exists) {
        final currentUser = UserModel.fromFirestore(currentDoc);
        final updatedUser = currentUser.copyWith(
          displayName: displayName,
          phoneNumber: phoneNumber,
          address: address,
          profileImageUrl: profileImageUrl,
        );

        updateData['isProfileComplete'] = updatedUser.hasCompleteProfile;
      }

      await userDoc.update(updateData);

      // إرجاع البيانات المحدثة
      return await getCurrentUserData();
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

      await _firestore.collection('users').doc(currentUser!.uid).update({
        'fcmToken': fcmToken,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ FCM token updated successfully');
    } catch (e) {
      print('❌ Error updating FCM token: $e');
    }
  }
}
