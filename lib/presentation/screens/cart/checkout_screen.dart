import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/cart_provider.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/providers/order_provider.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';

/// صفحة إنهاء الطلب
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنهاء الطلب'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
      ),
      body: Consumer3<CartProvider, AuthProvider, OrderProvider>(
        builder: (context, cartProvider, authProvider, orderProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildOrderSummary(cartProvider),
                _buildUserInfo(authProvider),
                _buildNotesSection(),
                _buildTotalSummary(cartProvider),
                _buildConfirmButton(cartProvider, authProvider, orderProvider),
              ],
            ),
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
            const Text(
              'السلة فارغة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton.primary(
              text: 'العودة للتسوق',
              onPressed: () => Navigator.popUntil(
                context,
                ModalRoute.withName(AppRoutes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartProvider.cartItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = cartProvider.cartItems[index];
              return Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.inventory,
                            color: AppColors.primaryColor,
                            size: 24,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.product.price.toStringAsFixed(0)} د.ع × ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(0)} د.ع',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'معلومات التوصيل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profileSetup);
                },
                child: const Text(
                  'تعديل',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'الاسم', user.displayName ?? 'غير محدد'),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone,
            'رقم الهاتف',
            user.phoneNumber ?? 'غير محدد',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'العنوان',
            user.address ?? 'غير محدد',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملاحظات إضافية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'أدخل أي ملاحظات أو تفاصيل إضافية للطلب...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(CartProvider cartProvider) {
    const deliveryFee = 5000.0; // أجرة التوصيل الثابتة

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('عدد العناصر', '${cartProvider.totalQuantity} قطعة'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'مجموع الطلب',
            '${cartProvider.totalPrice.toStringAsFixed(0)} د.ع',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'أجرة التوصيل',
            '${deliveryFee.toStringAsFixed(0)} د.ع',
            isDelivery: true,
          ),
          const Divider(height: 24, thickness: 2),
          _buildSummaryRow(
            'الإجمالي الكلي',
            '${(cartProvider.totalPrice + deliveryFee).toStringAsFixed(0)} د.ع',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDelivery = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? AppColors.primaryColor
                : isDelivery
                ? AppColors.warningColor
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(
    CartProvider cartProvider,
    AuthProvider authProvider,
    OrderProvider orderProvider,
  ) {
    // Ensure confirm button stays above system navigation (SafeArea)
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomButton.primary(
              text: _isProcessing ? 'جاري معالجة الطلب...' : 'تأكيد الطلب',
              onPressed: _isProcessing
                  ? null
                  : () => _confirmOrder(
                      cartProvider,
                      authProvider,
                      orderProvider,
                    ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'بالضغط على تأكيد الطلب فإنك توافق على شروط وأحكام الخدمة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(
    CartProvider cartProvider,
    AuthProvider authProvider,
    OrderProvider orderProvider,
  ) async {
    final user = authProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: بيانات المستخدم غير متوفرة'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (!user.hasCompleteProfile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إكمال بيانات الملف الشخصي أولاً'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.profileSetup);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await orderProvider.createOrder(
        userId: user.uid,
        userEmail: user.email,
        userName: user.displayName ?? 'غير محدد',
        userPhone: user.phoneNumber ?? 'غير محدد',
        userAddress: user.address ?? 'غير محدد',
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        cartItems: cartProvider.cartItems,
      );

      // مسح السلة
      await cartProvider.clearCart();

      // الانتقال إلى صفحة تأكيد الطلب
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.orderConfirmation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إنشاء الطلب: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
