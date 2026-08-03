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
                      value: selectedWarehouse,
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
            label: widget.isAuditMode ? 'Scan item to adjust stock' : 'Align barcode within the frame',
          ),
        ],
      ),
    );
  }
}
