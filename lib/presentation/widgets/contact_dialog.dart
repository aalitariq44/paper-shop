import 'package:flutter/material.dart';
import 'package:paper_shop/core/constants/app_colors.dart';

/// نافذة اتصل بنا المنبثقة
class ContactDialog extends StatelessWidget {
  const ContactDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'اتصل بنا',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('يمكنك التواصل معنا من خلال:'),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone, color: AppColors.primaryColor, size: 20),
              SizedBox(width: 8),
              Text('07701658558'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الموصل - المجموعة الثقافية - مقابل جامع هيبة خاتون وازل البريد',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  /// عرض النافذة المنبثقة
  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const ContactDialog());
  }
}
