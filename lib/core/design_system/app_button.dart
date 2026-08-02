import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool loading;
  final bool disabled;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.disabled = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final tokens = context.tokens;
    
    Color backgroundColor;
    Color textColor;
    double borderRadius;
    double paddingHorizontal;
    double paddingVertical;
    double fontSize;
    List<BoxShadow>? shadows;

    // Variant Colors
    switch (variant) {
      case AppButtonVariant.secondary:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        shadows = [tokens.shadowXs];
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.onSurface;
        shadows = null;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        shadows = null;
        break;
      case AppButtonVariant.destructive:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        shadows = [tokens.shadowXs];
        break;
      default:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        shadows = [tokens.shadowXs];
    }

    // Size Configurations
    switch (size) {
      case AppButtonSize.small:
        borderRadius = tokens.radiusSm;
        paddingHorizontal = tokens.spaceMd;
        paddingVertical = tokens.spaceSm;
        fontSize = 12.0;
        break;
      case AppButtonSize.large:
        borderRadius = tokens.radiusLg;
        paddingHorizontal = tokens.spaceXl;
        paddingVertical = tokens.spaceMd;
        fontSize = 16.0;
        break;
      default:
        borderRadius = tokens.radiusMd;
        paddingHorizontal = tokens.spaceLg;
        paddingVertical = tokens.spaceMd;
        fontSize = 14.0;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: fontSize + 2,
              height: fontSize + 2,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
          ),
        if (icon != null && !loading) ...[icon!, const SizedBox(width: 8)],
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon!],
      ],
    );

    if (fullWidth) {
      content = SizedBox(width: double.infinity, child: Center(child: content));
    }

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows,
        ),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: disabled || loading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal,
                vertical: paddingVertical,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: variant == AppButtonVariant.outline
                    ? Border.all(color: theme.dividerColor, width: 1.0)
                    : null,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
