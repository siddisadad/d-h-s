import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/inventory_provider.dart';
import '../../../../core/services/excel_service.dart';
import '../../../../components/product_list_item/product_list_item_widget.dart';
import '../../../../components/inventory_stat_card/inventory_stat_card_widget.dart';
import 'product_form_screen.dart';
import 'barcode_scanner_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(inventoryNotifierProvider);
    final products = ref.watch(filteredProductsProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PRODUCT INVENTORY'),
        actions: [
          IconButton(
            tooltip: 'Export to Excel',
            icon: const Icon(Icons.description_outlined),
            onPressed: () => ref.read(excelServiceProvider.notifier).exportInventory(products),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
            ),
          ),
          SizedBox(width: tokens.space8),
          CustomButton(
            text: 'Add Product',
            variant: CustomButtonVariant.primary,
            icon: Icons.add_rounded,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen())),
          ),
          SizedBox(width: tokens.space16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildStats(context),
          _buildCategories(context),
          Expanded(
            child: productsAsync.when(
              data: (_) => _buildProductList(context, products),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(tokens.space24),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              label: 'Search Products',
              hint: 'Search by Name, SKU or HSN Code...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => ref.read(inventoryNotifierProvider.notifier).setSearchQuery(val),
            ),
          ),
          SizedBox(width: tokens.space16),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28), // Align with text field
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
        onPressed: () => _showFilterSheet(context),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final tokens = context.tokens;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(tokens.space24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SMART FILTERS', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            SizedBox(height: tokens.space24),
            Text('Stock Status', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: tokens.space12),
            Row(
              children: [
                _filterChip(context, 'In Stock', true),
                SizedBox(width: tokens.space8),
                _filterChip(context, 'Low Stock', false),
                SizedBox(width: tokens.space8),
                _filterChip(context, 'Out of Stock', false),
              ],
            ),
            SizedBox(height: tokens.space24),
            Text('Price Range', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            RangeSlider(
              values: const RangeValues(0, 100),
              max: 100,
              onChanged: (val) {},
              activeColor: AppColors.primary,
            ),
            SizedBox(height: tokens.space24),
            CustomButton(text: 'Apply Filters', fullWidth: true, onPressed: () => Navigator.pop(context)),
            SizedBox(height: tokens.space12),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {},
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildStats(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space24, vertical: tokens.space16),
      child: Row(
        children: [
          const Expanded(
            child: InventoryStatCardWidget(
              label: 'Total Items',
              value: '1,284',
              icon: Icons.inventory_2_outlined,
            ),
          ),
          SizedBox(width: tokens.space16),
          const Expanded(
            child: InventoryStatCardWidget(
              label: 'Low Stock',
              value: '12',
              icon: Icons.warning_amber_rounded,
              color: AppColors.error,
            ),
          ),
          SizedBox(width: tokens.space16),
          const Expanded(
            child: InventoryStatCardWidget(
              label: 'Total Value',
              value: '₹42.5L',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final tokens = context.tokens;
    final currentCat = ref.watch(inventoryNotifierProvider.notifier).currentCategory;
    final categories = ['All Items', 'Steel & Iron', 'Power Tools', 'Plumbing', 'Electrical'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(tokens.space24, 0, tokens.space24, tokens.space16),
      child: Row(
        children: categories.map((cat) {
          final isSelected = currentCat == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) ref.read(inventoryNotifierProvider.notifier).setCategory(cat);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<dynamic> products) {
    final tokens = context.tokens;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.disabled.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No products found', style: context.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(tokens.space24, 0, tokens.space24, tokens.space24),
      itemCount: products.length,
      separatorBuilder: (context, index) => SizedBox(height: tokens.space12),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItemWidget(
          product: product,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
          ),
          onDelete: () => _confirmDeletion(context, product.sku),
        ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  void _confirmDeletion(BuildContext context, String sku) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to permanently remove SKU: $sku? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(inventoryNotifierProvider.notifier).deleteProduct(sku);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
