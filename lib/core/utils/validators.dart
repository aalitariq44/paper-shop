/// أدوات التحقق من صحة البيانات
class Validators {
  Validators._(); // منع إنشاء instance من الكلاس

  /// التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    if (!emailRegExp.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// التحقق من رقم الهاتف السعودي
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // إزالة المسافات والرموز الخاصة
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');

    // الأنماط المختلفة للأرقام السعودية
    final patterns = [
      RegExp(r'^05\d{8}$'), // 05xxxxxxxx
      RegExp(r'^\+9665\d{8}$'), // +9665xxxxxxxx
      RegExp(r'^9665\d{8}$'), // 9665xxxxxxxx
    ];

    if (!patterns.any((pattern) => pattern.hasMatch(cleanPhone))) {
      return 'رقم الهاتف غير صحيح (مثال: 0501234567)';
    }

    return null;
  }

  /// التحقق من الاسم الكامل
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }

    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون أكثر من حرف واحد';
    }

    if (value.trim().length > 50) {
      return 'الاسم طويل جداً';
    }

    // التحقق من وجود حروف عربية أو إنجليزية فقط
    final nameRegExp = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  /// التحقق من العنوان
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'العنوان مطلوب';
    }

    if (value.trim().length < 10) {
      return 'العنوان قصير جداً (أقل من 10 أحرف)';
    }

    if (value.trim().length > 200) {
      return 'العنوان طويل جداً';
    }

    return null;
  }

  /// التحقق من كلمة البحث
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة للبحث';
    }

    if (value.trim().length < 2) {
      return 'كلمة البحث قصيرة جداً';
    }

    if (value.trim().length > 100) {
      return 'كلمة البحث طويلة جداً';
    }

    return null;
  }

  /// التحقق من الكمية
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'الكمية مطلوبة';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'الكمية يجب أن تكون رقماً صحيحاً';
    }

    if (quantity < 1) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }

    if (quantity > 99) {
      return 'الكمية يجب أن تكون أقل من 100';
    }

    return null;
  }

  /// التحقق من السعر
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'السعر مطلوب';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'السعر يجب أن يكون رقماً صحيحاً';
    }

    if (price < 0) {
      return 'السعر يجب أن يكون أكبر من صفر';
    }

    if (price > 999999) {
      return 'السعر مرتفع جداً';
    }

    return null;
  }

  /// التحقق من النص العام (غير فارغ)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    if (value.trim().isEmpty) {
      return '$fieldName لا يمكن أن يكون فارغاً';
    }

    return null;
  }

  /// التحقق من الرقم الموجب
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName يجب أن يكون رقماً';
    }

    if (number <= 0) {
      return '$fieldName يجب أن يكون أكبر من صفر';
    }

    return null;
  }

  /// التحقق من الرقم الصحيح الموجب
  static String? validatePositiveInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName يجب أن يكون رقماً صحيحاً';
    }

    if (number <= 0) {
      return '$fieldName يجب أن يكون أكبر من صفر';
    }

    return null;
  }

  /// التحقق من طول النص
  static String? validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }

    if (minLength != null && value.trim().length < minLength) {
      return '$fieldName يجب أن يكون على الأقل $minLength أحرف';
    }

    if (maxLength != null && value.trim().length > maxLength) {
      return '$fieldName يجب أن يكون أقل من $maxLength حرف';
    }

    return null;
  }

  /// التحقق من تطابق النصوص
  static String? validateMatch(
    String? value1,
    String? value2,
    String fieldName,
  ) {
    if (value1 == null || value1.isEmpty) {
      return '$fieldName مطلوب';
    }

    if (value1 != value2) {
      return '$fieldName غير متطابق';
    }

    return null;
  }

  /// التحقق من الرابط (URL)
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرابط مطلوب';
    }

    final urlRegExp = RegExp(
      r'^https?://(?:[-\w.])+(?:\:[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:\#(?:[\w.])*)?)?$',
    );

    if (!urlRegExp.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  /// التحقق من تاريخ الميلاد (عمر أكبر من 13 سنة)
  static String? validateBirthDate(DateTime? value) {
    if (value == null) {
      return 'تاريخ الميلاد مطلوب';
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (age < 13) {
      return 'يجب أن يكون العمر أكبر من 13 سنة';
    }

    if (age > 100) {
      return 'تاريخ الميلاد غير صحيح';
    }

    return null;
  }

  /// تنظيف النص (إزالة المسافات الزائدة)
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// تنظيف رقم الهاتف
  static String cleanPhoneNumber(String phone) {
    // إزالة جميع الرموز غير الرقمية ما عدا علامة +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // تحويل الأنماط المختلفة إلى النمط الموحد
    if (cleaned.startsWith('+9665')) {
      cleaned = '05${cleaned.substring(5)}';
    } else if (cleaned.startsWith('9665')) {
      cleaned = '05${cleaned.substring(4)}';
    }

    return cleaned;
  }

  /// تنسيق رقم الهاتف للعرض
  static String formatPhoneNumber(String phone) {
    final cleaned = cleanPhoneNumber(phone);

    if (cleaned.startsWith('05') && cleaned.length == 10) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }

    return phone;
  }
}
