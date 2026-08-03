import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../providers/inventory_provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/warehouse.dart';
import '../../domain/entities/stock_transfer.dart';

class StockTransferScreen extends ConsumerStatefulWidget {
  const StockTransferScreen({super.key});

  @override
  ConsumerState<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends ConsumerState<StockTransferScreen> {
  Product? selectedProduct;
  Warehouse? fromWarehouse;
  Warehouse? toWarehouse;
  final qtyController = TextEditingController();
  final notesController = TextEditingController();
  bool isProcessing = false;

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
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'STOCK TRANSFER',
      );
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 24),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECT PRODUCT', style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  productsAsync.when(
                    data: (products) => DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      isExpanded: true,
                      hint: const Text('Search or select product'),
                      items: products.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (${p.sku})'),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedProduct = val),
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.inventory_2_outlined)),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, s) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FROM YARD', style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            warehousesAsync.when(
                              data: (warehouses) => DropdownButtonFormField<Warehouse>(
                                value: fromWarehouse,
                                hint: const Text('Source'),
                                items: warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                                onChanged: (val) => setState(() => fromWarehouse = val),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (e, s) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TO YARD', style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            warehousesAsync.when(
                              data: (warehouses) => DropdownButtonFormField<Warehouse>(
                                value: toWarehouse,
                                hint: const Text('Destination'),
                                items: warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                                onChanged: (val) => setState(() => toWarehouse = val),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (e, s) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Quantity to Transfer',
                    hint: '0.00',
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.scale_rounded,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Remarks / Notes',
                    hint: 'Optional reason for transfer...',
                    controller: notesController,
                    maxLines: 2,
                    prefixIcon: Icons.notes_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'INITIATE TRANSFER',
              fullWidth: true,
              loading: isProcessing,
              onPressed: _handleTransfer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Stock transfers deduct quantity from the source yard and add it to the destination yard. This action is irreversible once saved.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTransfer() async {
    if (selectedProduct == null || fromWarehouse == null || toWarehouse == null || qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (fromWarehouse!.id == toWarehouse!.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Source and destination cannot be same')));
      return;
    }

    final qty = double.tryParse(qtyController.text) ?? 0;
    if (qty <= 0) return;

    setState(() => isProcessing = true);

    final transfer = StockTransfer(
      id: 'TRF-${DateTime.now().millisecondsSinceEpoch}',
      fromWarehouseId: fromWarehouse!.id,
      toWarehouseId: toWarehouse!.id,
      productSku: selectedProduct!.sku,
      productName: selectedProduct!.name,
      quantity: qty,
      timestamp: DateTime.now(),
      performedBy: 'Admin User',
      notes: notesController.text,
    );

    final result = await ref.read(inventoryRepositoryProvider).transferStock(transfer);

    setState(() => isProcessing = false);

    if (result.isSuccess && mounted) {
      ref.invalidate(inventoryNotifierProvider);
      ref.invalidate(stockBreakdownProvider(selectedProduct!.sku));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Stock Transferred Successfully!'),
          backgroundColor: context.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer failed: ${result.failure?.message}')));
    }
  }
}
