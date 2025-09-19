import 'package:flutter/material.dart';
import 'package:paper_shop/core/constants/app_colors.dart';

/// زر مخصص للتطبيق مع دعم RTL والتصميم العربي
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isOutlined;
  final Color? borderColor;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50.0,
    this.borderRadius = 8.0,
    this.padding,
    this.textStyle,
    this.icon,
    this.isOutlined = false,
    this.borderColor,
    this.elevation = 2.0,
  });

  /// إنشاء زر رئيسي
  factory CustomButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double height = 50.0,
    Widget? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: AppColors.primaryColor,
      textColor: AppColors.textLight,
      width: width,
      height: height,
      icon: icon,
    );
  }

  /// إنشاء زر ثانوي
  factory CustomButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double height = 50.0,
    Widget? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: AppColors.secondaryColor,
      textColor: AppColors.textLight,
      width: width,
      height: height,
      icon: icon,
    );
  }

  /// إنشاء زر مفرغ (محاط بإطار)
  factory CustomButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    double? width,
    double height = 50.0,
    Widget? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isOutlined: true,
      borderColor: borderColor ?? AppColors.primaryColor,
      textColor: textColor ?? AppColors.primaryColor,
      backgroundColor: Colors.transparent,
      width: width,
      height: height,
      elevation: 0,
      icon: icon,
    );
  }

  /// إنشاء زر خطر (أحمر)
  factory CustomButton.danger({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double height = 50.0,
    Widget? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: AppColors.errorColor,
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
    );
  }

  /// إنشاء زر نجاح (أخضر)
  factory CustomButton.success({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double height = 50.0,
    Widget? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: AppColors.successColor,
      textColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
    );
  }

  /// إنشاء زر صغير
  factory CustomButton.small({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Color? backgroundColor,
    Color? textColor,
    Widget? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      textColor: textColor ?? AppColors.textLight,
      height: 36.0,
      borderRadius: 6.0,
      textStyle: const TextStyle(fontSize: 14),
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled = isDisabled || isLoading || onPressed == null;

    // تحديد الألوان حسب الحالة
    Color finalBackgroundColor;
    Color finalTextColor;

    if (isButtonDisabled) {
      finalBackgroundColor = isOutlined
          ? Colors.transparent
          : AppColors.buttonDisabledColor;
      finalTextColor = isOutlined
          ? AppColors.buttonDisabledColor
          : AppColors.textSecondary;
    } else {
      finalBackgroundColor = backgroundColor ?? AppColors.primaryColor;
      finalTextColor = textColor ?? AppColors.textLight;
    }

    final borderSide = isOutlined
        ? BorderSide(
            color: isButtonDisabled
                ? AppColors.buttonDisabledColor
                : (borderColor ?? AppColors.primaryColor),
            width: 1.5,
          )
        : BorderSide.none;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: finalBackgroundColor,
          foregroundColor: finalTextColor,
          elevation: isButtonDisabled ? 0 : elevation,
          shadowColor: Colors.black26,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide,
          ),
        ),
        child: _buildButtonContent(finalTextColor),
      ),
    );
  }

  /// بناء محتوى الزر
  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    // إذا كان هناك أيقونة ونص
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: _getTextStyle(textColor),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    // النص فقط
    return Text(
      text,
      style: _getTextStyle(textColor),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// الحصول على نمط النص
  TextStyle _getTextStyle(Color textColor) {
    return TextStyle(
      color: textColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: 'Cairo', // خط عربي
    ).merge(textStyle);
  }
}

/// زر أيقونة مخصص
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool isLoading;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.tooltip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize * 0.8,
                    height: iconSize * 0.8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        iconColor ?? AppColors.textPrimary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: iconColor ?? AppColors.textPrimary,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
