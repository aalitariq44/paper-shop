import 'package:flutter/material.dart';

/// ألوان التطبيق الثابتة
class AppColors {
  AppColors._(); // منع إنشاء instance من الكلاس

  // الألوان الرئيسية
  static const Color primaryColor = Color(
    0xFF2E7D32,
  ); // أخضر للطبيعة والقرطاسية
  static const Color primaryLightColor = Color(0xFF4CAF50); // أخضر فاتح
  static const Color primaryDarkColor = Color(0xFF1B5E20); // أخضر داكن
  static const Color secondaryColor = Color(0xFFFFA726); // برتقالي للإبرازات

  // ألوان الخلفيات
  static const Color backgroundColor = Color(0xFFF5F5F5); // رمادي فاتح جداً
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF212121); // أسود داكن
  static const Color textSecondary = Color(0xFF757575); // رمادي
  static const Color textLight = Colors.white;

  // ألوان الحالة
  static const Color successColor = Color(0xFF4CAF50); // أخضر للنجاح
  static const Color errorColor = Color(0xFFF44336); // أحمر للخطأ
  static const Color warningColor = Color(0xFFFF9800); // برتقالي للتحذير
  static const Color infoColor = Color(0xFF2196F3); // أزرق للمعلومات

  // ألوان التفاعل
  static const Color buttonColor = primaryColor;
  static const Color buttonDisabledColor = Color(0xFFBDBDBD); // رمادي فاتح
  static const Color dividerColor = Color(0xFFE0E0E0); // رمادي للخطوط الفاصلة

  // ألوان خاصة بالمتجر
  static const Color priceColor = Color(0xFF2E7D32); // أخضر داكن للأسعار
  static const Color discountColor = Color(0xFFF44336); // أحمر للخصومات
  static const Color cartBadgeColor = Color(0xFFF44336); // أحمر لشارة السلة
  static const Color ratingStarColor = Color(0xFFFFB300); // أصفر ذهبي للتقييم

  // تدرجات لونية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F8F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
