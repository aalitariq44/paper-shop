import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/data/models/order_model.dart';
import 'package:paper_shop/presentation/providers/order_provider.dart';
import 'package:paper_shop/presentation/providers/auth_provider.dart';
import 'package:paper_shop/presentation/widgets/custom_button.dart';

/// صفحة طلباتي
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isSignedIn) {
        context.read<OrderProvider>().loadOrders(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
          indicatorColor: AppColors.textLight,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'في الانتظار'),
            Tab(text: 'مكتملة'),
            Tab(text: 'ملغية'),
            Tab(text: 'مرفوضة'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshOrders(),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Consumer2<OrderProvider, AuthProvider>(
        builder: (context, orderProvider, authProvider, child) {
          if (!authProvider.isSignedIn) {
            return _buildNotSignedIn();
          }

          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
            return _buildError(orderProvider.error!, () => _refreshOrders());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(orderProvider.orders),
              _buildOrdersList(orderProvider.pendingOrders),
              _buildOrdersList(orderProvider.completedOrders),
              _buildOrdersList(orderProvider.cancelledOrders),
              _buildOrdersList(orderProvider.rejectedOrders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotSignedIn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'يرجى تسجيل الدخول',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'سجل دخولك لعرض طلباتك',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            CustomButton.primary(
              text: 'تسجيل الدخول',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton.primary(
              text: 'إعادة المحاولة',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return _buildEmptyOrders();
    }

    return RefreshIndicator(
      onRefresh: () => _refreshOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد طلبات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم تقم بأي طلبات حتى الآن',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            CustomButton.primary(
              text: 'ابدأ التسوق',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
              icon: const Icon(Icons.shopping_cart, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم الطلب والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),

              const SizedBox(height: 12),

              // تاريخ ووقت الطلب
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.formattedCreatedDate} - ${order.formattedCreatedTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // عدد العناصر والمبلغ
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.totalItems} عنصر',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.formattedTotal,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // أزرار العمليات
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showOrderDetails(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: const BorderSide(color: AppColors.primaryColor),
                      ),
                      child: const Text('عرض التفاصيل'),
                    ),
                  ),
                  if (order.canBeCancelled) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showCancelOrderDialog(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                          foregroundColor: AppColors.textLight,
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(status.colorCode).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(status.colorCode).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(status.colorCode),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    Navigator.pushNamed(
      context,
      AppRoutes.orderDetails,
      arguments: {RouteArguments.orderId: order.id},
    );
  }

  void _showCancelOrderDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إلغاء الطلب'),
          content: Text(
            'هل تريد إلغاء الطلب ${order.orderNumber}؟\n\nلن يمكنك التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () => _cancelOrder(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorColor,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text('إلغاء الطلب'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    Navigator.pop(context); // إغلاق الحوار

    try {
      await context.read<OrderProvider>().cancelOrder(
        order.id,
        'تم الإلغاء من قبل المستخدم',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الطلب بنجاح'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إلغاء الطلب: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Future<void> _refreshOrders() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isSignedIn) {
      await context.read<OrderProvider>().refreshOrders(authProvider.user!.uid);
    }
  }
}
