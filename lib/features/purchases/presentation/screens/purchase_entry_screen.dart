import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../crm/presentation/providers/crm_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../crm/domain/entities/contact.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/entities/purchase_order.dart';
import '../providers/purchase_provider.dart';
import '../../../inventory/presentation/screens/barcode_scanner_screen.dart';

class PurchaseEntryScreen extends ConsumerStatefulWidget {
  final Contact? prefilledSupplier;
  final List<PurchaseItem>? prefilledItems;

  const PurchaseEntryScreen({
    super.key,
    this.prefilledSupplier,
    this.prefilledItems,
  });

  @override
  ConsumerState<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends ConsumerState<PurchaseEntryScreen> {
  Contact? _selectedSupplier;
  final List<PurchaseItem> _items = [];

  @override
  void initState() {
    super.initState();
    _selectedSupplier = widget.prefilledSupplier;
    if (widget.prefilledItems != null) {
      _items.addAll(widget.prefilledItems!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('NEW PURCHASE ENTRY'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupplierSection(context),
            const SizedBox(height: 24),
            _buildItemsSection(context),
            const SizedBox(height: 24),
            _buildSummarySection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSupplierSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SUPPLIER', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        if (_selectedSupplier == null)
          CustomButton(
            text: 'Select Supplier',
            variant: CustomButtonVariant.outline,
            icon: Icons.business_rounded,
            fullWidth: true,
            onPressed: () => _showSupplierSelection(context),
          )
        else
          CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.successColor.withValues(alpha: 0.1),
                  child: Text(
                    _selectedSupplier!.initials,
                    style: TextStyle(color: context.successColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedSupplier!.name, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('GSTIN: ${_selectedSupplier!.gstin}', style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: context.colorScheme.error),
                  onPressed: () => setState(() => _selectedSupplier = null),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showSupplierSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SupplierSelectionSheet(onSelected: (s) => setState(() => _selectedSupplier = s)),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PURCHASE ITEMS', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BarcodeScannerScreen(
                        onResult: (p) => _addItemWithDialog(p.name, p.sku),
                      ),
                    ),
                  ),
                  icon: Icon(Icons.qr_code_scanner_rounded, color: context.colorScheme.primary),
                  tooltip: 'Scan Barcode',
                ),
                TextButton.icon(
                  onPressed: () => _showProductSelection(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Item'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          CustomCard(
            padding: const EdgeInsets.all(32),
            child: const Center(child: Text('No items added')),
          )
        else
          ..._items.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildItemCard(context, e.value, e.key),
          )),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, PurchaseItem item, int index) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('₹${item.costPrice.toStringAsFixed(2)} x ${item.qty}', style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Text('₹${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colorScheme.error),
            onPressed: () => setState(() => _items.removeAt(index)),
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
      builder: (context) => _ProductSelectionSheet(onSelected: (p) => _addItemWithDialog(p.name, p.sku)),
    );
  }

  void _addItemWithDialog(String name, String sku) {
    final costController = TextEditingController();
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add: $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: costController, decoration: const InputDecoration(labelText: 'Cost Price'), keyboardType: TextInputType.number),
            TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(costController.text) ?? 0.0;
              final qty = double.tryParse(qtyController.text) ?? 0.0;
              if (price > 0 && qty > 0) {
                setState(() {
                  _items.add(PurchaseItem(name: name, sku: sku, costPrice: price, qty: qty, gstRate: 18));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    final totalGst = subtotal * 0.18; // Mock 18% GST
    final total = subtotal + totalGst;
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return CustomCard(
      color: context.successColor.withValues(alpha: 0.02),
      child: Column(
        children: [
          _buildSummaryRow(context, 'Subtotal', currency.format(subtotal)),
          SizedBox(height: tokens.space8),
          _buildSummaryRow(context, 'Total GST (18%)', currency.format(totalGst)),
          Divider(height: tokens.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL PAYABLE', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(currency.format(total), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: context.successColor)),
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
        Text(label, style: TextStyle(color: context.onSurfaceVariantColor)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.tokens.space24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
      ),
      child: CustomButton(
        text: 'RECORD PURCHASE ENTRY',
        fullWidth: true,
        variant: CustomButtonVariant.primary,
        onPressed: () async {
          if (_selectedSupplier == null || _items.isEmpty) return;
          
          final success = await ref.read(purchaseNotifierProvider.notifier).createPurchase(
            PurchaseOrder(
              id: 'PUR-${DateTime.now().millisecondsSinceEpoch}',
              supplierId: _selectedSupplier!.id,
              supplierName: _selectedSupplier!.name,
              date: DateTime.now(),
              items: _items,
              status: 'Completed',
            ),
          );

          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Entry Recorded!')));
          }
        },
      ),
    );
  }
}

class _SupplierSelectionSheet extends ConsumerWidget {
  final Function(Contact) onSelected;
  const _SupplierSelectionSheet({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(crmNotifierProvider(ContactType.supplier));
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(24), child: Text('SELECT SUPPLIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(
            child: suppliersAsync.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text(list[index].initials)),
                  title: Text(list[index].name),
                  onTap: () {
                    onSelected(list[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSelectionSheet extends ConsumerWidget {
  final Function(dynamic) onSelected;
  const _ProductSelectionSheet({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryNotifierProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(24), child: Text('SELECT PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(
            child: productsAsync.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(list[index].name),
                  subtitle: Text('SKU: ${list[index].sku}'),
                  onTap: () {
                    onSelected(list[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
