import 'package:cloud_firestore/cloud_firestore.dart';
// import removed: product details are no longer embedded in order items

/// نموذج عنصر الطلب
class OrderItemModel {
  final String id;
  // نحفظ معرف المنتج فقط بدلاً من كامل بياناته
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  /// إنشاء OrderItemModel من Map
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    // دعم الرجوع للخلف: productId الأساسي، ثم product.id (القديم)، ثم categoryId (من تعديل سابق بالخطأ)
    String resolvedProductId = '';
    if (map['productId'] is String) {
      resolvedProductId = map['productId'] as String;
    } else if (map['product'] is Map<String, dynamic>) {
      final p = map['product'] as Map<String, dynamic>;
      if (p['id'] is String) {
        resolvedProductId = p['id'] as String;
      }
    } else if (map['categoryId'] is String) {
      resolvedProductId = map['categoryId'] as String;
    }

    return OrderItemModel(
      id: map['id'] ?? '',
      productId: resolvedProductId,
      quantity: map['quantity'] ?? 1,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  /// تحويل OrderItemModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  /// نسخ OrderItemModel مع تعديل بعض القيم
  OrderItemModel copyWith({
    String? id,
    String? productId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() {
    return 'OrderItemModel{id: $id, productId: $productId, quantity: $quantity, totalPrice: $totalPrice}';
  }
}

/// حالات الطلب
enum OrderStatus {
  pending('pending', 'في الانتظار', '⏳'),
  confirmed('confirmed', 'تم التأكيد', '✅'),
  processing('processing', 'قيد المعالجة', '🔄'),
  shipped('shipped', 'تم الشحن', '🚚'),
  delivered('delivered', 'تم التوصيل', '📦'),
  completed('completed', 'مكتمل', '🎉'),
  cancelled('cancelled', 'ملغي', '❌'),
  rejected('rejected', 'مرفوض', '🚫');

  const OrderStatus(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final String icon;

  /// الحصول على OrderStatus من String
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// التحقق من إمكانية إلغاء الطلب
  bool get canBeCancelled {
    return this == OrderStatus.pending || this == OrderStatus.confirmed;
  }

  /// التحقق من إمكانية تعديل الطلب
  bool get canBeModified {
    return this == OrderStatus.pending;
  }

  /// الحصول على لون الحالة
  int get colorCode {
    switch (this) {
      case OrderStatus.pending:
        return 0xFFFF9800; // Orange
      case OrderStatus.confirmed:
        return 0xFF2196F3; // Blue
      case OrderStatus.processing:
        return 0xFF9C27B0; // Purple
      case OrderStatus.shipped:
        return 0xFF00BCD4; // Cyan
      case OrderStatus.delivered:
        return 0xFF4CAF50; // Green
      case OrderStatus.completed:
        return 0xFF8BC34A; // Light Green
      case OrderStatus.cancelled:
        return 0xFF757575; // Grey
      case OrderStatus.rejected:
        return 0xFFF44336; // Red
    }
  }
}

/// نموذج الطلب
class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String? notes;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveryDate;
  final String? trackingNumber;
  final String? adminNotes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    this.notes,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.deliveryDate,
    this.trackingNumber,
    this.adminNotes,
  });

  /// إنشاء OrderModel من Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel.fromMap(data, doc.id);
  }

  /// إنشاء OrderModel من Map
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userAddress: map['userAddress'] ?? '',
      notes: map['notes'],
      items:
          (map['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      status: OrderStatus.fromString(map['status'] ?? 'pending'),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      deliveryDate: map['deliveryDate'] is Timestamp
          ? (map['deliveryDate'] as Timestamp).toDate()
          : null,
      trackingNumber: map['trackingNumber'],
      adminNotes: map['adminNotes'],
    );
  }

  /// تحويل OrderModel إلى Map للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'notes': notes,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveryDate': deliveryDate != null
          ? Timestamp.fromDate(deliveryDate!)
          : null,
      'trackingNumber': trackingNumber,
      'adminNotes': adminNotes,
    };
  }

  /// نسخ OrderModel مع تعديل بعض القيم
  OrderModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? userPhone,
    String? userAddress,
    String? notes,
    List<OrderItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveryDate,
    String? trackingNumber,
    String? adminNotes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  /// الحصول على عدد العناصر الإجمالي
  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  /// الحصول على رقم الطلب منسق
  String get orderNumber {
    return 'ORD-${id.substring(0, 8).toUpperCase()}';
  }

  /// الحصول على تاريخ الطلب منسق
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// الحصول على وقت الطلب منسق
  String get formattedCreatedTime {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'م' : 'ص';
    return '$hour:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  /// الحصول على المجموع الفرعي منسق
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} د.ع';

  /// الحصول على أجرة التوصيل منسقة
  String get formattedDeliveryFee => '${deliveryFee.toStringAsFixed(0)} د.ع';

  /// الحصول على الإجمالي منسق
  String get formattedTotal => '${total.toStringAsFixed(0)} د.ع';

  /// التحقق من إمكانية إلغاء الطلب
  bool get canBeCancelled => status.canBeCancelled;

  /// التحقق من إمكانية تعديل الطلب
  bool get canBeModified => status.canBeModified;

  /// التحقق من اكتمال الطلب
  bool get isCompleted =>
      status == OrderStatus.completed || status == OrderStatus.delivered;

  /// التحقق من إلغاء الطلب
  bool get isCancelled => status == OrderStatus.cancelled;

  /// التحقق من رفض الطلب
  bool get isRejected => status == OrderStatus.rejected;

  /// التحقق من حالة الطلب النشطة
  bool get isActive {
    return !isCancelled && !isRejected && !isCompleted;
  }

  @override
  String toString() {
    return 'OrderModel{id: $id, orderNumber: $orderNumber, status: ${status.displayName}, total: $formattedTotal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
