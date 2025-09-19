import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paper_shop/data/models/order_model.dart';

/// مستودع إدارة الطلبات في Firebase
class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // اسم المجموعة في Firestore
  static const String _collection = 'orders';

  /// إنشاء طلب جديد
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      // إنشاء مرجع جديد للطلب
      final docRef = _firestore.collection(_collection).doc();

      // إنشاء الطلب مع المعرف الجديد
      final orderWithId = order.copyWith(id: docRef.id);

      // حفظ الطلب في Firestore
      await docRef.set(orderWithId.toMap());

      return orderWithId;
    } catch (e) {
      throw Exception('فشل في إنشاء الطلب: $e');
    }
  }

  /// الحصول على طلب بالمعرف
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();

      if (doc.exists && doc.data() != null) {
        return OrderModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      throw Exception('فشل في الحصول على الطلب: $e');
    }
  }

  /// الحصول على طلبات المستخدم
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('فشل في تحميل طلبات المستخدم: $e');
    }
  }

  /// الحصول على جميع الطلبات (للإدارة)
  Future<List<OrderModel>> getAllOrders({
    OrderStatus? status,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('فشل في تحميل الطلبات: $e');
    }
  }

  /// تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('فشل في تحديث حالة الطلب: $e');
    }
  }

  /// إلغاء طلب
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.cancelled.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'adminNotes': reason,
      });
    } catch (e) {
      throw Exception('فشل في إلغاء الطلب: $e');
    }
  }

  /// رفض طلب
  Future<void> rejectOrder(String orderId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.rejected.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'adminNotes': reason,
      });
    } catch (e) {
      throw Exception('فشل في رفض الطلب: $e');
    }
  }

  /// تأكيد طلب
  Future<void> confirmOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.confirmed.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('فشل في تأكيد الطلب: $e');
    }
  }

  /// تحديث معلومات التوصيل
  Future<void> updateDeliveryInfo({
    required String orderId,
    String? trackingNumber,
    DateTime? deliveryDate,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (trackingNumber != null) {
        updates['trackingNumber'] = trackingNumber;
      }

      if (deliveryDate != null) {
        updates['deliveryDate'] = Timestamp.fromDate(deliveryDate);
      }

      await _firestore.collection(_collection).doc(orderId).update(updates);
    } catch (e) {
      throw Exception('فشل في تحديث معلومات التوصيل: $e');
    }
  }

  /// شحن طلب
  Future<void> shipOrder(String orderId, {String? trackingNumber}) async {
    try {
      final updates = <String, dynamic>{
        'status': OrderStatus.shipped.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (trackingNumber != null) {
        updates['trackingNumber'] = trackingNumber;
      }

      await _firestore.collection(_collection).doc(orderId).update(updates);
    } catch (e) {
      throw Exception('فشل في شحن الطلب: $e');
    }
  }

  /// توصيل طلب
  Future<void> deliverOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.delivered.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'deliveryDate': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('فشل في توصيل الطلب: $e');
    }
  }

  /// إكمال طلب
  Future<void> completeOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderStatus.completed.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('فشل في إكمال الطلب: $e');
    }
  }

  /// البحث في الطلبات
  Future<List<OrderModel>> searchOrders({
    required String searchTerm,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();

      List<OrderModel> orders = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // تطبيق فلترة النص محلياً
      if (searchTerm.isNotEmpty) {
        final lowerSearchTerm = searchTerm.toLowerCase();
        orders = orders.where((order) {
          return order.orderNumber.toLowerCase().contains(lowerSearchTerm) ||
              order.userName.toLowerCase().contains(lowerSearchTerm) ||
              order.userPhone.contains(searchTerm) ||
              order.userEmail.toLowerCase().contains(lowerSearchTerm);
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('فشل في البحث في الطلبات: $e');
    }
  }

  /// إحصائيات الطلبات
  Future<Map<String, int>> getOrdersStatistics() async {
    try {
      final allOrders = await getAllOrders(limit: 1000);

      final stats = <String, int>{
        'total': allOrders.length,
        'pending': 0,
        'confirmed': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'completed': 0,
        'cancelled': 0,
        'rejected': 0,
      };

      for (final order in allOrders) {
        switch (order.status) {
          case OrderStatus.pending:
            stats['pending'] = stats['pending']! + 1;
            break;
          case OrderStatus.confirmed:
            stats['confirmed'] = stats['confirmed']! + 1;
            break;
          case OrderStatus.processing:
            stats['processing'] = stats['processing']! + 1;
            break;
          case OrderStatus.shipped:
            stats['shipped'] = stats['shipped']! + 1;
            break;
          case OrderStatus.delivered:
            stats['delivered'] = stats['delivered']! + 1;
            break;
          case OrderStatus.completed:
            stats['completed'] = stats['completed']! + 1;
            break;
          case OrderStatus.cancelled:
            stats['cancelled'] = stats['cancelled']! + 1;
            break;
          case OrderStatus.rejected:
            stats['rejected'] = stats['rejected']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('فشل في الحصول على إحصائيات الطلبات: $e');
    }
  }

  /// مراقبة طلبات المستخدم في الوقت الفعلي
  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// مراقبة جميع الطلبات في الوقت الفعلي (للإدارة)
  Stream<List<OrderModel>> watchAllOrders({OrderStatus? status}) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList(),
    );
  }
}
