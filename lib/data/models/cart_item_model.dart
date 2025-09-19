import 'package:paper_shop/data/models/product_model.dart';

/// نموذج عنصر سلة المشتريات
class CartItemModel {
  final String id; // معرف العنصر في السلة
  final ProductModel product;
  final int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  /// إنشاء CartItemModel من Map
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      product: ProductModel.fromMap(map['product'], map['product']['id'] ?? ''),
      quantity: map['quantity'] ?? 1,
      addedAt: DateTime.parse(
        map['addedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// تحويل CartItemModel إلى Map للحفظ المحلي
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// نسخ CartItemModel مع تعديل بعض القيم
  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// الحصول على إجمالي سعر هذا العنصر
  double get totalPrice => product.price * quantity;

  /// الحصول على السعر الإجمالي مع العملة
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} ر.س';

  /// التحقق من توفر المنتج بالكمية المطلوبة
  bool get isAvailable {
    if (!product.inStock) return false;

    if (product.stockQuantity != null) {
      return product.stockQuantity! >= quantity;
    }

    return true; // إذا لم يكن هناك معلومات عن المخزون
  }

  /// الحصول على أقصى كمية متاحة
  int get maxAvailableQuantity {
    if (!product.isAvailable) return 0;
    return product.stockQuantity ?? 99; // أقصى كمية افتراضية
  }

  /// التحقق من إمكانية زيادة الكمية
  bool get canIncreaseQuantity {
    return quantity < maxAvailableQuantity;
  }

  /// التحقق من إمكانية تقليل الكمية
  bool get canDecreaseQuantity {
    return quantity > 1;
  }

  @override
  String toString() {
    return 'CartItemModel{id: $id, product: ${product.name}, quantity: $quantity, totalPrice: $totalPrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel &&
        other.id == id &&
        other.product.id == product.id;
  }

  @override
  int get hashCode => id.hashCode ^ product.id.hashCode;
}

/// نموذج سلة المشتريات
class CartModel {
  final List<CartItemModel> items;
  final DateTime lastUpdated;

  CartModel({required this.items, required this.lastUpdated});

  /// إنشاء سلة فارغة
  factory CartModel.empty() {
    return CartModel(items: [], lastUpdated: DateTime.now());
  }

  /// إنشاء CartModel من Map
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      items:
          (map['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      lastUpdated: DateTime.parse(
        map['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// تحويل CartModel إلى Map للحفظ المحلي
  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// نسخ CartModel مع تعديل بعض القيم
  CartModel copyWith({List<CartItemModel>? items, DateTime? lastUpdated}) {
    return CartModel(
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// الحصول على إجمالي عدد العناصر
  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  /// الحصول على إجمالي السعر
  double get totalPrice {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }

  /// الحصول على السعر الإجمالي مع العملة
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} ر.س';

  /// التحقق من وجود عناصر في السلة
  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// البحث عن عنصر معين بمعرف المنتج
  CartItemModel? findItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// التحقق من وجود منتج معين في السلة
  bool containsProduct(String productId) {
    return findItemByProductId(productId) != null;
  }

  /// الحصول على كمية منتج معين
  int getQuantityForProduct(String productId) {
    final item = findItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  /// الحصول على عدد الفئات المختلفة
  int get uniqueItemsCount => items.length;

  /// التحقق من توفر جميع العناصر
  bool get allItemsAvailable {
    return items.every((item) => item.isAvailable);
  }

  /// الحصول على العناصر غير المتوفرة
  List<CartItemModel> get unavailableItems {
    return items.where((item) => !item.isAvailable).toList();
  }

  /// الحصول على العناصر المتوفرة
  List<CartItemModel> get availableItems {
    return items.where((item) => item.isAvailable).toList();
  }

  @override
  String toString() {
    return 'CartModel{items: ${items.length}, totalItems: $totalItems, totalPrice: $totalPrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModel &&
        other.items.length == items.length &&
        other.totalPrice == totalPrice;
  }

  @override
  int get hashCode => items.hashCode ^ totalPrice.hashCode;
}
