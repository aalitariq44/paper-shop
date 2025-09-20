import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_strings.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/providers/products_provider.dart';
import 'package:paper_shop/presentation/providers/cart_provider.dart';
import 'package:paper_shop/presentation/widgets/product_card.dart';
import 'package:paper_shop/presentation/widgets/contact_dialog.dart';
import 'package:paper_shop/presentation/widgets/loading_widget.dart';
import 'package:paper_shop/presentation/screens/orders/my_orders_screen.dart';
import 'package:paper_shop/presentation/screens/profile/profile_screen.dart';

/// الشاشة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (mounted) {
      final productsProvider = context.read<ProductsProvider>();
      productsProvider.loadCategories();
      productsProvider.loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          // Cart tab replaced by dedicated CartScreen route
          const SizedBox.shrink(),
          _buildOrdersTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Image.asset(
          'assets/images/icon.jpg',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.textLight,
      elevation: 2,
      actions: [
        Transform.translate(
          offset: const Offset(-8, 0),
          child: TextButton(
            onPressed: () => ContactDialog.show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اتصل بنا',
                  style: TextStyle(color: AppColors.textLight),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.call, color: AppColors.textLight),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-8, 0),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: تنفيذ منطق الإشعارات لاحقاً
              },
            ),
          ),
        ),
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final itemCount = cartProvider.itemCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.cart);
                  },
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.cartBadgeColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildWelcomeSection(),
          const SizedBox(height: 12),
          _buildAllProducts(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: AppStrings.searchProducts,
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onSubmitted: (query) {
        if (query.trim().isNotEmpty) {
          _searchProducts(query.trim());
        }
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.isSignedIn
                          ? 'مرحباً ${authProvider.user?.displayName ?? 'بك'}'
                          : 'مرحباً بك في متجر ورق',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اكتشف أحدث منتجات القرطاسية وأدوات المكتب',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.store, color: AppColors.textLight, size: 40),
            ],
          ),
        );
      },
    );
  }

  // تم إزالة قسم المنتجات المميزة بناءً على طلب العميل

  Widget _buildAllProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.allProducts,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Consumer<ProductsProvider>(
          builder: (context, productsProvider, child) {
            if (productsProvider.productsLoading) {
              return const LoadingWidget();
            }

            if (productsProvider.products.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'لا توجد منتجات متاحة حالياً',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // Minimal spacing to maximize card width
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                // Lower ratio for taller cards
                childAspectRatio: 0.65,
              ),
              itemCount: productsProvider.products.length,
              itemBuilder: (context, index) {
                final product = productsProvider.products[index];
                return ProductCard(
                  product: product,
                  onTap: () => _navigateToProductDetails(product.id),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // تم حذف تبويب التصنيفات غير المستخدم لتقليل التعقيد

  Widget _buildOrdersTab() {
    return const MyOrdersScreen();
  }

  Widget _buildProfileTab() {
    // عرض صفحة الملف الشخصي المخصصة بدل الواجهة المضمنة السابقة
    return const ProfileScreen();
  }

  // تم الاستغناء عن عناصر قائمة الملف الشخصي لأن التبويب يعرض ProfileScreen مباشرةً

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) {
          // افتح شاشة السلة الحقيقية بدلاً من التبويب المحذوف
          Navigator.pushNamed(context, AppRoutes.cart);
          return;
        }
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: AppStrings.cart,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: AppStrings.orders,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );
  }

  void _searchProducts(String query) {
    if (mounted) {
      context.read<ProductsProvider>().searchProducts(query);
    }
  }

  void _navigateToProductDetails(String productId) {
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.productDetails,
        arguments: productId,
      );
    }
  }

  // تم نقل منطق تسجيل الخروج للتعامل داخل صفحات الملف الشخصي نفسها عند الحاجة

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
