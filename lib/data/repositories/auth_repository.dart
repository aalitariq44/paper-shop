import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paper_shop/core/services/auth_service.dart';
import 'package:paper_shop/data/models/user_model.dart';

/// مستودع المصادقة والمستخدمين
class AuthRepository {
  static AuthRepository? _instance;

  AuthRepository._();

  static AuthRepository get instance {
    _instance ??= AuthRepository._();
    return _instance!;
  }

  final AuthService _authService = AuthService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== عمليات المصادقة ==========

  /// المستخدم الحالي
  User? get currentUser => _authService.currentUser;

  /// stream حالة المصادقة
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// التحقق من حالة تسجيل الدخول
  bool get isSignedIn => _authService.isSignedIn;

  /// تسجيل الدخول باستخدام Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      final userModel = await _authService.signInWithGoogle();

      if (userModel != null) {
        return AuthResult.success(userModel);
      } else {
        return AuthResult.failure('تم إلغاء تسجيل الدخول');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      print('❌ Error in signInWithGoogle: $e');
      return AuthResult.failure('حدث خطأ في تسجيل الدخول');
    }
  }

  /// تسجيل الخروج
  Future<bool> signOut() async {
    try {
      await _authService.signOut();
      return true;
    } catch (e) {
      print('❌ Error in signOut: $e');
      return false;
    }
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUserData() async {
    return await _authService.getCurrentUserData();
  }

  /// stream لبيانات المستخدم الحالي
  Stream<UserModel?> get currentUserDataStream =>
      _authService.currentUserDataStream;

  // ========== عمليات المستخدمين ==========

  /// تحديث الملف الشخصي
  Future<UserUpdateResult> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      if (!isSignedIn) {
        return UserUpdateResult.failure('يجب تسجيل الدخول أولاً');
      }

      final updatedUser = await _authService.updateUserProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
      );

      if (updatedUser != null) {
        return UserUpdateResult.success(updatedUser);
      } else {
        return UserUpdateResult.failure('فشل في تحديث الملف الشخصي');
      }
    } catch (e) {
      print('❌ Error in updateUserProfile: $e');
      return UserUpdateResult.failure('حدث خطأ في تحديث الملف الشخصي');
    }
  }

  /// التحقق من اكتمال الملف الشخصي
  Future<bool> isProfileComplete() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.hasCompleteProfile ?? false;
    } catch (e) {
      print('❌ Error checking profile completion: $e');
      return false;
    }
  }

  /// الحصول على بيانات مستخدم معين (للإدارة)
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  /// البحث عن المستخدمين (للإدارة)
  Future<List<UserModel>> searchUsers(String searchTerm, {int? limit}) async {
    try {
      Query query = _firestore.collection('users');

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      // فلترة النتائج محلياً
      final users = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) {
            final searchLower = searchTerm.toLowerCase();
            return user.email.toLowerCase().contains(searchLower) ||
                (user.displayName?.toLowerCase().contains(searchLower) ??
                    false) ||
                (user.phoneNumber?.contains(searchTerm) ?? false);
          })
          .toList();

      return users;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// الحصول على إحصائيات المستخدمين (للإدارة)
  Future<Map<String, int>> getUsersStats() async {
    try {
      final allUsersSnapshot = await _firestore.collection('users').get();

      final completeProfilesSnapshot = await _firestore
          .collection('users')
          .where('isProfileComplete', isEqualTo: true)
          .get();

      final incompleteProfilesSnapshot = await _firestore
          .collection('users')
          .where('isProfileComplete', isEqualTo: false)
          .get();

      return {
        'total': allUsersSnapshot.docs.length,
        'completeProfiles': completeProfilesSnapshot.docs.length,
        'incompleteProfiles': incompleteProfilesSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting users stats: $e');
      return {'total': 0, 'completeProfiles': 0, 'incompleteProfiles': 0};
    }
  }

  /// حذف الحساب
  Future<bool> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      return true;
    } catch (e) {
      print('❌ Error deleting account: $e');
      return false;
    }
  }

  /// تحديث رمز FCM للإشعارات
  Future<void> updateFCMToken(String fcmToken) async {
    await _authService.updateFCMToken(fcmToken);
  }

  /// التحقق من صحة حالة المصادقة
  Future<bool> validateAuthState() async {
    return await _authService.validateAuthState();
  }

  /// إعادة تحميل بيانات المستخدم
  Future<UserModel?> reloadUser() async {
    try {
      if (!isSignedIn) return null;

      // إعادة تحميل المستخدم من Firebase Auth
      await currentUser!.reload();

      // الحصول على البيانات المحدثة من Firestore
      return await getCurrentUserData();
    } catch (e) {
      print('❌ Error reloading user: $e');
      return null;
    }
  }

  // ========== وظائف مساعدة ==========

  /// ترجمة رسائل الخطأ
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بهذا البريد الإلكتروني بطريقة تسجيل دخول مختلفة';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      case 'operation-not-allowed':
        return 'عملية تسجيل الدخول غير مسموحة';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم من قبل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'network-request-failed':
        return 'فشل في الاتصال بالشبكة';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموحة، حاول لاحقاً';
      default:
        return e.message ?? 'حدث خطأ في المصادقة';
    }
  }
}

// ========== نتائج العمليات ==========

/// نتيجة عملية المصادقة
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;

  AuthResult._(this.isSuccess, this.errorMessage, this.user);

  factory AuthResult.success(UserModel user) {
    return AuthResult._(true, null, user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(false, errorMessage, null);
  }
}

/// نتيجة عملية تحديث المستخدم
class UserUpdateResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;

  UserUpdateResult._(this.isSuccess, this.errorMessage, this.user);

  factory UserUpdateResult.success(UserModel user) {
    return UserUpdateResult._(true, null, user);
  }

  factory UserUpdateResult.failure(String errorMessage) {
    return UserUpdateResult._(false, errorMessage, null);
  }
}
