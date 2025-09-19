import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_strings.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/providers/user_provider.dart';
import 'package:paper_shop/presentation/widgets/custom_text_field.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';
import 'package:paper_shop/core/utils/validators.dart';

/// شاشة إعداد الملف الشخصي
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileSetup),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPersonalInfoCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 16),
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
          child: const Icon(
            Icons.person_add,
            size: 40,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'إعداد ملفك الشخصي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'أكمل معلوماتك الشخصية لتتمكن من إتمام عمليات الشراء',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  AppStrings.personalInfo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _nameController,
              label: AppStrings.fullName,
              hint: 'أدخل اسمك الكامل',
              prefixIcon: const Icon(Icons.person_outline),
              validator: Validators.validateFullName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: AppStrings.phoneNumber,
              hint: AppStrings.phoneHint,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhoneNumber,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField.multiline(
              controller: _addressController,
              label: AppStrings.address,
              hint: AppStrings.addressHint,
              validator: Validators.validateAddress,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildEmailDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailDisplay() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authProvider.user?.email ?? 'غير محدد',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified,
                color: AppColors.successColor,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return CustomButton.primary(
          text: AppStrings.save,
          onPressed: _isLoading || userProvider.isLoading ? null : _saveProfile,
          isLoading: _isLoading || userProvider.isLoading,
        );
      },
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : _skipSetup,
      child: const Text(
        'تخطي الآن وإكمال لاحقاً',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      if (authProvider.user == null) {
        throw Exception('المستخدم غير مسجل');
      }

      await userProvider.updateUser(
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.profileUpdated),
            backgroundColor: AppColors.successColor,
          ),
        );

        // العودة للشاشة الرئيسية
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في حفظ الملف الشخصي: ${e.toString()}'),
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

  void _skipSetup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تخطي الإعداد'),
          content: const Text(
            'يمكنك إكمال المعلومات الشخصية لاحقاً من خلال الملف الشخصي.\n'
            'ملاحظة: ستحتاج لإكمال هذه المعلومات قبل إتمام أي عملية شراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
              },
              child: const Text('متابعة'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
