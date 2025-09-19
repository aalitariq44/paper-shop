import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_strings.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/cart_provider.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';

/// شاشة سلة المشتريات
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cart),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearCartDialog(),
                  tooltip: 'مسح السلة',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(child: _buildCartItems(cartProvider)),
              _buildCartSummary(cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.emptyCart,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.emptyCartMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton.primary(
              text: 'تصفح المنتجات',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(CartProvider cartProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final item = cartProvider.cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // صورة المنتج
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: item.product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.inventory,
                                color: AppColors.primaryColor,
                                size: 32,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.inventory,
                          color: AppColors.primaryColor,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                // معلومات المنتج
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.product.description.isNotEmpty) ...[
                        Text(
                          item.product.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Text(
                            '${item.product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.priceColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'x ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الإجمالي: ${item.totalPrice.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // أزرار التحكم في الكمية
                Column(
                  children: [
                    _buildQuantityControls(cartProvider, item),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () => _removeItem(cartProvider, item.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.errorColor,
                      ),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityControls(CartProvider cartProvider, item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: item.quantity > 1
                ? () => cartProvider.decreaseQuantity(item.id)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: item.canIncreaseQuantity
                ? () => cartProvider.increaseQuantity(item.id)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null
                ? AppColors.primaryColor
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(top: BorderSide(color: AppColors.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow('عدد العناصر', '${cartProvider.totalQuantity}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'المجموع الجزئي',
            '${cartProvider.totalPrice.toStringAsFixed(2)} ${AppStrings.currency}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'رسوم الشحن',
            cartProvider.shippingCost > 0
                ? '${cartProvider.shippingCost.toStringAsFixed(0)} ${AppStrings.currency}'
                : 'مجاني',
            isShipping: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'الضريبة (15%)',
            '${cartProvider.taxAmount.toStringAsFixed(2)} ${AppStrings.currency}',
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            AppStrings.total,
            '${cartProvider.grandTotal.toStringAsFixed(2)} ${AppStrings.currency}',
            isTotal: true,
          ),
          const SizedBox(height: 20),
          CustomButton.primary(
            text: AppStrings.proceedToCheckout,
            onPressed: () => _proceedToCheckout(),
            icon: const Icon(Icons.payment, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isShipping = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? AppColors.primaryColor
                : isShipping && value == 'مجاني'
                ? AppColors.successColor
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _removeItem(CartProvider cartProvider, String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف المنتج'),
          content: const Text('هل تريد حذف هذا المنتج من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                cartProvider.removeFromCart(itemId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.itemRemovedFromCart),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              },
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مسح السلة'),
          content: const Text('هل تريد مسح جميع المنتجات من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CartProvider>().clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم مسح السلة'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              },
              child: const Text('مسح'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout() {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.signInRequired),
          backgroundColor: AppColors.errorColor,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    if (authProvider.user?.hasCompleteProfile != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.profileCompleteRequired),
          backgroundColor: AppColors.warningColor,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.profileSetup);
      return;
    }

    Navigator.pushNamed(context, AppRoutes.checkout);
  }
}
