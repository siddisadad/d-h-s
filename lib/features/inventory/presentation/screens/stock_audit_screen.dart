import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/stock_audit_provider.dart';
import '../../domain/entities/stock_audit.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/warehouse.dart';

class StockAuditScreen extends ConsumerStatefulWidget {
  const StockAuditScreen({super.key});

  @override
  ConsumerState<StockAuditScreen> createState() => _StockAuditScreenState();
}

class _StockAuditScreenState extends ConsumerState<StockAuditScreen> {
  Warehouse? selectedWarehouse;
  final List<StockAuditItem> auditItems = [];
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehouseNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'PHYSICAL STOCK AUDIT',
      );
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildWarehouseSelector(context, warehousesAsync),
          Expanded(
            child: selectedWarehouse == null
                ? _buildInitialState(context)
                : _buildAuditList(context),
          ),
          if (selectedWarehouse != null) _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector(BuildContext context, AsyncValue<List<Warehouse>> warehousesAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: context.colorScheme.surface,
      child: warehousesAsync.when(
        data: (list) => DropdownButtonFormField<Warehouse>(
          value: selectedWarehouse,
          decoration: const InputDecoration(
            labelText: 'SELECT YARD FOR AUDIT',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: list.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
          onChanged: (val) {
            setState(() {
              selectedWarehouse = val;
              auditItems.clear();
            });
          },
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, s) => Text('Error: $e'),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_rounded, size: 64, color: context.onSurfaceVariantColor.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('Select a warehouse to begin audit', style: context.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildAuditList(BuildContext context) {
    final tokens = context.tokens;

    return ListView.builder(
      padding: EdgeInsets.all(tokens.space16),
      itemCount: auditItems.length + 1,
      itemBuilder: (context, index) {
        if (index == auditItems.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: CustomButton(
              text: 'ADD PRODUCT TO AUDIT',
              variant: CustomButtonVariant.outline,
              icon: Icons.add_rounded,
              onPressed: () => _showProductPicker(context),
            ),
          );
        }
        return _buildAuditItemCard(context, auditItems[index], index);
      },
    );
  }

  Widget _buildAuditItemCard(BuildContext context, StockAuditItem item, int index) {
    final variance = item.physicalQuantity - item.systemQuantity;
    final color = variance == 0 ? Colors.green : (variance > 0 ? Colors.blue : Colors.red);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('SKU: ${item.productSku}', style: context.textTheme.labelSmall),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => setState(() => auditItems.removeAt(index)),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: _qtyStat('System', item.systemQuantity.toStringAsFixed(2)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              Expanded(
                child: _qtyStat('Physical', item.physicalQuantity.toStringAsFixed(2), isEditable: true, onEdit: () => _editPhysicalQty(context, index)),
              ),
              const VerticalDivider(),
              Expanded(
                child: _qtyStat('Variance', '${variance >= 0 ? "+" : ""}${variance.toStringAsFixed(2)}', color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyStat(String label, String val, {Color? color, bool isEditable = false, VoidCallback? onEdit}) {
    return InkWell(
      onTap: onEdit,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(val, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
              if (isEditable) const Icon(Icons.edit_rounded, size: 12, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductPicker(BuildContext context) async {
    final products = await ref.read(inventoryNotifierProvider.future);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProductPickerSheet(
        products: products,
        onSelected: (p) => _addAuditItem(context, p),
      ),
    );
  }

  void _addAuditItem(BuildContext context, Product product) async {
    // Get current stock for the selected warehouse
    final breakdown = await ref.read(stockBreakdownProvider(product.sku).future);
    final systemQty = breakdown[selectedWarehouse!.id] ?? 0.0;

    setState(() {
      auditItems.add(StockAuditItem(
        productSku: product.sku,
        productName: product.name,
        systemQuantity: systemQty,
        physicalQuantity: systemQty, // Default to system qty
      ));
    });
    Navigator.pop(context);
  }

  void _editPhysicalQty(BuildContext context, int index) {
    final controller = TextEditingController(text: auditItems[index].physicalQuantity.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Physical Count for ${auditItems[index].productName}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'Units'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? auditItems[index].physicalQuantity;
              setState(() {
                auditItems[index] = StockAuditItem(
                  productSku: auditItems[index].productSku,
                  productName: auditItems[index].productName,
                  systemQuantity: auditItems[index].systemQuantity,
                  physicalQuantity: val,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'COMPLETE AUDIT & ADJUST STOCK',
              fullWidth: true,
              loading: isSaving,
              onPressed: auditItems.isEmpty ? null : _saveAudit,
            ),
          ),
        ],
      ),
    );
  }

  void _saveAudit() async {
    setState(() => isSaving = true);

    final audit = StockAudit(
      id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      warehouseId: selectedWarehouse!.id,
      timestamp: DateTime.now(),
      performedBy: 'Manager',
      items: auditItems,
      status: 'Completed',
    );

    // 1. Create the Audit Record
    await ref.read(stockAuditNotifierProvider.notifier).createAudit(audit);

    // 2. Perform Stock Adjustments for Variances
    for (var item in auditItems) {
      final variance = item.physicalQuantity - item.systemQuantity;
      if (variance != 0) {
        await ref.read(inventoryNotifierProvider.notifier).adjustStock(
          item.productSku,
          selectedWarehouse!.id,
          variance,
          reason: 'Audit Adjustment',
          notes: 'Ref: ${audit.id}',
        );
      }
    }

    setState(() => isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audit Completed and Stock Adjusted!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}

class _ProductPickerSheet extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onSelected;

  const _ProductPickerSheet({required this.products, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text('SELECT PRODUCT', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(products[index].name),
                subtitle: Text('SKU: ${products[index].sku}'),
                onTap: () => onSelected(products[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
