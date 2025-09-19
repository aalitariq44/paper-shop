import 'package:flutter/material.dart';
import 'package:paper_shop/data/repositories/user_repository.dart';
import 'package:paper_shop/data/models/user_model.dart';

/// مزود حالة المستخدم
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository.instance;

  // الحالة الداخلية
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // الحصول على القيم
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تحميل بيانات المستخدم الحالي
  Future<void> loadCurrentUser() async {
    try {
      _setLoading(true);
      _clearError();

      _user = await _userRepository.getCurrentUser();
    } catch (e) {
      _setError('حدث خطأ في تحميل بيانات المستخدم: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUser({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedUser = await _userRepository.updateCurrentUser(
        displayName: displayName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
      );

      if (updatedUser != null) {
        _user = updatedUser;
        _setLoading(false);
        return true;
      } else {
        _setError('فشل في تحديث بيانات المستخدم');
        return false;
      }
    } catch (e) {
      _setError('حدث خطأ في تحديث بيانات المستخدم: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// التحقق من اكتمال الملف الشخصي
  Future<bool> checkProfileCompletion() async {
    try {
      return await _userRepository.isProfileComplete();
    } catch (e) {
      print('❌ Error checking profile completion: $e');
      return false;
    }
  }

  /// إعادة تحميل بيانات المستخدم
  Future<void> refresh() async {
    await loadCurrentUser();
  }

  /// تحديث المستخدم محلياً (بدون API call)
  void updateLocalUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// مسح بيانات المستخدم
  void clearUser() {
    _user = null;
    _clearError();
    notifyListeners();
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

}
