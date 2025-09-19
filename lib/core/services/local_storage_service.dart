import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paper_shop/data/models/cart_item_model.dart';

/// خدمة التخزين المحلي باستخدام SharedPreferences
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  /// تهيئة SharedPreferences
  Future<void> initialize() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      print('✅ Local storage initialized successfully');
    } catch (e) {
      print('❌ Error initializing local storage: $e');
      rethrow;
    }
  }

  /// التأكد من تهيئة SharedPreferences
  Future<SharedPreferences> get _prefs async {
    if (_preferences == null) {
      await initialize();
    }
    return _preferences!;
  }

  // ========== مفاتيح التخزين ==========
  static const String _keyCart = 'cart_data';
  static const String _keyUserPrefs = 'user_preferences';
  static const String _keySearchHistory = 'search_history';
  static const String _keyRecentlyViewed = 'recently_viewed_products';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';

  // ========== إدارة السلة ==========

  /// حفظ بيانات السلة
  Future<bool> saveCart(CartModel cart) async {
    try {
      final prefs = await _prefs;
      final cartJson = jsonEncode(cart.toMap());
      final result = await prefs.setString(_keyCart, cartJson);

      if (result) {
        print('✅ Cart saved successfully');
      }
      return result;
    } catch (e) {
      print('❌ Error saving cart: $e');
      return false;
    }
  }

  /// قراءة بيانات السلة
  Future<CartModel?> getCart() async {
    try {
      final prefs = await _prefs;
      final cartJson = prefs.getString(_keyCart);

      if (cartJson != null && cartJson.isNotEmpty) {
        final cartMap = jsonDecode(cartJson) as Map<String, dynamic>;
        return CartModel.fromMap(cartMap);
      }

      return null;
    } catch (e) {
      print('❌ Error getting cart: $e');
      return null;
    }
  }

  /// مسح بيانات السلة
  Future<bool> clearCart() async {
    try {
      final prefs = await _prefs;
      final result = await prefs.remove(_keyCart);

      if (result) {
        print('✅ Cart cleared successfully');
      }
      return result;
    } catch (e) {
      print('❌ Error clearing cart: $e');
      return false;
    }
  }

  // ========== تفضيلات المستخدم ==========

  /// حفظ تفضيلات المستخدم
  Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await _prefs;
      final prefsJson = jsonEncode(preferences);
      return await prefs.setString(_keyUserPrefs, prefsJson);
    } catch (e) {
      print('❌ Error saving user preferences: $e');
      return false;
    }
  }

  /// قراءة تفضيلات المستخدم
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final prefs = await _prefs;
      final prefsJson = prefs.getString(_keyUserPrefs);

      if (prefsJson != null && prefsJson.isNotEmpty) {
        return jsonDecode(prefsJson) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('❌ Error getting user preferences: $e');
      return null;
    }
  }

  // ========== سجل البحث ==========

  /// حفظ كلمة في سجل البحث
  Future<bool> addToSearchHistory(String query) async {
    try {
      if (query.trim().isEmpty) return false;

      final history = await getSearchHistory();

      // إزالة الكلمة إذا كانت موجودة (لتجنب التكرار)
      history.remove(query);

      // إضافة الكلمة في المقدمة
      history.insert(0, query);

      // الاحتفاظ بآخر 20 كلمة بحث فقط
      if (history.length > 20) {
        history.removeRange(20, history.length);
      }

      return await _saveSearchHistory(history);
    } catch (e) {
      print('❌ Error adding to search history: $e');
      return false;
    }
  }

  /// قراءة سجل البحث
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await _prefs;
      final historyJson = prefs.getString(_keySearchHistory);

      if (historyJson != null && historyJson.isNotEmpty) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        return historyList.cast<String>();
      }

      return [];
    } catch (e) {
      print('❌ Error getting search history: $e');
      return [];
    }
  }

  /// حفظ سجل البحث
  Future<bool> _saveSearchHistory(List<String> history) async {
    try {
      final prefs = await _prefs;
      final historyJson = jsonEncode(history);
      return await prefs.setString(_keySearchHistory, historyJson);
    } catch (e) {
      print('❌ Error saving search history: $e');
      return false;
    }
  }

  /// مسح سجل البحث
  Future<bool> clearSearchHistory() async {
    try {
      final prefs = await _prefs;
      return await prefs.remove(_keySearchHistory);
    } catch (e) {
      print('❌ Error clearing search history: $e');
      return false;
    }
  }

  // ========== المنتجات المعروضة مؤخراً ==========

  /// إضافة منتج للمعروضة مؤخراً
  Future<bool> addToRecentlyViewed(String productId) async {
    try {
      final recentlyViewed = await getRecentlyViewed();

      // إزالة المنتج إذا كان موجود (لتجنب التكرار)
      recentlyViewed.remove(productId);

      // إضافة المنتج في المقدمة
      recentlyViewed.insert(0, productId);

      // الاحتفاظ بآخر 10 منتجات فقط
      if (recentlyViewed.length > 10) {
        recentlyViewed.removeRange(10, recentlyViewed.length);
      }

      return await _saveRecentlyViewed(recentlyViewed);
    } catch (e) {
      print('❌ Error adding to recently viewed: $e');
      return false;
    }
  }

  /// قراءة المنتجات المعروضة مؤخراً
  Future<List<String>> getRecentlyViewed() async {
    try {
      final prefs = await _prefs;
      final recentlyViewedJson = prefs.getString(_keyRecentlyViewed);

      if (recentlyViewedJson != null && recentlyViewedJson.isNotEmpty) {
        final recentlyViewedList =
            jsonDecode(recentlyViewedJson) as List<dynamic>;
        return recentlyViewedList.cast<String>();
      }

      return [];
    } catch (e) {
      print('❌ Error getting recently viewed: $e');
      return [];
    }
  }

  /// حفظ المنتجات المعروضة مؤخراً
  Future<bool> _saveRecentlyViewed(List<String> recentlyViewed) async {
    try {
      final prefs = await _prefs;
      final recentlyViewedJson = jsonEncode(recentlyViewed);
      return await prefs.setString(_keyRecentlyViewed, recentlyViewedJson);
    } catch (e) {
      print('❌ Error saving recently viewed: $e');
      return false;
    }
  }

  // ========== إعدادات التطبيق ==========

  /// حفظ حالة اكتمال التعريف بالتطبيق
  Future<bool> setOnboardingComplete(bool complete) async {
    try {
      final prefs = await _prefs;
      return await prefs.setBool(_keyOnboardingComplete, complete);
    } catch (e) {
      print('❌ Error setting onboarding complete: $e');
      return false;
    }
  }

  /// التحقق من اكتمال التعريف بالتطبيق
  Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_keyOnboardingComplete) ?? false;
    } catch (e) {
      print('❌ Error checking onboarding complete: $e');
      return false;
    }
  }

  /// حفظ حالة الإشعارات
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await _prefs;
      return await prefs.setBool(_keyNotificationsEnabled, enabled);
    } catch (e) {
      print('❌ Error setting notifications enabled: $e');
      return false;
    }
  }

  /// التحقق من حالة الإشعارات
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_keyNotificationsEnabled) ?? true;
    } catch (e) {
      print('❌ Error checking notifications enabled: $e');
      return true;
    }
  }

  /// حفظ وضع السمة (فاتح/داكن)
  Future<bool> setThemeMode(String themeMode) async {
    try {
      final prefs = await _prefs;
      return await prefs.setString(_keyThemeMode, themeMode);
    } catch (e) {
      print('❌ Error setting theme mode: $e');
      return false;
    }
  }

  /// قراءة وضع السمة
  Future<String?> getThemeMode() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyThemeMode);
    } catch (e) {
      print('❌ Error getting theme mode: $e');
      return null;
    }
  }

  // ========== عمليات عامة ==========

  /// مسح جميع البيانات المحلية
  Future<bool> clearAllData() async {
    try {
      final prefs = await _prefs;
      await prefs.clear();
      print('✅ All local data cleared successfully');
      return true;
    } catch (e) {
      print('❌ Error clearing all data: $e');
      return false;
    }
  }

  /// حفظ قيمة نصية
  Future<bool> setString(String key, String value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setString(key, value);
    } catch (e) {
      print('❌ Error setting string value: $e');
      return false;
    }
  }

  /// قراءة قيمة نصية
  Future<String?> getString(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getString(key);
    } catch (e) {
      print('❌ Error getting string value: $e');
      return null;
    }
  }

  /// حفظ قيمة منطقية
  Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setBool(key, value);
    } catch (e) {
      print('❌ Error setting bool value: $e');
      return false;
    }
  }

  /// قراءة قيمة منطقية
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(key);
    } catch (e) {
      print('❌ Error getting bool value: $e');
      return null;
    }
  }

  /// حفظ قيمة رقمية صحيحة
  Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await _prefs;
      return await prefs.setInt(key, value);
    } catch (e) {
      print('❌ Error setting int value: $e');
      return false;
    }
  }

  /// قراءة قيمة رقمية صحيحة
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.getInt(key);
    } catch (e) {
      print('❌ Error getting int value: $e');
      return null;
    }
  }

  /// حذف مفتاح معين
  Future<bool> remove(String key) async {
    try {
      final prefs = await _prefs;
      return await prefs.remove(key);
    } catch (e) {
      print('❌ Error removing key: $e');
      return false;
    }
  }

  /// التحقق من وجود مفتاح معين
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(key);
    } catch (e) {
      print('❌ Error checking key existence: $e');
      return false;
    }
  }
}
