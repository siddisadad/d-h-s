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

class PurchaseEntryScreen extends ConsumerStatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  ConsumerState<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends ConsumerState<PurchaseEntryScreen> {
  Contact? _selectedSupplier;
  final List<PurchaseItem> _items = [];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NEW PURCHASE ENTRY'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupplierSection(context),
            SizedBox(height: tokens.space24),
            _buildItemsSection(context),
            SizedBox(height: tokens.space24),
            _buildSummarySection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSupplierSection(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SUPPLIER', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        SizedBox(height: tokens.space12),
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
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  child: Text(_selectedSupplier!.initials, style: const TextStyle(color: AppColors.success)),
                ),
                SizedBox(width: tokens.space16),
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.error),
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
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PURCHASE ITEMS', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            TextButton.icon(
              onPressed: () => _showProductSelection(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Item'),
            ),
          ],
        ),
        SizedBox(height: tokens.space12),
        if (_items.isEmpty)
          CustomCard(
            padding: EdgeInsets.all(tokens.space32),
            child: const Center(child: Text('No items added')),
          )
        else
          ..._items.asMap().entries.map((e) => Padding(
            padding: EdgeInsets.only(bottom: tokens.space12),
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
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
      builder: (context) => _ProductSelectionSheet(onSelected: (p) => setState(() => _items.add(p))),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    final totalGst = subtotal * 0.18; // Mock 18% GST
    final total = subtotal + totalGst;
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return CustomCard(
      color: AppColors.success.withValues(alpha: 0.02),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', currency.format(subtotal)),
          SizedBox(height: tokens.space8),
          _buildSummaryRow('Total GST (18%)', currency.format(totalGst)),
          Divider(height: tokens.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL PAYABLE', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(currency.format(total), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.tokens.space24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: CustomButton(
        text: 'RECORD PURCHASE ENTRY',
        fullWidth: true,
        variant: CustomButtonVariant.primary,
        onPressed: () async {
          if (_selectedSupplier == null || _items.isEmpty) return;
          // Logic to save purchase
          Navigator.pop(context);
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
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
  final Function(PurchaseItem) onSelected;
  const _ProductSelectionSheet({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryNotifierProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    onSelected(PurchaseItem(
                      name: list[index].name,
                      costPrice: 50.0, // Mock
                      qty: 10,
                      gstRate: 18,
                    ));
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
