import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_strings.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 60),
              _buildLoginCard(),
              const SizedBox(height: 20),
              _buildSkipButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.store, size: 60, color: AppColors.textLight),
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'متجرك المفضل لأدوات القرطاسية',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppStrings.welcomeBack,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.pleaseSignIn,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildGoogleSignInButton(),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return CustomButton.primary(
          text: AppStrings.signInWithGoogle,
          onPressed: _isLoading || authProvider.isLoading
              ? null
              : _signInWithGoogle,
          isLoading: _isLoading || authProvider.isLoading,
          icon: const Icon(Icons.login, color: AppColors.textLight),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.dividerColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('أو', style: TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(child: Divider(color: AppColors.dividerColor)),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مميزات تسجيل الدخول:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.shopping_cart,
          title: 'حفظ السلة',
          description: 'احتفظ بمنتجاتك المختارة',
        ),
        _buildFeatureItem(
          icon: Icons.history,
          title: 'تتبع الطلبات',
          description: 'راجع طلباتك السابقة',
        ),
        _buildFeatureItem(
          icon: Icons.person,
          title: 'ملف شخصي',
          description: 'إدارة معلوماتك الشخصية',
        ),
        _buildFeatureItem(
          icon: Icons.local_shipping,
          title: 'توصيل سريع',
          description: 'معلومات التوصيل المحفوظة',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : _skipLogin,
      child: const Text(
        'تخطي وتصفح المنتجات',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();

      if (mounted && authProvider.isSignedIn) {
        // التحقق من اكتمال الملف الشخصي
        if (authProvider.user?.hasCompleteProfile == true) {
          // العودة للشاشة السابقة أو الذهاب للرئيسية
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          // الذهاب لشاشة إعداد الملف الشخصي
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الدخول: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}
