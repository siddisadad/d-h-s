import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/security/permissions.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../providers/sales_provider.dart';

class SalesSummaryCard extends ConsumerWidget {
  final TextEditingController discountController;
  final String label;

  const SalesSummaryCard({
    super.key,
    required this.discountController,
    this.label = 'SUMMARY',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return CustomCard(
      color: context.colorScheme.primary.withValues(alpha: 0.05),
      padding: EdgeInsets.all(tokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(context, 'Subtotal', currency.format(draft.subtotal)),
          SizedBox(height: tokens.space8),
          _buildSummaryRow(context, 'Total GST', currency.format(draft.totalGst)),
          PermissionWrapper(
            requiredPermissions: const [AppPermission.applyDiscount],
            child: Padding(
              padding: EdgeInsets.only(top: tokens.space8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount',
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: context.tokens.textSecondary)),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: discountController,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        filled: true,
                        fillColor: context.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: context.colorScheme.outline),
                        ),
                      ),
                      onChanged: (val) {
                        final d = double.tryParse(val) ?? 0;
                        ref
                            .read(salesInvoiceNotifierProvider.notifier)
                            .updateDiscount(d);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
              height: tokens.space32,
              color: context.colorScheme.outline.withValues(alpha: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GRAND TOTAL', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(
                currency.format(draft.grandTotal),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.6))),
        Text(value, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
