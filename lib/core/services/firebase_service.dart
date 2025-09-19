import 'package:firebase_core/firebase_core.dart';
import 'package:paper_shop/firebase_options.dart';

/// خدمة Firebase الأساسية
class FirebaseService {
  static FirebaseService? _instance;

  FirebaseService._();

  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  bool _isInitialized = false;

  /// تهيئة Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// إعادة تهيئة Firebase (في حالة وجود مشاكل)
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }
}
