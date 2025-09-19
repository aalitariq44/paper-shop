import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

/// أدوات مساعدة مختلفة للتطبيق
class AppHelpers {
  AppHelpers._(); // منع إنشاء instance من الكلاس

  // ========== تنسيق الأرقام والتواريخ ==========

  /// تنسيق السعر مع العملة
  static String formatPrice(double price) {
    return '${NumberFormat('#,##0', 'ar').format(price)} ر.س';
  }

  /// تنسيق الرقم مع الفواصل
  static String formatNumber(int number) {
    return NumberFormat('#,##0', 'ar').format(number);
  }

  /// تنسيق التاريخ باللغة العربية
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  /// تنسيق التاريخ والوقت باللغة العربية
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a', 'ar').format(dateTime);
  }

  /// الحصول على الوقت النسبي (منذ كم)
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years سنة';
    }
  }

  // ========== تنسيق النصوص ==========

  /// اقتطاع النص مع إضافة نقاط
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// تحويل أول حرف إلى كابيتال
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// تحويل النص إلى عنوان (كل كلمة تبدأ بحرف كابيتال)
  static String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => capitalize(word.toLowerCase()))
        .join(' ');
  }

  // ========== أدوات اللون ==========

  /// الحصول على لون نص مناسب حسب لون الخلفية
  static Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// تحويل HEX إلى Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// تحويل Color إلى HEX
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  // ========== أدوات الشاشة ==========

  /// التحقق من حجم الشاشة
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600;
  }

  /// التحقق من الاتجاه
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// الحصول على عرض الشاشة
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// الحصول على ارتفاع الشاشة
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// الحصول على padding الآمن
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // ========== أدوات التنقل ==========

  /// التنقل إلى صفحة جديدة
  static Future<T?> navigateTo<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (context) => page));
  }

  /// التنقل مع استبدال الصفحة الحالية
  static Future<T?> navigateReplacement<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// التنقل مع مسح جميع الصفحات السابقة
  static Future<T?> navigateAndClearStack<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  /// الرجوع للصفحة السابقة
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }

  // ========== أدوات النوافذ المنبثقة ==========

  /// إظهار رسالة SnackBar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// إظهار رسالة نجاح
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// إظهار رسالة خطأ
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// إظهار رسالة تحذير
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// إظهار حوار تأكيد
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: confirmColor != null
                  ? TextButton.styleFrom(foregroundColor: confirmColor)
                  : null,
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// إظهار حوار المعلومات
  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'موافق',
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// إظهار مؤشر التحميل
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        );
      },
    );
  }

  /// إخفاء مؤشر التحميل
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // ========== أدوات أخرى ==========

  /// إخفاء لوحة المفاتيح
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// التحقق من الاتصال بالإنترنت (يحتاج حزمة connectivity_plus)
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// توليد معرف عشوائي
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// التحقق من كون القائمة فارغة أم لا
  static bool isListEmpty<T>(List<T>? list) {
    return list == null || list.isEmpty;
  }

  /// التحقق من كون النص فارغاً أم لا
  static bool isStringEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// حساب المسافة بين نقطتين (للخرائط)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // هذه دالة بسيطة للحساب التقريبي
    // للاستخدام الفعلي قد تحتاج لحزمة geolocator
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// تحويل extension الملف إلى نوع MIME
  static String getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
