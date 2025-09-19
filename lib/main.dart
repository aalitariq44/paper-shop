import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_shop/app.dart';
import 'package:paper_shop/core/services/firebase_service.dart';
import 'package:paper_shop/core/services/local_storage_service.dart';

/// نقطة دخول التطبيق الرئيسية
void main() async {
  // التأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تحديد اتجاه الشاشة (عمودي فقط)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // إعداد شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    // تهيئة Firebase
    print('🔥 تهيئة Firebase...');
    await FirebaseService.instance.initialize();

    // تهيئة التخزين المحلي
    print('💾 تهيئة التخزين المحلي...');
    await LocalStorageService.instance.initialize();

    print('✅ تم تهيئة جميع الخدمات بنجاح');

    // تشغيل التطبيق
    runApp(const PaperShopApp());
  } catch (e, stackTrace) {
    print('❌ خطأ في تهيئة التطبيق: $e');
    print('Stack trace: $stackTrace');

    // تشغيل التطبيق مع شاشة خطأ
    runApp(const ErrorApp());
  }
}

/// تطبيق الخطأ في حالة فشل التهيئة
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خطأ في التطبيق',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 24),
                Text(
                  'خطأ في تشغيل التطبيق',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'حدث خطأ في تهيئة التطبيق.\nيرجى إعادة تشغيل التطبيق.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'إذا استمر الخطأ، يرجى التواصل مع الدعم الفني.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
