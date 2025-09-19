/// مسارات التطبيق وأسماء الصفحات
class AppRoutes {
  AppRoutes._(); // منع إنشاء instance من الكلاس

  // المسارات الأساسية
  static const String home = '/';
  static const String login = '/login';
  static const String profileSetup = '/profile-setup';
  static const String profile = '/profile';

  // مسارات المنتجات
  static const String productDetails = '/product-details';
  static const String categoryProducts = '/category-products';
  static const String searchResults = '/search-results';

  // مسارات السلة والطلبات
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';

  // مسارات أخرى
  static const String about = '/about';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String terms = '/terms';
  static const String help = '/help';
}

/// أسماء المعاملات للتنقل بين الصفحات
class RouteArguments {
  RouteArguments._();

  static const String productId = 'productId';
  static const String categoryId = 'categoryId';
  static const String searchQuery = 'searchQuery';
  static const String orderId = 'orderId';
  static const String userId = 'userId';
}
