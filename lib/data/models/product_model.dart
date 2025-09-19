import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المنتج
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String imageUrl;
  final List<String>? additionalImages; // صور إضافية
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isAvailable; // حالة التوفر
  final int? stockQuantity; // كمية المخزون
  final bool isFeatured; // منتج مميز
  final double? rating; // تقييم المنتج
  final int? ratingCount; // عدد التقييمات

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    this.additionalImages,
    this.createdAt,
    this.updatedAt,
    this.isAvailable = true,
    this.stockQuantity,
    this.isFeatured = false,
    this.rating,
    this.ratingCount,
  });

  /// إنشاء ProductModel من بيانات Firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      additionalImages: data['additionalImages'] != null
          ? List<String>.from(data['additionalImages'])
          : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isAvailable: data['isAvailable'] ?? true,
      stockQuantity: data['stockQuantity'],
      isFeatured: data['isFeatured'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  /// إنشاء ProductModel من Map
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      additionalImages: map['additionalImages'] != null
          ? List<String>.from(map['additionalImages'])
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isAvailable: map['isAvailable'] ?? true,
      stockQuantity: map['stockQuantity'],
      isFeatured: map['isFeatured'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  /// تحويل ProductModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
      'isFeatured': isFeatured,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  /// نسخ ProductModel مع تعديل بعض القيم
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? imageUrl,
    List<String>? additionalImages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
    int? stockQuantity,
    bool? isFeatured,
    double? rating,
    int? ratingCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  /// الحصول على السعر مع العملة
  String get formattedPrice => '${price.toStringAsFixed(0)} د.ع';

  /// التحقق من وجود المنتج في المخزون
  bool get inStock {
    if (stockQuantity == null) return isAvailable;
    return isAvailable && stockQuantity! > 0;
  }

  /// الحصول على معدل التقييم (من 5)
  double get averageRating => rating ?? 0.0;

  /// الحصول على نص التقييم
  String get ratingText {
    if (ratingCount == null || ratingCount == 0) {
      return 'لا يوجد تقييم';
    }
    return '${averageRating.toStringAsFixed(1)} ($ratingCount تقييم)';
  }

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, price: $price, categoryId: $categoryId, isAvailable: $isAvailable}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
