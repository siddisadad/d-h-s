import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TransactionItemWidget extends StatelessWidget {
  const TransactionItemWidget({
    super.key,
    this.amount = '12,400',
    this.balance = '45,820',
    this.date = '22 May 2024',
    this.ref = '#SI-2024-882',
    this.type = 'Sales Invoice',
    this.isDebit = true,
  });

  final String amount;
  final String balance;
  final String date;
  final String ref;
  final String type;
  final bool isDebit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: isDebit ? context.colorScheme.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.tokens.radiusMd),
                  ),
                  child: Icon(
                    isDebit ? Icons.description_rounded : Icons.payments_rounded,
                    color: isDebit ? context.colorScheme.error : AppColors.success,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$ref • $date',
                        style: context.textTheme.labelSmall!.copyWith(color: context.textTheme.bodySmall!.color),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$amount',
                      style: context.textTheme.titleSmall!.copyWith(
                        color: isDebit ? context.colorScheme.error : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bal: ₹$balance',
                      style: context.textTheme.labelSmall!.copyWith(color: context.textTheme.bodySmall!.color, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: context.colorScheme.outline, indent: 76),
        ],
      ),
    );
  }
}
