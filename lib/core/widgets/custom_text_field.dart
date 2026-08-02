import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface.withValues(alpha: enabled ? 0.8 : 0.4),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: context.textTheme.bodyLarge?.copyWith(
            color: enabled ? null : context.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: context.colorScheme.primary.withValues(alpha: enabled ? 1.0 : 0.5)) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: context.colorScheme.secondary.withValues(alpha: enabled ? 1.0 : 0.5)) : null,
            filled: !enabled,
            fillColor: enabled ? null : AppColors.border.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
