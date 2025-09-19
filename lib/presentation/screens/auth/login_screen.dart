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
  bool _showEmailLogin = false;
  bool _isSignUpMode = false;

  // Controllers for email/password form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

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
            Text(
              _showEmailLogin 
                ? (_isSignUpMode ? 'إنشاء حساب جديد' : 'تسجيل الدخول')
                : AppStrings.welcomeBack,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _showEmailLogin 
                ? (_isSignUpMode ? 'أدخل بياناتك لإنشاء حساب جديد' : 'أدخل بياناتك لتسجيل الدخول')
                : AppStrings.pleaseSignIn,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            if (!_showEmailLogin) ...[
              _buildGoogleSignInButton(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildEmailLoginButton(),
              const SizedBox(height: 16),
              _buildFeaturesList(),
            ] else ...[
              _buildEmailForm(),
              const SizedBox(height: 16),
              _buildBackToOptionsButton(),
            ],
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

  Widget _buildEmailLoginButton() {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () {
        setState(() {
          _showEmailLogin = true;
          _isSignUpMode = false;
        });
      },
      icon: const Icon(Icons.email, color: AppColors.primaryColor),
      label: const Text(
        'تسجيل الدخول بالبريد الإلكتروني',
        style: TextStyle(color: AppColors.primaryColor),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSignUpMode) ...[
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              if (_isSignUpMode && value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          
          if (_isSignUpMode) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى تأكيد كلمة المرور';
                }
                if (value != _passwordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
          ],
          
          const SizedBox(height: 24),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton.primary(
                text: _isSignUpMode ? 'إنشاء حساب' : 'تسجيل الدخول',
                onPressed: _isLoading || authProvider.isLoading
                    ? null
                    : _submitEmailForm,
                isLoading: _isLoading || authProvider.isLoading,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isSignUpMode ? 'لديك حساب؟ ' : 'ليس لديك حساب؟ '),
              TextButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isSignUpMode = !_isSignUpMode;
                    _clearForm();
                  });
                },
                child: Text(_isSignUpMode ? 'تسجيل الدخول' : 'إنشاء حساب جديد'),
              ),
            ],
          ),
          
          if (!_isSignUpMode) ...[
            TextButton(
              onPressed: _isLoading ? null : _showForgotPasswordDialog,
              child: const Text('نسيت كلمة المرور؟'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackToOptionsButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : () {
        setState(() {
          _showEmailLogin = false;
          _isSignUpMode = false;
          _clearForm();
        });
      },
      icon: const Icon(Icons.arrow_back),
      label: const Text('العودة إلى خيارات تسجيل الدخول'),
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

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _displayNameController.clear();
  }

  Future<void> _submitEmailForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      bool success = false;

      if (_isSignUpMode) {
        success = await authProvider.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
      } else {
        success = await authProvider.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted && success) {
        // التحقق من اكتمال الملف الشخصي
        if (authProvider.user?.hasCompleteProfile == true) {
          // العودة للشاشة السابقة أو الذهاب للرئيسية
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          // الذهاب لشاشة إعداد الملف الشخصي
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        }
      } else if (mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppColors.errorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
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

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إعادة تعيين كلمة المرور'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('أدخل بريدك الإلكتروني لإرسال رابط إعادة تعيين كلمة المرور'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('إرسال'),
              onPressed: () async {
                if (emailController.text.trim().isNotEmpty) {
                  try {
                    final authProvider = context.read<AuthProvider>();
                    final success = await authProvider.sendPasswordResetEmail(emailController.text.trim());
                    
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success 
                            ? 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'
                            : 'فشل في إرسال رابط إعادة تعيين كلمة المرور'),
                          backgroundColor: success ? Colors.green : AppColors.errorColor,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ: ${e.toString()}'),
                          backgroundColor: AppColors.errorColor,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
