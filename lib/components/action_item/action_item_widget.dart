import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/theme/app_theme.dart';

class ActionItemWidget extends StatelessWidget {
  final String icon;
  final String label;
  final String target;
  final Color tone;

  const ActionItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.target,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return InkWell(
      onTap: () => context.go(target), // Assumes target is a path now
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tone.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [tokens.shadowXs],
              ),
              child: Icon(_getIconData(icon), color: tone, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'add_shopping_cart_rounded': return Icons.add_shopping_cart_rounded;
      case 'local_shipping_rounded': return Icons.local_shipping_rounded;
      case 'barcode_scanner_rounded': return Icons.qr_code_scanner_rounded;
      case 'assessment_rounded': return Icons.assessment_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}
