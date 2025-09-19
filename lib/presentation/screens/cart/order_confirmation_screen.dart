import 'package:flutter/material.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';

/// صفحة تأكيد الطلب
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الطلب'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
        automaticallyImplyLeading: false, // منع زر الرجوع
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة النجاح
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.successColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 60,
                        color: AppColors.successColor,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // رسالة النجاح الرئيسية
                    const Text(
                      'تم استلام طلبك بنجاح!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // رسالة تفصيلية
                    const Text(
                      'شكراً لك على طلبك. سنتواصل معك خلال 24 ساعة لتأكيد التفاصيل وموعد التوصيل.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // معلومات إضافية
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'معلومات مهمة:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const _InfoItem(
                            text: 'يمكنك متابعة حالة طلبك من قسم "طلباتي"',
                          ),
                          const SizedBox(height: 8),
                          const _InfoItem(
                            text: 'ستصلك رسالة تأكيد على رقم الهاتف المسجل',
                          ),
                          const SizedBox(height: 8),
                          const _InfoItem(
                            text: 'أجرة التوصيل المتفق عليها 5,000 د.ع',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // معلومات الاتصال
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dividerColor),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'للاستفسارات:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'خدمة العملاء - 24/7',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // أزرار التنقل
              Column(
                children: [
                  CustomButton.primary(
                    text: 'عرض طلباتي',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.orders,
                      ModalRoute.withName(AppRoutes.home),
                    ),
                    icon: const Icon(
                      Icons.list_alt,
                      color: AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 12),

                  CustomButton.outlined(
                    text: 'متابعة التسوق',
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر معلومات
class _InfoItem extends StatelessWidget {
  final String text;

  const _InfoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 8, left: 8),
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
