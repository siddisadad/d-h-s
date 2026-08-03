import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../components/base_list_item.dart';
import '../../../crm/domain/entities/contact.dart';
import '../../../crm/presentation/providers/crm_provider.dart';
import '../providers/sales_provider.dart';

class CustomerSelectorCard extends ConsumerWidget {
  const CustomerSelectorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUSTOMER DETAILS',
          style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        if (draft.selectedCustomer == null)
          CustomButton(
            text: 'Select Customer',
            variant: CustomButtonVariant.outline,
            icon: Icons.person_add_alt_1_rounded,
            fullWidth: true,
            onPressed: () => _showCustomerSelection(context, ref),
          )
        else
          CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(draft.selectedCustomer!.initials, style: TextStyle(color: context.colorScheme.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(draft.selectedCustomer!.name, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('GSTIN: ${draft.selectedCustomer!.gstin}', style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showCustomerSelection(context, ref),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: context.colorScheme.error),
                  onPressed: () => ref.read(salesInvoiceNotifierProvider.notifier).setSelectedCustomer(null),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showCustomerSelection(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CustomerSelectionSheet(),
    );
  }
}

class _CustomerSelectionSheet extends ConsumerWidget {
  const _CustomerSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));
    final tokens = context.tokens;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.space24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SELECT CUSTOMER', style: context.textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final c = list[index];
                  return BaseListItem(
                    title: c.name,
                    subtitle: 'GSTIN: ${c.gstin} • ${c.location}',
                    leading: CircleAvatar(
                      backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(c.initials, style: TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    showDivider: index < list.length - 1,
                    onTap: () {
                      ref.read(salesInvoiceNotifierProvider.notifier).setSelectedCustomer(c);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
