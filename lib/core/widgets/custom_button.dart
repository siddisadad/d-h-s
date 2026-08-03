import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';

enum CustomButtonVariant { primary, secondary, outline, ghost, destructive }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    
    Color backgroundColor;
    Color textColor;
    BorderSide? borderSide;

    switch (variant) {
      case CustomButtonVariant.secondary:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        break;
      case CustomButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary, width: 1.5);
        break;
      case CustomButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        break;
      case CustomButtonVariant.destructive:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        break;
      default:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: variant == CustomButtonVariant.primary ? Colors.transparent : backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        side: borderSide ?? BorderSide.none,
      ),
    );

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: variant == CustomButtonVariant.primary ? BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
      ) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
            )
          else if (icon != null)
            Icon(icon, size: 20),
          if (loading || icon != null) const SizedBox(width: 10),
          Text(
            text,
            style: context.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );
  }
}
