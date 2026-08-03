import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../components/base_list_item.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../inventory/presentation/screens/barcode_scanner_screen.dart';
import '../../domain/entities/invoice_item.dart';
import '../providers/sales_provider.dart';

class InvoiceItemList extends ConsumerWidget {
  final String emptyMessage;
  const InvoiceItemList({
    super.key,
    this.emptyMessage = 'No items added to this draft',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ITEMS',
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
                  Text(emptyMessage),
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
