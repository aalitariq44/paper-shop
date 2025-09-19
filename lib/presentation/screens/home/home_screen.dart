import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_strings.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/providers/products_provider.dart';
import 'package:paper_shop/presentation/providers/cart_provider.dart';
import 'package:paper_shop/presentation/widgets/product_card.dart';
import 'package:paper_shop/presentation/widgets/loading_widget.dart';

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
      productsProvider.loadFeaturedProducts();
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
          _buildCategoriesTab(),
          _buildCartTab(),
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
            onPressed: () {
              // TODO: تنفيذ منطق الاتصال لاحقاً
            },
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
                    setState(() {
                      _currentIndex = 2; // الانتقال لتبويب السلة
                    });
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildWelcomeSection(),
          const SizedBox(height: 20),
          _buildFeaturedProducts(),
          const SizedBox(height: 20),
          _buildAllProducts(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        decoration: const InputDecoration(
          hintText: AppStrings.searchProducts,
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            _searchProducts(query.trim());
          }
        },
      ),
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

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.featuredProducts,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1; // الانتقال لتبويب التصنيفات
                });
              },
              child: const Text(AppStrings.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer<ProductsProvider>(
          builder: (context, productsProvider, child) {
            if (productsProvider.productsLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (productsProvider.featuredProducts.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'لا توجد منتجات مميزة متاحة حالياً',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productsProvider.featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = productsProvider.featuredProducts[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    child: ProductCard(
                      product: product,
                      onTap: () => _navigateToProductDetails(product.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

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
        const SizedBox(height: 12),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
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

  Widget _buildCategoriesTab() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.categoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productsProvider.categoriesError != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'خطأ في تحميل التصنيفات',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productsProvider.categoriesError!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => productsProvider.loadCategories(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (productsProvider.categories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد تصنيفات متاحة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'لم يتم العثور على أي تصنيفات',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: productsProvider.categories.length,
          itemBuilder: (context, index) {
            final category = productsProvider.categories[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // TODO: Navigate to category products
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم اختيار تصنيف: ${category.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // صورة التصنيف
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          color: AppColors.surfaceColor,
                        ),
                        child: category.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  category.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.category,
                                      size: 48,
                                      color: AppColors.primaryColor,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.category,
                                size: 48,
                                color: AppColors.primaryColor,
                              ),
                      ),
                    ),
                    // اسم التصنيف
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartTab() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.cartItems.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.emptyCart,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppStrings.emptyCartMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.cartItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.inventory,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.product.price} ${AppStrings.currency}',
                                  style: const TextStyle(
                                    color: AppColors.priceColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  cartProvider.decreaseQuantity(item.id);
                                },
                                icon: const Icon(Icons.remove),
                                iconSize: 20,
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  cartProvider.increaseQuantity(item.id);
                                },
                                icon: const Icon(Icons.add),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceColor,
                border: Border(top: BorderSide(color: AppColors.dividerColor)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.total,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${cartProvider.totalPrice.toStringAsFixed(2)} ${AppStrings.currency}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.priceColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _proceedToCheckout(),
                      child: const Text(AppStrings.proceedToCheckout),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isSignedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'يرجى تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سجل دخولك للوصول إلى ملفك الشخصي وطلباتك',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _navigateToLogin(),
                    child: const Text(AppStrings.signIn),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryColor,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.displayName ?? 'المستخدم',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.email ?? '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileMenuItem(
                icon: Icons.edit,
                title: 'تعديل الملف الشخصي',
                onTap: () => _navigateToProfileSetup(),
              ),
              _buildProfileMenuItem(
                icon: Icons.shopping_bag,
                title: 'طلباتي',
                onTap: () {
                  // TODO: Navigate to orders
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.logout,
                title: AppStrings.signOut,
                onTap: () => _showSignOutDialog(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.home),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: AppStrings.categories,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: AppStrings.cart,
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

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  void _navigateToProfileSetup() {
    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.profileSetup);
    }
  }

  void _proceedToCheckout() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.signInRequired),
          backgroundColor: AppColors.errorColor,
        ),
      );
      _navigateToLogin();
      return;
    }

    if (authProvider.user?.hasCompleteProfile != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.profileCompleteRequired),
          backgroundColor: AppColors.warningColor,
        ),
      );
      _navigateToProfileSetup();
      return;
    }

    Navigator.pushNamed(context, AppRoutes.checkout);
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.signOut),
          content: const Text(AppStrings.signOutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  context.read<AuthProvider>().signOut();
                }
              },
              child: const Text(AppStrings.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
