import 'package:flutter/material.dart';
import 'package:paper_shop/data/repositories/auth_repository.dart';
import 'package:paper_shop/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// مزود حالة المصادقة
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository.instance;

  // الحالة الداخلية
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authStateSubscription;
  bool _disposed = false;

  // الحصول على القيم
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initialize();
  }

  /// تهيئة المزود
  void _initialize() {
    _listenToAuthChanges();
  }

  /// الاستماع لتغييرات حالة المصادقة
  void _listenToAuthChanges() {
    _authStateSubscription = _authRepository.authStateChanges.listen((
      User? user,
    ) async {
      if (user != null) {
        await _loadUserData();
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  /// تحميل بيانات المستخدم
  Future<void> _loadUserData() async {
    try {
      _user = await _authRepository.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  /// تسجيل الدخول باستخدام Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authRepository.signInWithGoogle();

      if (result.isSuccess && result.user != null) {
        _user = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'فشل في تسجيل الدخول');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في تسجيل الدخول: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authRepository.signInWithEmail(email, password);

      if (result.isSuccess && result.user != null) {
        _user = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'فشل في تسجيل الدخول');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في تسجيل الدخول: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// إنشاء حساب جديد بالبريد الإلكتروني وكلمة المرور
  Future<bool> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authRepository.signUpWithEmail(email, password, displayName: displayName);

      if (result.isSuccess && result.user != null) {
        _user = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'فشل في إنشاء الحساب');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في إنشاء الحساب: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authRepository.sendPasswordResetEmail(email);

      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('فشل في إرسال رابط إعادة تعيين كلمة المرور');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في إرسال رابط إعادة تعيين كلمة المرور: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الخروج
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authRepository.signOut();

      if (success) {
        _user = null;
        _setLoading(false);
        return true;
      } else {
        _setError('فشل في تسجيل الخروج');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في تسجيل الخروج: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث الملف الشخصي
  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _authRepository.updateUserProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
      );

      if (result.isSuccess && result.user != null) {
        _user = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.errorMessage ?? 'فشل في تحديث الملف الشخصي');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في تحديث الملف الشخصي: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// التحقق من اكتمال الملف الشخصي
  bool get isProfileComplete {
    return _user?.hasCompleteProfile ?? false;
  }

  /// إعادة تحميل بيانات المستخدم
  Future<void> reloadUserData() async {
    await _loadUserData();
  }

  // وظائف مساعدة لإدارة الحالة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
