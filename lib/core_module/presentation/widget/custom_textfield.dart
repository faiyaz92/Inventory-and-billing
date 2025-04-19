import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller; // Restored for compatibility
  final String? initialValue; // Optional for controller-less cases
  final FocusNode? focusNode;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int? maxLines; // Optional multiline support
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextInputType? keyboardType; // Optional input control
  final bool enabled; // Optional enable/disable
  final EdgeInsets? contentPadding; // Optional padding

  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.labelStyle,
    this.hintStyle,
    this.keyboardType,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Use controller if provided
      initialValue: controller == null ? initialValue : null, // Fallback to initialValue if no controller
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      enabled: enabled,
      style: defaultTextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: labelStyle ??
            defaultTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
        hintStyle: hintStyle ??
            defaultTextStyle(
              fontSize: 14,
              color: Colors.grey, // Subtle hint color
            ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        counterText: maxLength != null ? '' : null,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}