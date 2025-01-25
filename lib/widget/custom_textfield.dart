import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/utils/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final TextStyle? labelStyle; // Optional label style
  final TextStyle? hintStyle; // Optional hint style

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.textInputAction,
    this.maxLength,
    this.onChanged,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.labelStyle, // Pass custom label style if needed
    this.hintStyle, // Pass custom hint style if needed
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onFieldSubmitted,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: defaultTextStyle(), // Use global default text style
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: labelStyle ?? defaultTextStyle(fontSize: 14, fontWeight: FontWeight.normal), // Default or custom label style
        hintStyle: hintStyle ?? defaultTextStyle(fontSize: 14, color: Colors.grey), // Default or custom hint style
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
