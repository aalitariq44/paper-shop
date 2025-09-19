import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج فئة المنتجات
class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime? createdAt;
  final int? sortOrder; // ترتيب العرض

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.createdAt,
    this.sortOrder,
  });

  /// إنشاء CategoryModel من بيانات Firestore
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  /// إنشاء CategoryModel من Map
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  /// تحويل CategoryModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'sortOrder': sortOrder,
    };
  }

  /// نسخ CategoryModel مع تعديل بعض القيم
  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, imageUrl: $imageUrl, createdAt: $createdAt, sortOrder: $sortOrder}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
