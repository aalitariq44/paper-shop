import 'package:flutter/material.dart';
import 'package:paper_shop/core/constants/app_colors.dart';

/// ويدجت التحميل المخصص للتطبيق
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 50.0,
    this.strokeWidth = 4.0,
  });

  /// ويدجت تحميل صغير
  factory LoadingWidget.small({Color? color, String? message}) {
    return LoadingWidget(
      color: color,
      message: message,
      size: 24.0,
      strokeWidth: 2.0,
    );
  }

  /// ويدجت تحميل كبير مع رسالة
  factory LoadingWidget.large({Color? color, String? message}) {
    return LoadingWidget(
      color: color,
      message: message ?? 'جاري التحميل...',
      size: 60.0,
      strokeWidth: 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// ويدجت تحميل مع شريط تقدم
class ProgressLoadingWidget extends StatelessWidget {
  final double? progress;
  final String? message;
  final Color? color;

  const ProgressLoadingWidget({
    super.key,
    this.progress,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          if (progress != null)
            Text(
              '${(progress! * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

/// ويدجت تحميل مخصص بتصميم دائري متقدم
class CustomCircularLoading extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;
  final String? message;

  const CustomCircularLoading({
    super.key,
    this.color,
    this.size = 50.0,
    this.duration = const Duration(seconds: 2),
    this.message,
  });

  @override
  State<CustomCircularLoading> createState() => _CustomCircularLoadingState();
}

class _CustomCircularLoadingState extends State<CustomCircularLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CircularLoadingPainter(
                    progress: _controller.value,
                    color: widget.color ?? AppColors.primaryColor,
                  ),
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// رسام التحميل الدائري المخصص
class _CircularLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularLoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // رسم الخلفية
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 2, backgroundPaint);

    // رسم التقدم
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ويدجت تحميل الشبكة مع رسالة خطأ
class NetworkLoadingWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final String? retryButtonText;

  const NetworkLoadingWidget({
    super.key,
    required this.isLoading,
    this.error,
    this.onRetry,
    this.loadingMessage,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidget.large(message: loadingMessage ?? 'جاري التحميل...');
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text(
              error!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  retryButtonText ?? 'إعادة المحاولة',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// ويدجت تحميل صفحة كاملة مع خلفية شفافة
class FullScreenLoadingWidget extends StatelessWidget {
  final String? message;
  final Color backgroundColor;
  final Color? indicatorColor;

  const FullScreenLoadingWidget({
    super.key,
    this.message,
    this.backgroundColor = Colors.black54,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LoadingWidget.large(
            message: message ?? 'جاري التحميل...',
            color: indicatorColor,
          ),
        ),
      ),
    );
  }
}

/// مؤشر تحميل صغير للأزرار
class ButtonLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoadingIndicator({super.key, this.color, this.size = 16.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
      ),
    );
  }
}
