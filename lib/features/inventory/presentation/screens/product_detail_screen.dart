import '../../../../core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';

import '../../../../core/providers/app_bar_provider.dart';
import '../../../../core/security/permissions.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../providers/inventory_provider.dart';
import '../providers/adjustment_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/presentation/providers/forecast_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/domain/entities/demand_forecast.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/stock_adjustment.dart';
import '../../domain/entities/warehouse.dart';
import 'product_form_screen.dart';
import 'stock_adjustments_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String sku;
  const ProductDetailScreen({super.key, required this.sku});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(sku));
    final history = ref.watch(productHistoryProvider(sku));
    final breakdownAsync = ref.watch(stockBreakdownProvider(sku));
    final warehousesAsync = ref.watch(warehouseNotifierProvider);
    final forecastAsync = ref.watch(demandForecastProvider(sku));
    final tokens = context.tokens;


    return productAsync.when(
      data: (product) {
        if (product == null) return const Center(child: Text('Product not found'));

        // Update Global AppBar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(appBarNotifierProvider.notifier).update(
            title: product.name.toUpperCase(),
            actions: [
              PermissionWrapper(
                requiredPermissions: const [AppPermission.manageInventory],
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                  ),
                ),
              ),
            ],
          );
        });

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, product),
              const SizedBox(height: 24),
              _buildStockCard(context, product),
              const SizedBox(height: 24),
              _buildDemandInsights(context, forecastAsync, product),
              const SizedBox(height: 24),
              _buildBreakdownSection(context, product, breakdownAsync, warehousesAsync),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.stockMovement, style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  PermissionWrapper(
                    requiredPermissions: const [AppPermission.adjustStock],
                    child: TextButton(
                      onPressed: () => _showAdjustmentDialog(context),
                      child: const Text(AppStrings.addAdjustment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              history.when(
                data: (list) => _buildHistoryList(context, list),
                loading: () => const Center(child: LinearProgressIndicator()),
                error: (e, s) => Text('Error loading history: $e'),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHeader(BuildContext context, Product product) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.inventory_2_rounded, color: context.colorScheme.primary, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                Text('SKU: ${product.sku} • HSN: 7214', style: context.textTheme.bodySmall),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(product.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colorScheme.secondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, Product product) {
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return Row(
      children: [
        Expanded(
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.currentStock, style: context.textTheme.labelSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${product.stock} ${product.unit}', style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    if (product.isLowStock)
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        PermissionWrapper(
          requiredPermissions: const [AppPermission.viewPrices],
          child: Expanded(
            child: CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.unitPrice, style: context.textTheme.labelSmall),
                  const SizedBox(height: 8),
                  Text(currency.format(product.price), style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: context.colorScheme.primary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemandInsights(BuildContext context, AsyncValue<DemandForecast?> forecastAsync, Product product) {
    return forecastAsync.when(
      data: (forecast) {
        if (forecast == null) return const SizedBox.shrink();
        return CustomCard(
          color: forecast.isCritical ? context.colorScheme.error.withValues(alpha: 0.02) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.demandInsights, style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                  _buildTrendBadge(context, forecast.trend),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _insightStat(
                      context, 
                      AppStrings.predictedDemand,
                      '${forecast.predictedWeeklyDemand.toStringAsFixed(1)} ${product.unit}',
                      Icons.trending_up_rounded,
                    ),
                  ),
                  Container(width: 1, height: 40, color: context.theme.dividerColor),
                  Expanded(
                    child: _insightStat(
                      context, 
                      AppStrings.estStockOut,
                      forecast.estimatedDaysUntilStockOut > 365 ? '99+ Days' : '${forecast.estimatedDaysUntilStockOut} Days',
                      Icons.timer_outlined,
                      color: forecast.isCritical ? context.colorScheme.error : (forecast.isWarning ? Colors.orange : null),
                    ),
                  ),
                ],
              ),
              if (forecast.isCritical) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: context.colorScheme.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(AppStrings.criticalStockOut, style: TextStyle(color: context.colorScheme.error, fontSize: 11, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: LinearProgressIndicator()),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _insightStat(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: context.tokens.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: context.textTheme.labelSmall?.copyWith(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTrendBadge(BuildContext context, TrendDirection trend) {
    String label;
    IconData icon;
    Color color;

    switch (trend) {
      case TrendDirection.up:
        label = AppStrings.trendRising;
        icon = Icons.trending_up_rounded;
        color = context.tokens.success;
        break;
      case TrendDirection.down:
        label = AppStrings.trendFalling;
        icon = Icons.trending_down_rounded;
        color = context.colorScheme.error;
        break;
      case TrendDirection.stable:
        label = AppStrings.trendStable;
        icon = Icons.trending_flat_rounded;
        color = context.colorScheme.secondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection(BuildContext context, Product product, AsyncValue<Map<String, double>> breakdownAsync, AsyncValue<List<Warehouse>> warehousesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.stockBreakdown, style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        breakdownAsync.when(
          data: (breakdown) => warehousesAsync.when(
            data: (warehouses) => CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: warehouses.map((w) {
                  final qty = breakdown[w.id] ?? 0.0;
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(w.location),
                    trailing: Text(
                      '${NumberFormat.decimalPattern().format(qty)} ${product.unit}',
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (e, s) => const Text('Error loading warehouses'),
          ),
          loading: () => const Center(child: LinearProgressIndicator()),
          error: (e, s) => const Text('Error loading breakdown'),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context, List<StockAdjustment> history) {
    if (history.isEmpty) {
      return const CustomCard(
        padding: EdgeInsets.all(32),
        child: Center(child: Text(AppStrings.noMovementHistory)),
      );
    }

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: history.map((adj) {
          final isPositive = adj.quantityChange > 0;
          return ListTile(
            leading: Icon(adj.reason.icon, color: isPositive ? context.tokens.success : context.colorScheme.error),
            title: Text(adj.reason.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(adj.timestamp)),
            trailing: Text(
              '${isPositive ? "+" : ""}${adj.quantityChange}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isPositive ? context.tokens.success : context.colorScheme.error,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdjustmentFormDialog(),
    );
  }
}
