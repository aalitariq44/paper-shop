import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paper_shop/data/models/product_model.dart';
import 'package:paper_shop/data/models/category_model.dart';

/// مستودع البيانات للتعامل مع المنتجات والفئات
class ProductRepository {
  static ProductRepository? _instance;

  ProductRepository._();

  static ProductRepository get instance {
    _instance ??= ProductRepository._();
    return _instance!;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== عمليات الفئات ==========

  /// الحصول على جميع الفئات
  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .orderBy('sortOrder', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting categories: $e');
      return [];
    }
  }

  /// stream للفئات
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .orderBy('sortOrder', descending: false)
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('❌ Error in categories stream: $error');
          return <CategoryModel>[];
        });
  }

  /// الحصول على فئة واحدة
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting category by ID: $e');
      return null;
    }
  }

  // ========== عمليات المنتجات ==========

  /// الحصول على جميع المنتجات
  Future<List<ProductModel>> getAllProducts({
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting all products: $e');
      return [];
    }
  }

  /// stream لجميع المنتجات
  Stream<List<ProductModel>> getAllProductsStream({int? limit}) {
    Query query = _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('❌ Error in products stream: $error');
          return <ProductModel>[];
        });
  }

  /// الحصول على المنتجات المميزة
  Future<List<ProductModel>> getFeaturedProducts({int? limit}) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting featured products: $e');
      return [];
    }
  }

  /// stream للمنتجات المميزة
  Stream<List<ProductModel>> getFeaturedProductsStream({int? limit}) {
    Query query = _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('❌ Error in featured products stream: $error');
          return <ProductModel>[];
        });
  }

  /// الحصول على منتجات فئة معينة
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    int? limit,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting products by category: $e');
      return [];
    }
  }

  /// stream لمنتجات فئة معينة
  Stream<List<ProductModel>> getProductsByCategoryStream(
    String categoryId, {
    int? limit,
  }) {
    Query query = _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((querySnapshot) {
          return querySnapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('❌ Error in products by category stream: $error');
          return <ProductModel>[];
        });
  }

  /// الحصول على منتج واحد
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting product by ID: $e');
      return null;
    }
  }

  /// stream لمنتج واحد
  Stream<ProductModel?> getProductByIdStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .snapshots()
        .map((docSnapshot) {
          if (docSnapshot.exists) {
            return ProductModel.fromFirestore(docSnapshot);
          }
          return null;
        })
        .handleError((error) {
          print('❌ Error in product by ID stream: $error');
          return null;
        });
  }

  /// البحث في المنتجات
  Future<List<ProductModel>> searchProducts(
    String searchTerm, {
    String? categoryId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true);

      // إضافة فلتر الفئة إن وُجد
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final querySnapshot = await query.get();

      // فلترة النتائج محلياً حسب النص المدخل
      // هذا حل مؤقت - للحل الأفضل يُفضل استخدام Algolia أو خدمة البحث الأخرى
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) {
            final searchLower = searchTerm.toLowerCase();
            return product.name.toLowerCase().contains(searchLower) ||
                product.description.toLowerCase().contains(searchLower);
          })
          .toList();

      // ترتيب النتائج حسب الصلة
      products.sort((a, b) {
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();
        final searchLower = searchTerm.toLowerCase();

        // إعطاء أولوية للمنتجات التي تبدأ بكلمة البحث
        if (aName.startsWith(searchLower) && !bName.startsWith(searchLower)) {
          return -1;
        } else if (!aName.startsWith(searchLower) &&
            bName.startsWith(searchLower)) {
          return 1;
        }

        // ثم الترتيب حسب التاريخ
        return b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0;
      });

      if (limit != null && products.length > limit) {
        return products.sublist(0, limit);
      }

      return products;
    } catch (e) {
      print('❌ Error searching products: $e');
      return [];
    }
  }

  /// الحصول على المنتجات ذات الصلة (نفس الفئة)
  Future<List<ProductModel>> getRelatedProducts(
    String productId,
    String categoryId, {
    int limit = 6,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit + 1) // +1 للتأكد من استبعاد المنتج الحالي
          .get();

      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) => product.id != productId) // استبعاد المنتج الحالي
          .take(limit)
          .toList();

      return products;
    } catch (e) {
      print('❌ Error getting related products: $e');
      return [];
    }
  }

  /// الحصول على أحدث المنتجات
  Future<List<ProductModel>> getLatestProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting latest products: $e');
      return [];
    }
  }

  /// الحصول على المنتجات حسب IDs محددة
  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    try {
      if (productIds.isEmpty) return [];

      // Firestore يدعم حتى 10 عناصر في in query
      if (productIds.length <= 10) {
        final querySnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: productIds)
            .get();

        return querySnapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();
      } else {
        // تقسيم القائمة إلى مجموعات من 10
        final List<ProductModel> allProducts = [];
        for (int i = 0; i < productIds.length; i += 10) {
          final chunk = productIds.sublist(
            i,
            i + 10 > productIds.length ? productIds.length : i + 10,
          );

          final querySnapshot = await _firestore
              .collection('products')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          final chunkProducts = querySnapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();

          allProducts.addAll(chunkProducts);
        }
        return allProducts;
      }
    } catch (e) {
      print('❌ Error getting products by IDs: $e');
      return [];
    }
  }

  /// التحقق من توفر المنتج
  Future<bool> isProductAvailable(String productId) async {
    try {
      final product = await getProductById(productId);
      return product?.inStock ?? false;
    } catch (e) {
      print('❌ Error checking product availability: $e');
      return false;
    }
  }

  /// إحصائيات المنتجات (للإدارة)
  Future<Map<String, int>> getProductsStats() async {
    try {
      final allProductsSnapshot = await _firestore.collection('products').get();

      final availableProductsSnapshot = await _firestore
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();

      final featuredProductsSnapshot = await _firestore
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .get();

      return {
        'total': allProductsSnapshot.docs.length,
        'available': availableProductsSnapshot.docs.length,
        'featured': featuredProductsSnapshot.docs.length,
        'unavailable':
            allProductsSnapshot.docs.length -
            availableProductsSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting products stats: $e');
      return {'total': 0, 'available': 0, 'featured': 0, 'unavailable': 0};
    }
  }
}
