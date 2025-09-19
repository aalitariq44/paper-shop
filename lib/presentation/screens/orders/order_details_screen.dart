import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_shop/core/constants/app_colors.dart';
import 'package:paper_shop/core/constants/app_routes.dart';
import 'package:paper_shop/data/models/order_model.dart';
import 'package:paper_shop/presentation/providers/order_provider.dart';

/// صفحة تفاصيل الطلب
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetails();
    });
  }

  void _loadOrderDetails() async {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = arguments?[RouteArguments.orderId] as String?;

    if (orderId == null) {
      setState(() {
        _error = 'معرف الطلب غير صحيح';
        _isLoading = false;
      });
      return;
    }

    try {
      final order = await context.read<OrderProvider>().getOrderById(orderId);
      setState(() {
        _order = order;
        _isLoading = false;
        _error = order == null ? 'لم يتم العثور على الطلب' : null;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل في تحميل تفاصيل الطلب: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_order?.orderNumber ?? 'تفاصيل الطلب'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textLight,
        actions: [
          if (_order?.canBeCancelled == true)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => _showCancelOrderDialog(),
              tooltip: 'إلغاء الطلب',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    if (_order == null) {
      return _buildNotFound();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOrderHeader(),
          _buildOrderStatus(),
          _buildOrderItems(),
          _buildDeliveryInfo(),
          _buildOrderSummary(),
          if (_order!.notes?.isNotEmpty == true) _buildNotes(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'الطلب غير موجود',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _order!.orderNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              _buildStatusChip(_order!.status),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'تاريخ الطلب',
            '${_order!.formattedCreatedDate} - ${_order!.formattedCreatedTime}',
          ),
          if (_order!.updatedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.update,
              'آخر تحديث',
              '${_order!.updatedAt!.day}/${_order!.updatedAt!.month}/${_order!.updatedAt!.year}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حالة الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
      OrderStatus.completed,
    ];

    int currentIndex = statuses.indexOf(_order!.status);
    if (currentIndex == -1) {
      // إذا كان الطلب ملغياً أو مرفوضاً
      return Center(child: _buildStatusChip(_order!.status));
    }

    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = index <= currentIndex;
        final isActive = index == currentIndex;

        return Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primaryColor
                    : AppColors.dividerColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryColor
                      : AppColors.dividerColor,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 12,
                color: isCompleted ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عناصر الطلب (${_order!.items.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              return Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: item.product.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.inventory,
                                  color: AppColors.primaryColor,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.inventory,
                            color: AppColors.primaryColor,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.unitPrice.toStringAsFixed(0)} د.ع × ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(0)} د.ع',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات التوصيل',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'المستلم', _order!.userName),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'رقم الهاتف', _order!.userPhone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'العنوان', _order!.userAddress),
          if (_order!.trackingNumber != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.local_shipping,
              'رقم التتبع',
              _order!.trackingNumber!,
            ),
          ],
          if (_order!.deliveryDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.schedule,
              'تاريخ التوصيل',
              '${_order!.deliveryDate!.day}/${_order!.deliveryDate!.month}/${_order!.deliveryDate!.year}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الفاتورة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('المجموع الفرعي', _order!.formattedSubtotal),
          const SizedBox(height: 8),
          _buildSummaryRow('أجرة التوصيل', _order!.formattedDeliveryFee),
          const Divider(height: 24, thickness: 2),
          _buildSummaryRow(
            'الإجمالي الكلي',
            _order!.formattedTotal,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملاحظات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _order!.notes!,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primaryColor : AppColors.textPrimary,
          ),
        ),
      ],
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

  void _showCancelOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إلغاء الطلب'),
          content: Text(
            'هل تريد إلغاء الطلب ${_order!.orderNumber}؟\n\nلن يمكنك التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () => _cancelOrder(),
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

  Future<void> _cancelOrder() async {
    Navigator.pop(context); // إغلاق الحوار

    try {
      await context.read<OrderProvider>().cancelOrder(
        _order!.id,
        'تم الإلغاء من قبل المستخدم',
      );

      setState(() {
        _order = _order!.copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      });

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
}
