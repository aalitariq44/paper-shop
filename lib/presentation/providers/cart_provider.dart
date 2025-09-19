import 'package:flutter/material.dart';
import 'package:paper_shop/data/models/product_model.dart';
import 'package:paper_shop/data/models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// مزود حالة سلة المشتريات
class CartProvider extends ChangeNotifier {
  // الحالة الداخلية
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  // مفاتيح التخزين المحلي
  static const String _cartKey = 'cart_items';
  static const String _cartCountKey = 'cart_count';

  bool _disposed = false;

  // الحصول على القيم
  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cartItems.isEmpty;
  int get itemCount => _cartItems.length;

  /// عدد إجمالي القطع في السلة
  int get totalQuantity {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// إجمالي سعر السلة
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// السعر الإجمالي مع الضريبة
  double get totalWithTax {
    const double taxRate = 0.15; // ضريبة 15%
    return totalPrice * (1 + taxRate);
  }

  /// قيمة الضريبة
  double get taxAmount {
    const double taxRate = 0.15;
    return totalPrice * taxRate;
  }

  /// إجمالي السعر مع الشحن والضريبة
  double get grandTotal {
    const double shippingCost = 15.0; // رسوم شحن ثابتة
    return totalWithTax + (totalPrice > 100 ? 0 : shippingCost);
  }

  /// رسوم الشحن
  double get shippingCost {
    const double cost = 15.0;
    return totalPrice > 100 ? 0 : cost; // شحن مجاني للطلبات أكثر من 100 دينار
  }

  /// تحميل السلة من التخزين المحلي
  Future<void> loadCart() async {
    try {
      _setLoading(true);
      _clearError();

      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList(_cartKey);

      if (cartData != null && cartData.isNotEmpty) {
        _cartItems = cartData
            .map((jsonString) => CartItemModel.fromMap(jsonDecode(jsonString)))
            .toList();
      } else {
        _cartItems = [];
      }
    } catch (e) {
      _setError('حدث خطأ في تحميل السلة: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// حفظ السلة في التخزين المحلي
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _cartItems
          .map((item) => jsonEncode(item.toMap()))
          .toList();
      await prefs.setStringList(_cartKey, cartData);
      await prefs.setInt(_cartCountKey, totalQuantity);
    } catch (e) {
      print('❌ Error saving cart: $e');
    }
  }

  /// إضافة منتج إلى السلة
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      _clearError();

      // التحقق من وجود المنتج في السلة
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // إذا كان المنتج موجود، زيادة الكمية
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + quantity,
        );
      } else {
        // إضافة منتج جديد
        final cartItem = CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          addedAt: DateTime.now(),
        );
        _cartItems.add(cartItem);
      }

      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في إضافة المنتج إلى السلة: $e');
    }
  }

  /// تحديث كمية منتج في السلة
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      _clearError();

      if (newQuantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
        await _saveCart();
        notifyListeners();
      }
    } catch (e) {
      _setError('حدث خطأ في تحديث الكمية: $e');
    }
  }

  /// زيادة كمية منتج
  Future<void> increaseQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    await updateQuantity(cartItemId, item.quantity + 1);
  }

  /// تقليل كمية منتج
  Future<void> decreaseQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    if (item.quantity > 1) {
      await updateQuantity(cartItemId, item.quantity - 1);
    } else {
      await removeFromCart(cartItemId);
    }
  }

  /// حذف منتج من السلة
  Future<void> removeFromCart(String cartItemId) async {
    try {
      _clearError();

      _cartItems.removeWhere((item) => item.id == cartItemId);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في حذف المنتج من السلة: $e');
    }
  }

  /// حذف منتج حسب معرف المنتج
  Future<void> removeProductFromCart(String productId) async {
    try {
      _clearError();

      _cartItems.removeWhere((item) => item.product.id == productId);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في حذف المنتج من السلة: $e');
    }
  }

  /// مسح السلة بالكامل
  Future<void> clearCart() async {
    try {
      _clearError();

      _cartItems.clear();
      await _saveCart();
      notifyListeners();
    } catch (e) {
      _setError('حدث خطأ في مسح السلة: $e');
    }
  }

  /// التحقق من وجود منتج في السلة
  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  /// الحصول على كمية منتج معين في السلة
  int getProductQuantity(String productId) {
    try {
      final item = _cartItems.firstWhere(
        (item) => item.product.id == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  /// الحصول على عنصر سلة معين
  CartItemModel? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// الحصول على ملخص الطلب
  Map<String, dynamic> getOrderSummary() {
    return {
      'items': _cartItems.map((item) => item.toMap()).toList(),
      'itemsCount': itemCount,
      'totalQuantity': totalQuantity,
      'subtotal': totalPrice,
      'taxAmount': taxAmount,
      'shippingCost': shippingCost,
      'total': grandTotal,
    };
  }

  /// التحقق من توفر جميع العناصر
  bool get allItemsAvailable {
    return _cartItems.every((item) => item.isAvailable);
  }

  /// الحصول على العناصر غير المتوفرة
  List<CartItemModel> get unavailableItems {
    return _cartItems.where((item) => !item.isAvailable).toList();
  }

  /// الحصول على العناصر المتوفرة
  List<CartItemModel> get availableItems {
    return _cartItems.where((item) => item.isAvailable).toList();
  }

  // وظائف مساعدة لإدارة الحالة
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
