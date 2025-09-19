/// النصوص والكلمات الثابتة في التطبيق باللغة العربية
class AppStrings {
  AppStrings._(); // منع إنشاء instance من الكلاس

  // العامة
  static const String appName = 'متجر القرطاسية';
  static const String loading = 'جارٍ التحميل...';
  static const String retry = 'إعادة المحاولة';
  static const String error = 'حدث خطأ';
  static const String success = 'تمت العملية بنجاح';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String save = 'حفظ';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String search = 'البحث...';
  static const String noResults = 'لا توجد نتائج';
  static const String internetError = 'تحقق من الاتصال بالإنترنت';

  // الشاشة الرئيسية
  static const String home = 'الرئيسية';
  static const String categories = 'التصنيفات';
  static const String products = 'المنتجات';
  static const String featuredProducts = 'منتجات مميزة';
  static const String newProducts = 'أحدث المنتجات';
  static const String allProducts = 'جميع المنتجات';
  static const String viewAll = 'عرض الكل';
  static const String searchProducts = 'البحث في المنتجات';

  // المنتجات
  static const String productDetails = 'تفاصيل المنتج';
  static const String description = 'الوصف';
  static const String price = 'السعر';
  static const String quantity = 'الكمية';
  static const String addToCart = 'إضافة للسلة';
  static const String inStock = 'متوفر';
  static const String outOfStock = 'غير متوفر';
  static const String currency = 'ر.س'; // ريال سعودي

  // سلة المشتريات
  static const String cart = 'السلة';
  static const String cartItems = 'عناصر السلة';
  static const String emptyCart = 'السلة فارغة';
  static const String emptyCartMessage = 'لا توجد منتجات في السلة';
  static const String total = 'الإجمالي';
  static const String subtotal = 'المجموع الجزئي';
  static const String checkout = 'تأكيد الطلب';
  static const String removeFromCart = 'إزالة من السلة';
  static const String updateQuantity = 'تحديث الكمية';
  static const String cartItemCount = 'عدد العناصر';

  // المصادقة
  static const String signIn = 'تسجيل الدخول';
  static const String signOut = 'تسجيل الخروج';
  static const String signInWithGoogle = 'تسجيل الدخول مع جوجل';
  static const String welcomeBack = 'مرحباً بك مرة أخرى';
  static const String pleaseSignIn = 'يرجى تسجيل الدخول للمتابعة';
  static const String authError = 'فشل في تسجيل الدخول';
  static const String signOutConfirm = 'هل تريد تسجيل الخروج؟';

  // الملف الشخصي
  static const String profile = 'الملف الشخصي';
  static const String profileSetup = 'إعداد الملف الشخصي';
  static const String personalInfo = 'المعلومات الشخصية';
  static const String fullName = 'الاسم الكامل';
  static const String email = 'البريد الإلكتروني';
  static const String phoneNumber = 'رقم الهاتف';
  static const String address = 'العنوان';
  static const String profileImage = 'الصورة الشخصية';
  static const String updateProfile = 'تحديث الملف الشخصي';
  static const String profileUpdated = 'تم تحديث الملف الشخصي';
  static const String completeProfileFirst =
      'يرجى إكمال المعلومات الشخصية أولاً';

  // التحقق من البيانات
  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'بريد إلكتروني غير صحيح';
  static const String invalidPhone = 'رقم هاتف غير صحيح';
  static const String phoneHint = 'مثال: 0501234567';
  static const String addressHint = 'العنوان الكامل (المدينة، الحي، الشارع)';

  // الطلبات
  static const String orders = 'الطلبات';
  static const String orderConfirmed = 'تم تأكيد الطلب';
  static const String orderConfirmation = 'تأكيد الطلب';
  static const String orderSummary = 'ملخص الطلب';
  static const String contactInfo = 'معلومات التواصل';
  static const String deliveryInfo = 'معلومات التوصيل';
  static const String orderSuccessMessage =
      'تم تسجيل طلبك، سيتم التواصل معك خلال 24 ساعة تقريباً';
  static const String proceedToCheckout = 'متابعة الطلب';

  // الرسائل والإشعارات
  static const String itemAddedToCart = 'تمت إضافة المنتج للسلة';
  static const String itemRemovedFromCart = 'تمت إزالة المنتج من السلة';
  static const String quantityUpdated = 'تم تحديث الكمية';
  static const String profileCompleteRequired =
      'يجب إكمال المعلومات الشخصية قبل الطلب';
  static const String signInRequired = 'يجب تسجيل الدخول قبل الطلب';

  // أزرار وإجراءات
  static const String continueBtn = 'متابعة';
  static const String backBtn = 'رجوع';
  static const String closeBtn = 'إغلاق';
  static const String doneBtn = 'تم';
  static const String nextBtn = 'التالي';
  static const String previousBtn = 'السابق';
  static const String selectImage = 'اختيار صورة';
  static const String takePhoto = 'التقاط صورة';
  static const String chooseFromGallery = 'اختيار من المعرض';

  // رسائل الحالة
  static const String noInternetConnection = 'لا يوجد اتصال بالإنترنت';
  static const String serverError = 'خطأ في الخادم';
  static const String unknownError = 'خطأ غير معروف';
  static const String tryAgainLater = 'حاول مرة أخرى لاحقاً';

  // فئات المنتجات (أمثلة)
  static const String pensCategory = 'أقلام';
  static const String notebooksCategory = 'دفاتر';
  static const String officeSuppliessCategory = 'أدوات مكتبية';
  static const String artSuppliesCategory = 'أدوات فنية';
  static const String schoolSuppliesCategory = 'أدوات مدرسية';
  static const String paperCategory = 'أوراق';
}
