import 'package:flutter/material.dart';
import 'package:paper_shop/data/repositories/product_repository.dart';
import 'package:paper_shop/data/models/product_model.dart';
import 'package:paper_shop/data/models/category_model.dart';

/// مزود حالة المنتجات والفئات
class ProductsProvider extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository.instance;

  // الحالة الداخلية للفئات
  List<CategoryModel> _categories = [];
  bool _categoriesLoading = false;
  String? _categoriesError;

  // الحالة الداخلية للمنتجات
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  bool _productsLoading = false;
  String? _productsError;

  // الحالة الداخلية للبحث
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';

  bool _disposed = false;

  // الحصول على القيم - الفئات
  List<CategoryModel> get categories => _categories;
  bool get categoriesLoading => _categoriesLoading;
  String? get categoriesError => _categoriesError;

  // الحصول على القيم - المنتجات
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  bool get productsLoading => _productsLoading;
  String? get productsError => _productsError;

  // الحصول على قيم البحث
  List<ProductModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentSearchQuery => _currentSearchQuery;

  /// تحميل جميع الفئات
  Future<void> loadCategories() async {
    try {
      _setCategoriesLoading(true);
      _clearCategoriesError();

      _categories = await _productRepository.getCategories();
    } catch (e) {
      _setCategoriesError('حدث خطأ في تحميل الفئات: $e');
    } finally {
      _setCategoriesLoading(false);
    }
  }

  /// تحميل جميع المنتجات
  Future<void> loadProducts({int? limit}) async {
    try {
      _setProductsLoading(true);
      _clearProductsError();

      _products = await _productRepository.getAllProducts(limit: limit);
    } catch (e) {
      _setProductsError('حدث خطأ في تحميل المنتجات: $e');
    } finally {
      _setProductsLoading(false);
    }
  }

  /// تحميل المنتجات المميزة
  Future<void> loadFeaturedProducts({int? limit}) async {
    try {
      _featuredProducts = await _productRepository.getFeaturedProducts(
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      print('❌ Error loading featured products: $e');
    }
  }

  /// تحميل منتجات فئة معينة
  Future<List<ProductModel>> loadProductsByCategory(
    String categoryId, {
    int? limit,
  }) async {
    try {
      return await _productRepository.getProductsByCategory(
        categoryId,
        limit: limit,
      );
    } catch (e) {
      print('❌ Error loading products by category: $e');
      return [];
    }
  }

  /// البحث في المنتجات
  Future<void> searchProducts(String query, {String? categoryId}) async {
    try {
      _setSearching(true);
      _currentSearchQuery = query;

      if (query.trim().isEmpty) {
        _searchResults = [];
        _setSearching(false);
        return;
      }

      _searchResults = await _productRepository.searchProducts(
        query,
        categoryId: categoryId,
      );
    } catch (e) {
      print('❌ Error searching products: $e');
      _searchResults = [];
    } finally {
      _setSearching(false);
    }
  }

  /// مسح نتائج البحث
  void clearSearch() {
    _searchResults = [];
    _currentSearchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  /// الحصول على منتج واحد
  Future<ProductModel?> getProductById(String productId) async {
    try {
      return await _productRepository.getProductById(productId);
    } catch (e) {
      print('❌ Error getting product by ID: $e');
      return null;
    }
  }

  /// الحصول على المنتجات ذات الصلة
  Future<List<ProductModel>> getRelatedProducts(
    String productId,
    String categoryId,
  ) async {
    try {
      return await _productRepository.getRelatedProducts(productId, categoryId);
    } catch (e) {
      print('❌ Error getting related products: $e');
      return [];
    }
  }

  /// الحصول على أحدث المنتجات
  Future<List<ProductModel>> loadLatestProducts({int limit = 10}) async {
    try {
      return await _productRepository.getLatestProducts(limit: limit);
    } catch (e) {
      print('❌ Error loading latest products: $e');
      return [];
    }
  }

  /// إعادة تحميل جميع البيانات
  Future<void> refreshAll() async {
    await Future.wait([
      loadCategories(),
      loadProducts(),
      loadFeaturedProducts(),
    ]);
  }

  /// الحصول على منتجات من قائمة IDs
  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    try {
      return await _productRepository.getProductsByIds(productIds);
    } catch (e) {
      print('❌ Error getting products by IDs: $e');
      return [];
    }
  }

  // وظائف مساعدة لإدارة حالة الفئات
  void _setCategoriesLoading(bool loading) {
    _categoriesLoading = loading;
    notifyListeners();
  }

  void _setCategoriesError(String? error) {
    _categoriesError = error;
    _categoriesLoading = false;
    notifyListeners();
  }

  void _clearCategoriesError() {
    _categoriesError = null;
    notifyListeners();
  }

  // وظائف مساعدة لإدارة حالة المنتجات
  void _setProductsLoading(bool loading) {
    _productsLoading = loading;
    notifyListeners();
  }

  void _setProductsError(String? error) {
    _productsError = error;
    _productsLoading = false;
    notifyListeners();
  }

  void _clearProductsError() {
    _productsError = null;
    notifyListeners();
  }

  // وظائف مساعدة لإدارة حالة البحث
  void _setSearching(bool searching) {
    _isSearching = searching;
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
