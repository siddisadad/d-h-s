import '../../core/design_system/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class PurchaseTransactionItemWidget extends StatelessWidget {
  final String amount;
  final String date;
  final String sku;
  final String supplier;
  final String status;

  const PurchaseTransactionItemWidget({
    super.key,
    required this.amount,
    required this.date,
    required this.sku,
    required this.supplier,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isReceived = status.toLowerCase() == 'received';

    return CustomCard(
      padding: EdgeInsets.all(tokens.space16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 24),
          ),
          SizedBox(width: tokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'SKU: $sku • $amount',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isReceived ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: (isReceived ? AppColors.success : AppColors.warning).withValues(alpha: 0.2)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isReceived ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: context.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
