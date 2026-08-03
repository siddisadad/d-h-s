import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/sales_provider.dart';
import '../../../crm/presentation/providers/crm_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../crm/domain/entities/contact.dart';
import '../../domain/entities/invoice_item.dart';
import '../../../../components/base_list_item.dart';
import '../../../inventory/presentation/screens/barcode_scanner_screen.dart';

class CustomerSelector extends ConsumerWidget {
  const CustomerSelector({super.key});

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
            onPressed: () => _showCustomerSelection(context),
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
                  onPressed: () => _showCustomerSelection(context),
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

  void _showCustomerSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CustomerSelectionSheet(),
    );
  }
}

class InvoiceItemsList extends ConsumerWidget {
  const InvoiceItemsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INVOICE ITEMS',
              style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BarcodeScannerScreen(
                        onResult: (p) {
                          ref.read(salesInvoiceNotifierProvider.notifier).addItem(InvoiceItem(
                            name: p.name,
                            sku: p.sku,
                            price: p.price,
                            qty: 1,
                            gstRate: 18,
                          ));
                        },
                      ),
                    ),
                  ),
                  icon: Icon(Icons.qr_code_scanner_rounded, color: context.colorScheme.primary),
                  tooltip: 'Scan Barcode',
                ),
                TextButton.icon(
                  onPressed: () => _showProductSelection(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add Item'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (draft.items.isEmpty)
          CustomCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: context.onSurfaceColor.withValues(alpha: 0.38)),
                  const SizedBox(height: 12),
                  const Text('No items added yet'),
                ],
              ),
            ),
          )
        else
          ...draft.items.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(context, ref, entry.value, entry.key),
          )),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, InvoiceItem item, int index) {
    final tokens = context.tokens;
    return CustomCard(
      padding: EdgeInsets.all(tokens.space12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '₹${item.price.toStringAsFixed(2)} x ${item.qty}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.subtotal.toStringAsFixed(2)}',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: context.colorScheme.primary),
              ),
              Text(
                'GST (${item.gstRate}%)',
                style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: context.colorScheme.error, size: 20),
            onPressed: () => ref.read(salesInvoiceNotifierProvider.notifier).removeItem(index),
          ),
        ],
      ),
    );
  }

  void _showProductSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ProductSelectionSheet(),
    );
  }
}

class InvoiceSummarySection extends ConsumerWidget {
  final TextEditingController discountController;
  const InvoiceSummarySection({super.key, required this.discountController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return CustomCard(
      color: context.colorScheme.primary.withValues(alpha: 0.05),
      padding: EdgeInsets.all(tokens.space20),
      child: Column(
        children: [
          _buildSummaryRow(context, 'Subtotal', currency.format(draft.subtotal)),
          SizedBox(height: tokens.space8),
          _buildSummaryRow(context, 'Total GST', currency.format(draft.totalGst)),
          SizedBox(height: tokens.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount', style: context.textTheme.bodyMedium?.copyWith(color: context.tokens.textSecondary)),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: discountController,
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    filled: true,
                    fillColor: context.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: context.colorScheme.outline),
                    ),
                  ),
                  onChanged: (val) {
                    final d = double.tryParse(val) ?? 0;
                    ref.read(salesInvoiceNotifierProvider.notifier).updateDiscount(d);
                  },
                ),
              ),
            ],
          ),
          Divider(height: tokens.space32, color: context.colorScheme.outline.withValues(alpha: 0.5)),
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

class _ProductSelectionSheet extends ConsumerWidget {
  const _ProductSelectionSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryNotifierProvider);
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
                Text('ADD PRODUCT', style: context.textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  return BaseListItem(
                    title: p.name,
                    subtitle: 'SKU: ${p.sku} • Stock: ${p.stock}',
                    trailing: Text(
                      '₹${p.price.toStringAsFixed(2)}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    showDivider: index < list.length - 1,
                    onTap: () {
                      ref.read(salesInvoiceNotifierProvider.notifier).addItem(InvoiceItem(
                        name: p.name,
                        sku: p.sku,
                        price: p.price,
                        qty: 1,
                        gstRate: 18,
                      ));
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
