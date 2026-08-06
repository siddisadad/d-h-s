import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_scaffold.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/adjustment_provider.dart';
import '../providers/inventory_provider.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/warehouse.dart';

class StockAdjustmentsScreen extends ConsumerWidget {
  const StockAdjustmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustments = ref.watch(adjustmentNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'STOCK ADJUSTMENTS',
        actions: [
          CustomButton(
            text: 'New Adjustment',
            variant: CustomButtonVariant.primary,
            icon: Icons.add_rounded,
            onPressed: () => _showAdjustmentDialog(context, ref),
          ),
        ],
      );
    });

    return AppScaffold(
      title: '', // Handled by provider
      body: Padding(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: adjustments.isEmpty 
                ? _buildEmptyState(context)
                : _buildHistoryList(context, adjustments),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adjustment History',
          style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Review all manual stock corrections and audit logs.',
          style: context.textTheme.bodyMedium?.copyWith(color: context.tokens.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: context.theme.disabledColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No Adjustments Yet', style: context.textTheme.titleMedium),
          Text('Perform your first stock correction to see it here.', style: context.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<StockAdjustment> adjustments) {
    final tokens = context.tokens;
    return ListView.separated(
      itemCount: adjustments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final adj = adjustments[index];
        final isPositive = adj.quantityChange > 0;
        
        return CustomCard(
          padding: EdgeInsets.all(tokens.space16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: adj.reason.icon == Icons.broken_image_rounded ? context.colorScheme.error.withValues(alpha: 0.1) : context.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(adj.reason.icon, color: adj.reason.icon == Icons.broken_image_rounded ? context.colorScheme.error : context.colorScheme.primary, size: 20),
              ),
              SizedBox(width: tokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(adj.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('SKU: ${adj.productSku} • ${adj.reason.label}', style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? "+" : ""}${adj.quantityChange}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isPositive ? context.tokens.success : context.colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(adj.timestamp),
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 10, color: context.tokens.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdjustmentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AdjustmentFormDialog(),
    );
  }
}

class AdjustmentFormDialog extends ConsumerStatefulWidget {
  const AdjustmentFormDialog({super.key});

  @override
  ConsumerState<AdjustmentFormDialog> createState() => _AdjustmentFormDialogState();
}

class _AdjustmentFormDialogState extends ConsumerState<AdjustmentFormDialog> {
  Product? selectedProduct;
  Warehouse? selectedWarehouse;
  final qtyController = TextEditingController();
  final notesController = TextEditingController();
  AdjustmentReason selectedReason = AdjustmentReason.correction;

  @override
  void initState() {
    super.initState();
    // Default warehouse will be set when data arrives or if we pre-fetch
  }

  @override
  void dispose() {
    qtyController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(inventoryNotifierProvider);
    final warehousesAsync = ref.watch(warehouseNotifierProvider);

    return AlertDialog(
      title: const Text('Perform Stock Adjustment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            productsAsync.when(
              data: (products) => DropdownButtonFormField<Product>(
                initialValue: selectedProduct,
                isExpanded: true,
                hint: const Text('Select a product'),
                items: products.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text('${p.name} (${p.sku})', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (val) => setState(() => selectedProduct = val),
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const Text('Error loading products'),
            ),
            const SizedBox(height: 16),
            const Text('Warehouse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            warehousesAsync.when(
              data: (warehouses) {
                // Auto-select default if none selected
                if (selectedWarehouse == null && warehouses.isNotEmpty) {
                  final def = warehouses.firstWhere((w) => w.isDefault, orElse: () => warehouses.first);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => selectedWarehouse = def);
                  });
                }

                return DropdownButtonFormField<Warehouse>(
                  initialValue: selectedWarehouse,
                  isExpanded: true,
                  hint: const Text('Select warehouse'),
                  items: warehouses.map((w) => DropdownMenuItem(
                    value: w,
                    child: Text(w.name),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedWarehouse = val),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const Text('Error loading warehouses'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Qty Change',
                    hint: 'e.g. -5 or 10',
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reason', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AdjustmentReason>(
                        initialValue: selectedReason,
                        items: AdjustmentReason.values.map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.label),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedReason = val!),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Notes (Optional)',
              hint: 'Explain why this adjustment is being made...',
              controller: notesController,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: const Text('Apply Adjustment'),
        ),
      ],
    );
  }

  void _submit() async {
    if (selectedProduct == null || selectedWarehouse == null || qtyController.text.isEmpty) return;

    final qty = double.tryParse(qtyController.text) ?? 0;
    if (qty == 0) return;

    final adjustment = StockAdjustment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productSku: selectedProduct!.sku,
      productName: selectedProduct!.name,
      warehouseId: selectedWarehouse!.id,
      quantityChange: qty,
      reason: selectedReason,
      timestamp: DateTime.now(),
      performedBy: 'Admin User',
      notes: notesController.text,
    );

    await ref.read(inventoryNotifierProvider.notifier).adjustStock(
      selectedProduct!.sku, 
      selectedWarehouse!.id, 
      qty,
    );
    
    // Add to history (local UI state for this screen's session)
    await ref.read(adjustmentNotifierProvider.notifier).addAdjustment(adjustment);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock adjusted for ${selectedProduct!.name}'),
          backgroundColor: context.successColor,
        ),
      );
    }
  }
}
