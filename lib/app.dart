import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_strings.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/providers/products_provider.dart';
import 'package:paper_shop/presentation/providers/cart_provider.dart';
import 'package:paper_shop/presentation/providers/user_provider.dart';
import 'package:paper_shop/presentation/screens/home/home_screen.dart';
import 'package:paper_shop/presentation/screens/auth/login_screen.dart';
import 'package:paper_shop/presentation/screens/profile/profile_setup_screen.dart';
import 'package:paper_shop/presentation/screens/cart/cart_screen.dart';
import 'package:paper_shop/presentation/screens/product/product_details_screen.dart';

/// التطبيق الرئيسي لمتجر ورق
class PaperShopApp extends StatelessWidget {
  const PaperShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // مزودي إدارة الحالة
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            // إعدادات التطبيق الأساسية
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,

            // إعدادات اللغة والاتجاه
            locale: const Locale('ar', 'SA'), // العربية السعودية
            supportedLocales: const [
              Locale('ar', 'SA'), // العربية
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // إعدادات السمة
            theme: _buildThemeData(),

            // إعدادات التنقل
            navigatorKey: GlobalKey<NavigatorState>(),
            onGenerateRoute: _onGenerateRoute,
            initialRoute: _getInitialRoute(authProvider),

            // البناء حسب حالة المصادقة
            home: _buildHomeScreen(authProvider),
          );
        },
      ),
    );
  }

  /// إنشاء سمة التطبيق
  ThemeData _buildThemeData() {
    return ThemeData(
      // الألوان الأساسية
      primarySwatch: MaterialColor(AppColors.primaryColor.value, <int, Color>{
        50: Color(0xFFE8F5E8),
        100: Color(0xFFC6E6C7),
        200: Color(0xFFA1D5A3),
        300: Color(0xFF7CC47E),
        400: Color(0xFF60B663),
        500: AppColors.primaryColor,
        600: Color(0xFF43A047),
        700: Color(0xFF388E3C),
        800: Color(0xFF2E7D32),
        900: Color(0xFF1B5E20),
      }),
      primaryColor: AppColors.primaryColor,

      // ألوان إضافية
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light,
        secondary: AppColors.secondaryColor,
        surface: AppColors.surfaceColor,
        error: AppColors.errorColor,
      ),

      // ألوان الخلفية
      scaffoldBackgroundColor: AppColors.backgroundColor,
      canvasColor: AppColors.backgroundColor,
      cardColor: AppColors.cardColor,

      // سمة شريط التطبيق
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),

      // سمة الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.textLight,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // سمة الأزرار النصية
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // سمة الأيقونات
      iconTheme: const IconThemeData(color: AppColors.primaryColor, size: 24),

      // سمة البطاقات
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // سمة حقول النص
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // سمة النصوص
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
      ),

      // سمة الخطوط الفاصلة
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 1,
      ),

      // سمة Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        selectedIconTheme: IconThemeData(
          color: AppColors.primaryColor,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // إعدادات أخرى
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,

      // دعم RTL
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryColor,
        selectionColor: AppColors.primaryColor.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primaryColor,
      ),
    );
  }

  /// تحديد المسار الأولي حسب حالة المصادقة
  String _getInitialRoute(AuthProvider authProvider) {
    if (authProvider.isSignedIn) {
      if (authProvider.user?.hasCompleteProfile == true) {
        return AppRoutes.home;
      } else {
        return AppRoutes.profileSetup;
      }
    }
    return AppRoutes.home; // سيتم توجيه المستخدم لتسجيل الدخول عند الحاجة
  }

  /// بناء الشاشة الرئيسية حسب حالة المصادقة
  Widget _buildHomeScreen(AuthProvider authProvider) {
    // إذا كان التطبيق يُحمّل
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // إذا كان المستخدم مسجلاً ولكن لم يكمل ملفه الشخصي
    if (authProvider.isSignedIn &&
        authProvider.user?.hasCompleteProfile == false) {
      return const ProfileSetupScreen();
    }

    // الشاشة الرئيسية
    return const HomeScreen();
  }

  /// معالج تنقل المسارات
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.profileSetup:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
          settings: settings,
        );

      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );

      case AppRoutes.productDetails:
        final productId = settings.arguments as String?;
        if (productId != null) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
            settings: settings,
          );
        }
        break;

      default:
        // صفحة غير موجودة
        return MaterialPageRoute(
          builder: (_) => const _NotFoundScreen(),
          settings: settings,
        );
    }

    return null;
  }
}

/// شاشة عدم وجود الصفحة
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحة غير موجودة')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'لم نتمكن من العثور على الصفحة المطلوبة',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
