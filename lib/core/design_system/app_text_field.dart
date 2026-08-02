import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helper;
  final String? initialValue;
  final TextEditingController? controller;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isError;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextAlign textAlign;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.initialValue,
    this.controller,
    this.leadingIcon,
    this.trailingIcon,
    this.isError = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label!,
              style: textTheme.labelMedium?.copyWith(
                color: isError ? colorScheme.error : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textAlign: textAlign,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.labelMedium?.copyWith(color: theme.hintColor),
            prefixIcon: leadingIcon,
            suffixIcon: trailingIcon,
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              borderSide: BorderSide(
                color: isError ? colorScheme.error : theme.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              borderSide: BorderSide(
                color: isError ? colorScheme.error : colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
          ),
        ),
        if (helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              helper!,
              style: textTheme.bodySmall?.copyWith(
                color: isError ? colorScheme.error : textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
