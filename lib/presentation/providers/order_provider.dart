import 'package:flutter/material.dart';
import 'package:paper_shop/data/models/order_model.dart';
import 'package:paper_shop/data/models/cart_item_model.dart';
import 'package:paper_shop/data/repositories/order_repository.dart';

/// مزود إدارة الطلبات
class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل طلبات المستخدم
  Future<void> loadOrders(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _orders = await _orderRepository.getUserOrders(userId);
      notifyListeners();
    } catch (e) {
      _setError('فشل في تحميل الطلبات: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// إنشاء طلب جديد
  Future<OrderModel> createOrder({
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required String userAddress,
    String? notes,
    required List<CartItemModel> cartItems,
  }) async {
    _clearError();

    try {
      // حساب المبالغ
      final subtotal = cartItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      const deliveryFee = 5000.0; // أجرة التوصيل الثابتة
      final total = subtotal + deliveryFee;

      // تحويل عناصر السلة إلى عناصر الطلب
      final orderItems = cartItems.map((cartItem) {
        return OrderItemModel(
          id: cartItem.id,
          productId: cartItem.product.id,
          quantity: cartItem.quantity,
          unitPrice: cartItem.product.price,
          totalPrice: cartItem.totalPrice,
        );
      }).toList();

      // إنشاء نموذج الطلب
      final order = OrderModel(
        id: '', // سيتم تعيينه من Firestore
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        userPhone: userPhone,
        userAddress: userAddress,
        notes: notes,
        items: orderItems,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      // حفظ الطلب في قاعدة البيانات
      final createdOrder = await _orderRepository.createOrder(order);

      // إضافة الطلب للقائمة المحلية
      _orders.insert(0, createdOrder);
      notifyListeners();

      return createdOrder;
    } catch (e) {
      _setError('فشل في إنشاء الطلب: $e');
      rethrow;
    }
  }

  /// الحصول على طلب معين بالمعرف
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return await _orderRepository.getOrderById(orderId);
    } catch (e) {
      _setError('فشل في الحصول على الطلب: $e');
      return null;
    }
  }

  /// تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _clearError();

    try {
      await _orderRepository.updateOrderStatus(orderId, newStatus);

      // تحديث الطلب في القائمة المحلية
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في تحديث حالة الطلب: $e');
    }
  }

  /// إلغاء طلب
  Future<void> cancelOrder(String orderId, String reason) async {
    _clearError();

    try {
      await _orderRepository.cancelOrder(orderId, reason);

      // تحديث الطلب في القائمة المحلية
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
          adminNotes: reason,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل في إلغاء الطلب: $e');
      rethrow;
    }
  }

  /// الحصول على الطلبات حسب الحالة
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// الحصول على الطلبات النشطة (غير المكتملة أو الملغاة)
  List<OrderModel> get activeOrders {
    return _orders.where((order) => order.isActive).toList();
  }

  /// الحصول على الطلبات المكتملة
  List<OrderModel> get completedOrders {
    return _orders.where((order) => order.isCompleted).toList();
  }

  /// الحصول على الطلبات الملغاة
  List<OrderModel> get cancelledOrders {
    return _orders.where((order) => order.isCancelled).toList();
  }

  /// الحصول على الطلبات المرفوضة
  List<OrderModel> get rejectedOrders {
    return _orders.where((order) => order.isRejected).toList();
  }

  /// الحصول على الطلبات في الانتظار
  List<OrderModel> get pendingOrders {
    return getOrdersByStatus(OrderStatus.pending);
  }

  /// الحصول على عدد الطلبات النشطة
  int get activeOrdersCount => activeOrders.length;

  /// البحث في الطلبات
  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return _orders;

    final lowerQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.orderNumber.toLowerCase().contains(lowerQuery) ||
          order.userName.toLowerCase().contains(lowerQuery) ||
          order.userPhone.contains(query) ||
          order.items.any(
            (item) => item.productId.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  /// تحديث الطلبات تلقائياً
  Future<void> refreshOrders(String userId) async {
    await loadOrders(userId);
  }

  /// مسح الطلبات المحلية
  void clearOrders() {
    _orders.clear();
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _orders.clear();
    super.dispose();
  }
}
