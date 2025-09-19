import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_shop/core/constants/app_colors.dart';

/// حقل نص مخصص للتطبيق مع دعم RTL والتصميم العربي
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextAlign textAlign;
  final double borderRadius;
  final Color? fillColor;
  final bool filled;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.borderRadius = 8.0,
    this.fillColor,
    this.filled = true,
    this.contentPadding,
  }) : super(key: key);

  /// إنشاء حقل كلمة مرور
  factory CustomTextField.password({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      label: label ?? 'كلمة المرور',
      hint: hint ?? 'أدخل كلمة المرور',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
    );
  }

  /// إنشاء حقل البريد الإلكتروني
  factory CustomTextField.email({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      label: label ?? 'البريد الإلكتروني',
      hint: hint ?? 'أدخل البريد الإلكتروني',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }

  /// إنشاء حقل الهاتف
  factory CustomTextField.phone({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      label: label ?? 'رقم الهاتف',
      hint: hint ?? 'أدخل رقم الهاتف',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  /// إنشاء حقل البحث
  factory CustomTextField.search({
    Key? key,
    String? hint,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    void Function()? onClear,
    bool enabled = true,
    bool showClearButton = true,
  }) {
    return CustomTextField(
      key: key,
      hint: hint ?? 'ابحث عن المنتجات...',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      keyboardType: TextInputType.text,
      prefixIcon: const Icon(Icons.search),
      suffixIcon:
          showClearButton && controller != null && controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                onClear?.call();
              },
            )
          : null,
      borderRadius: 25.0,
      textInputAction: TextInputAction.search,
    );
  }

  /// إنشاء حقل متعدد الأسطر
  factory CustomTextField.multiline({
    Key? key,
    String? label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 4,
    int minLines = 2,
    int? maxLength,
    bool enabled = true,
  }) {
    return CustomTextField(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.multiline,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: TextAlign.start,
    );
  }

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          textAlign: widget.textAlign,
          textDirection: _getTextDirection(),
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontFamily: 'Cairo',
          ),
          decoration: _buildInputDecoration(),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ],
    );
  }

  /// بناء تصميم حقل الإدخال
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 16,
        fontFamily: 'Cairo',
      ),
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      errorText: widget.errorText,
      errorStyle: TextStyle(
        color: AppColors.errorColor,
        fontSize: 12,
        fontFamily: 'Cairo',
      ),
      filled: widget.filled,
      fillColor:
          widget.fillColor ??
          (widget.enabled ? AppColors.surfaceColor : AppColors.backgroundColor),
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: _buildBorder(),
      enabledBorder: _buildBorder(),
      focusedBorder: _buildBorder(color: AppColors.primaryColor, width: 2.0),
      errorBorder: _buildBorder(color: AppColors.errorColor),
      focusedErrorBorder: _buildBorder(color: AppColors.errorColor, width: 2.0),
      disabledBorder: _buildBorder(color: AppColors.dividerColor),
      counterStyle: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontFamily: 'Cairo',
      ),
    );
  }

  /// بناء أيقونة السفيكس
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  /// بناء حدود حقل الإدخال
  OutlineInputBorder _buildBorder({Color? color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: color ?? AppColors.dividerColor,
        width: width,
      ),
    );
  }

  /// تحديد اتجاه النص
  TextDirection _getTextDirection() {
    // إذا كان النوع رقم أو إيميل، استخدم LTR
    if (widget.keyboardType == TextInputType.number ||
        widget.keyboardType == TextInputType.phone ||
        widget.keyboardType == TextInputType.emailAddress ||
        widget.keyboardType == TextInputType.url) {
      return TextDirection.ltr;
    }
    return TextDirection.rtl;
  }
}

/// حقل نص مع تسمية مرفقة
class LabeledTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool required;

  const LabeledTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: hint,
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }
}
