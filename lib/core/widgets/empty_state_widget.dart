import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(tokens.space24),
              decoration: BoxDecoration(
                color: context.onSurfaceColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: context.onSurfaceColor.withValues(alpha: 0.38),
              ),
            ),
            SizedBox(height: tokens.space24),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.space8),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(color: context.onSurfaceVariantColor),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: tokens.space32),
              CustomButton(
                text: actionLabel!,
                onPressed: onAction,
                variant: CustomButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
