import '../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BaseListItem extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;
  final Color? leadingBackgroundColor;
  final IconData? leadingIcon;
  final Color? leadingIconColor;

  const BaseListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.padding,
    this.leadingBackgroundColor,
    this.leadingIcon,
    this.leadingIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && leadingIcon != null) {
      leadingWidget = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: leadingBackgroundColor ?? context.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        child: Icon(
          leadingIcon,
          color: leadingIconColor ?? context.colorScheme.primary,
          size: 20,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: padding ?? EdgeInsets.all(tokens.space16),
            child: Row(
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget,
                  SizedBox(width: tokens.space16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: tokens.space16),
                  trailing!,
                ],
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: context.colorScheme.outline.withValues(alpha: 0.5),
              indent: leadingWidget != null ? 76 : tokens.space16,
            ),
        ],
      ),
    );
  }
}
