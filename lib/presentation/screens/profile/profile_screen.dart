import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';

/// صفحة الملف الشخصي
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isSignedIn) {
            return _buildSignInPrompt();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(authProvider),
                const SizedBox(height: 16),
                _buildProfileDetails(authProvider),
                const SizedBox(height: 16),
                _buildMenuOptions(),
                const SizedBox(height: 24),
                _buildSignOutButton(authProvider),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'سجل دخولك لعرض ملفك الشخصي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'احصل على تجربة شخصية مع تتبع الطلبات والمفضلة',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton.primary(
              text: 'تسجيل الدخول',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final user = authProvider.user;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundColor,
                border: Border.all(color: AppColors.textLight, width: 3),
              ),
              child: user?.profileImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        user!.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primaryColor,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryColor,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'مستخدم',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  user?.hasCompleteProfile == true
                      ? Icons.check_circle
                      : Icons.warning,
                  color: user?.hasCompleteProfile == true
                      ? Colors.green
                      : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  user?.hasCompleteProfile == true
                      ? 'الملف الشخصي مكتمل'
                      : 'الملف الشخصي غير مكتمل',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(AuthProvider authProvider) {
    final user = authProvider.user;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المعلومات الشخصية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.profileSetup);
                  },
                  icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.person,
              title: 'الاسم',
              value: user?.displayName ?? 'غير محدد',
            ),
            _buildDetailRow(
              icon: Icons.phone,
              title: 'رقم الهاتف',
              value: user?.phoneNumber ?? 'غير محدد',
            ),
            _buildDetailRow(
              icon: Icons.location_on,
              title: 'العنوان',
              value: user?.address ?? 'غير محدد',
              maxLines: 2,
            ),
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'تاريخ التسجيل',
              value: user?.createdAt != null
                  ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                  : 'غير محدد',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 1,
    bool isEditable = false,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isEditable && onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit,
                color: AppColors.primaryColor,
                size: 20,
              ),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.contact_support,
            title: 'اتصل بنا',
            onTap: _showContactDialog,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.privacy_tip,
            title: 'سياسة الخصوصية',
            onTap: _showPrivacyPolicy,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.description,
            title: 'الشروط والأحكام',
            onTap: _showTermsAndConditions,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomButton.secondary(
        text: 'تسجيل الخروج',
        onPressed: _isLoading || authProvider.isLoading ? null : _signOut,
        isLoading: _isLoading || authProvider.isLoading,
        icon: const Icon(Icons.logout, color: AppColors.errorColor),
      ),
    );
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.signOut();

        if (mounted && success) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (mounted && authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ في تسجيل الخروج: ${e.toString()}'),
              backgroundColor: AppColors.errorColor,
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
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اتصل بنا'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يمكنك التواصل معنا من خلال:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primaryColor, size: 20),
                SizedBox(width: 8),
                Text('0501234567'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, color: AppColors.primaryColor, size: 20),
                SizedBox(width: 8),
                Text('info@papershop.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(child: Text('بغداد الكرادة')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'نحن في متجر الأوراق نلتزم بحماية خصوصيتك. '
            'نجمع المعلومات الضرورية فقط لتقديم خدماتنا، ولا نشارك '
            'معلوماتك الشخصية مع أطراف ثالثة دون موافقتك الصريحة.\n\n'
            'المعلومات التي نجمعها:\n'
            '• الاسم والبريد الإلكتروني\n'
            '• رقم الهاتف والعنوان\n'
            '• بيانات الطلبات والمشتريات\n\n'
            'نستخدم هذه المعلومات لـ:\n'
            '• معالجة الطلبات\n'
            '• التواصل معك\n'
            '• تحسين خدماتنا',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الشروط والأحكام'),
        content: const SingleChildScrollView(
          child: Text(
            'شروط وأحكام استخدام متجر الأوراق:\n\n'
            '1. القبول بالشروط:\n'
            'باستخدامك لهذا التطبيق، فإنك توافق على هذه الشروط والأحكام.\n\n'
            '2. استخدام الخدمة:\n'
            '• يجب استخدام التطبيق للأغراض المشروعة فقط\n'
            '• لا يجوز تقديم معلومات كاذبة أو مضللة\n'
            '• يحظر إساءة استخدام النظام\n\n'
            '3. الطلبات والمدفوعات:\n'
            '• الأسعار شاملة الضريبة\n'
            '• يمكن إلغاء الطلب قبل التأكيد\n'
            '• المدفوعات آمنة ومحمية\n\n'
            '4. التوصيل:\n'
            '• نسعى لتوصيل الطلبات في الوقت المحدد\n'
            '• رسوم التوصيل قد تختلف حسب المنطقة\n\n'
            '5. الإرجاع والاستبدال:\n'
            '• يمكن إرجاع المنتجات خلال 7 أيام\n'
            '• يجب أن تكون المنتجات في حالتها الأصلية',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
