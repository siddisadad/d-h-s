import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_text_field.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/entities/product.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/presentation/providers/inventory_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _hsnController;
  String _selectedCategory = 'Steel';
  String _selectedUnit = 'Kg';

  final List<String> _categories = ['Steel', 'Power Tools', 'Plumbing', 'Electrical'];
  final List<String> _units = ['Kg', 'Piece', 'Meter', 'Reel', 'MT'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _skuController = TextEditingController(text: widget.product?.sku);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    _stockController = TextEditingController(text: widget.product?.stock.toString());
    _hsnController = TextEditingController(text: widget.product?.hsnCode);

    if (widget.product != null) {
      if (_categories.contains(widget.product!.category)) {
        _selectedCategory = widget.product!.category;
      }
      if (_units.contains(widget.product!.unit)) {
        _selectedUnit = widget.product!.unit;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _hsnController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final newProduct = Product(
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      stock: double.tryParse(_stockController.text.trim()) ?? 0,
      hsnCode: _hsnController.text.trim().isEmpty ? null : _hsnController.text.trim(),
      unit: _selectedUnit,
      isLowStock: (double.tryParse(_stockController.text.trim()) ?? 0) < 50,
    );

    try {
      if (widget.product == null) {
        await ref.read(inventoryNotifierProvider.notifier).addProduct(newProduct);
      } else {
        await ref.read(inventoryNotifierProvider.notifier).updateProduct(newProduct);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: context.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'EDIT PRODUCT' : 'ADD NEW PRODUCT'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Product Name',
                hint: 'e.g. Tata Tiscon TMT Bar',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'SKU / Item Code',
                hint: 'e.g. STEEL-TMT-12',
                controller: _skuController,
                enabled: !isEdit, 
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _buildDropdown(
                label: 'Category',
                value: _selectedCategory,
                items: _categories,
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'HSN / SAC Code',
                hint: 'e.g. 7208',
                controller: _hsnController,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price (₹)',
                      hint: '0.00',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _selectedUnit,
                      items: _units,
                      onChanged: (val) => setState(() => _selectedUnit = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Current Stock',
                hint: '0',
                controller: _stockController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: isEdit ? 'Update Product' : 'Create Product',
                fullWidth: true,
                onPressed: _saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.colorScheme.primary),
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: context.textTheme.bodyLarge),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
