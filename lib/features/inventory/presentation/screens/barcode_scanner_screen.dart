import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/entities/product.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/presentation/screens/product_form_screen.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/scanner_overlay.dart';
import '../../domain/entities/warehouse.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  final bool isAuditMode;
  final Function(Product)? onResult;

  const BarcodeScannerScreen({
    super.key, 
    this.isAuditMode = false,
    this.onResult,
  });

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late MobileScannerController controller;
  bool isScanning = true;
  bool isBulkMode = false;
  final Map<String, int> bulkScans = {};
  Warehouse? selectedBulkWarehouse;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => isScanning = false);
    debugPrint('🔍 Barcode detected: $code');

    if (isBulkMode) {
      _handleBulkScan(code);
      return;
    }

    final productsAsync = ref.read(inventoryNotifierProvider);
    
    productsAsync.whenData((products) {
      final matches = products.where((p) => p.sku.toUpperCase() == code.toUpperCase());

      if (matches.isNotEmpty) {
        final product = matches.first;
        
        if (widget.onResult != null) {
          widget.onResult!(product);
          Navigator.pop(context);
          return;
        }

        if (widget.isAuditMode) {
          _showAuditDialog(product);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(product: product),
            ),
          );
        }
      } else {
        _handleNoMatch(code);
      }
    });
  }

  void _showAuditDialog(Product product) {
    final qtyController = TextEditingController();
    Warehouse? selectedWarehouse;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final warehousesAsync = ref.watch(warehouseNotifierProvider);

          return AlertDialog(
            title: Text('AUDIT: ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Total Stock: ${product.stock} ${product.unit}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text('Select Yard', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                warehousesAsync.when(
                  data: (list) {
                    if (selectedWarehouse == null && list.isNotEmpty) {
                       selectedWarehouse = list.firstWhere((w) => w.isDefault, orElse: () => list.first);
                    }
                    return DropdownButtonFormField<Warehouse>(
                      initialValue: selectedWarehouse,
                      items: list.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                      onChanged: (val) => selectedWarehouse = val,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Adjustment (+ or -)',
                    hintText: 'e.g. 50 or -10',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => isScanning = true);
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedWarehouse == null) return;
                  final adjustment = double.tryParse(qtyController.text) ?? 0;
                  if (adjustment != 0) {
                    await ref.read(inventoryNotifierProvider.notifier).adjustStock(
                      product.sku, 
                      selectedWarehouse!.id, 
                      adjustment,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stock updated for ${product.name} in ${selectedWarehouse!.name}'), duration: const Duration(seconds: 1)),
                    );
                    setState(() => isScanning = true);
                  }
                },
                child: const Text('UPDATE'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleNoMatch(String code) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No product found for SKU: $code'),
          backgroundColor: context.errorColor,
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: () => setState(() => isScanning = true),
          ),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !isScanning) {
          setState(() => isScanning = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAuditMode ? 'RAPID STOCK AUDIT' : 'SCAN BARCODE'),
        actions: [
          if (widget.isAuditMode)
            Row(
              children: [
                const Text('BULK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Switch(
                  value: isBulkMode,
                  onChanged: (val) {
                    setState(() {
                      isBulkMode = val;
                      isScanning = true;
                    });
                    if (val && selectedBulkWarehouse == null) {
                      _showBulkWarehouseSelection();
                    }
                  },
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android_rounded),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          ScannerOverlay(
            label: isBulkMode
              ? 'Bulk Mode Active: Scan items for ${selectedBulkWarehouse?.name ?? "..."}'
              : (widget.isAuditMode ? 'Scan item to adjust stock' : 'Align barcode within the frame'),
          ),
          if (isBulkMode && bulkScans.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildBulkStatusCard(),
            ),
        ],
      ),
    );
  }

  void _handleBulkScan(String code) {
    final productsAsync = ref.read(inventoryNotifierProvider);
    productsAsync.whenData((products) {
      final matches = products.where((p) => p.sku.toUpperCase() == code.toUpperCase());
      if (matches.isNotEmpty) {
        setState(() {
          bulkScans[code] = (bulkScans[code] ?? 0) + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${matches.first.name} (Total: ${bulkScans[code]})'),
            duration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        _handleNoMatch(code);
      }
      // Resume scanning after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => isScanning = true);
      });
    });
  }

  void _showBulkWarehouseSelection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Audit Yard'),
        content: Consumer(
          builder: (context, ref, _) {
            final warehousesAsync = ref.watch(warehouseNotifierProvider);
            return warehousesAsync.when(
              data: (list) => DropdownButtonFormField<Warehouse>(
                hint: const Text('Select target yard'),
                items: list.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
                onChanged: (val) => setState(() => selectedBulkWarehouse = val),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildBulkStatusCard() {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SESSIONS SCANS: ${bulkScans.length} items', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Total Units: ${bulkScans.values.fold(0, (a, b) => a + b)}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showReviewSheet(),
              child: const Text('REVIEW', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () => _commitBulkAudit(),
              child: const Text('COMMIT'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('BULK AUDIT REVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView(
                children: bulkScans.entries.map((e) => ListTile(
                  title: Text(e.key),
                  trailing: Text('x${e.value}'),
                  onLongPress: () => setState(() => bulkScans.remove(e.key)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _commitBulkAudit() async {
    if (selectedBulkWarehouse == null) {
      _showBulkWarehouseSelection();
      return;
    }

    final total = bulkScans.length;
    for (var entry in bulkScans.entries) {
      await ref.read(inventoryNotifierProvider.notifier).adjustStock(
        entry.key,
        selectedBulkWarehouse!.id,
        entry.value.toDouble(),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully updated $total items in ${selectedBulkWarehouse!.name}')));
      setState(() {
        bulkScans.clear();
        isBulkMode = false;
        isScanning = true;
      });
    }
  }
}
