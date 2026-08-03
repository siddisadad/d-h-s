import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/inventory_provider.dart';
import '../providers/category_provider.dart';
import '../../../../core/services/excel_service.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../../../../components/product_list_item/product_list_item_widget.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/security/permissions.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import 'product_form_screen.dart';
import 'barcode_scanner_screen.dart';
import 'product_detail_screen.dart';
import '../providers/inventory_stats_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/presentation/providers/forecast_provider.dart';
import '../../domain/entities/product.dart' as entity;
import 'package:intl/intl.dart';

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

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'PRODUCT INVENTORY',
        actions: [
          PermissionWrapper(
            requiredPermissions: const [AppPermission.exportData],
            child: IconButton(
              tooltip: 'Export to Excel',
              icon: const Icon(Icons.description_outlined),
              onPressed: () => ref.read(excelServiceProvider.notifier).exportInventory(products),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/inventory/scanner'),
          ),
          const SizedBox(width: 8),
          PermissionWrapper(
            requiredPermissions: const [AppPermission.manageInventory],
            child: CustomButton(
              text: 'Add Product',
              variant: CustomButtonVariant.primary,
              icon: Icons.add_rounded,
              onPressed: () => context.push('/inventory/new'),
            ),
          ),
        ],
      );
    });

    return Column(
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: context.colorScheme.surface,
      padding: EdgeInsets.all(tokens.space24),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              label: 'Search Products',
              hint: 'Search by Name, SKU or HSN Code...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => ref.read(inventorySearchProvider.notifier).set(val),
            ),
          ),
          const SizedBox(width: 16),
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
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(Icons.tune_rounded, color: context.colorScheme.onSurfaceVariant),
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
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SMART FILTERS', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2, color: context.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            Text('Stock Status', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _filterChip(context, 'In Stock', true),
                const SizedBox(width: 8),
                _filterChip(context, 'Low Stock', false),
                const SizedBox(width: 8),
                _filterChip(context, 'Out of Stock', false),
              ],
            ),
            const SizedBox(height: 24),
            Text('Price Range', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            RangeSlider(
              values: const RangeValues(0, 100),
              max: 100,
              onChanged: (val) {},
              activeColor: context.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            CustomButton(text: 'Apply Filters', fullWidth: true, onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 12),
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
      selectedColor: context.colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: context.colorScheme.primary,
    );
  }

  Widget _buildStats(BuildContext context) {
    final tokens = context.tokens;
    final stats = ref.watch(inventoryStatsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space24, vertical: tokens.space16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Total Items',
              value: stats.totalItems.toString(),
              icon: Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              label: 'Low Stock',
              value: stats.lowStockItems.toString(),
              icon: Icons.warning_amber_rounded,
              isAlert: stats.lowStockItems > 0,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              label: 'Total Value',
              value: _formatValue(stats.totalValue),
              icon: Icons.account_balance_wallet_outlined,
              color: context.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else {
      return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(value);
    }
  }

  Widget _buildCategories(BuildContext context) {
    final tokens = context.tokens;
    final currentCat = ref.watch(inventoryCategoryProvider);
    final categories = ref.watch(categoryNamesProvider);

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
                if (selected) ref.read(inventoryCategoryProvider.notifier).set(cat);
              },
              backgroundColor: context.colorScheme.surface,
              selectedColor: context.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? context.colorScheme.primary : context.colorScheme.outline),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<entity.Product> products) {
    final tokens = context.tokens;

    if (products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No Products Found',
        message: 'We couldn\'t find any products matching your search or category filters.',
        actionLabel: 'Clear All Filters',
        onAction: () {
          _searchController.clear();
          ref.read(inventorySearchProvider.notifier).set('');
          ref.read(inventoryCategoryProvider.notifier).set('All Items');
        },
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(tokens.space24, 0, tokens.space24, tokens.space24),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItemWidget(
          product: product,
          onTap: () => context.push('/inventory/${product.sku}'),
          onEdit: () => context.push('/inventory/edit/${product.sku}'),
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
            child: Text('Delete', style: TextStyle(color: context.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
