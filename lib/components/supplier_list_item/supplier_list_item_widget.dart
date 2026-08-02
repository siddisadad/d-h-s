import '../../core/design_system/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SupplierListItemWidget extends StatefulWidget {
  const SupplierListItemWidget({
    super.key,
    this.balance = '₹4,50,000',
    this.contact = '+91 98765 43210',
    this.gstin = '27AAACA1234A1Z5',
    this.initials = 'AS',
    this.name = 'Adarsh Steel Industries',
  });

  final String balance;
  final String contact;
  final String gstin;
  final String initials;
  final String name;

  @override
  State<SupplierListItemWidget> createState() => _SupplierListItemWidgetState();
}

class _SupplierListItemWidgetState extends State<SupplierListItemWidget> {
  bool _isLedgerLoading = false;
  bool _isPayableLoading = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          shape: BoxShape.rectangle,
          border: Border.all(
            color: context.colorScheme.outline,
            width: 1.0,
          ),
          boxShadow: [tokens.shadowSm],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52.0,
                    height: 52.0,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Text(
                      widget.initials,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium!.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GSTIN: ${widget.gstin}',
                          style: context.textTheme.labelSmall!.copyWith(
                            color: context.textTheme.bodySmall!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Text(
                      'Active',
                      style: context.textTheme.labelSmall!.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding',
                        style: context.textTheme.labelSmall!.copyWith(color: context.textTheme.bodySmall!.color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.balance,
                        style: context.textTheme.titleMedium!.copyWith(
                          color: context.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Contact',
                        style: context.textTheme.labelSmall!.copyWith(color: context.textTheme.bodySmall!.color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.contact,
                        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Ledger',
                      variant: CustomButtonVariant.outline,
                      icon: Icons.account_balance_wallet_rounded,
                      loading: _isLedgerLoading,
                      onPressed: () async {
                        setState(() => _isLedgerLoading = true);
                        await Future.delayed(const Duration(seconds: 1));
                        if (mounted) {
                          setState(() => _isLedgerLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening Ledger for ${widget.name}...')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Payable',
                      variant: CustomButtonVariant.primary,
                      icon: Icons.payments_rounded,
                      loading: _isPayableLoading,
                      onPressed: () async {
                        setState(() => _isPayableLoading = true);
                        await Future.delayed(const Duration(seconds: 1));
                        if (mounted) {
                          setState(() => _isPayableLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Payable for ${widget.name}...')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
