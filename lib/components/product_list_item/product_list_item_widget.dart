import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:deshmukh_steel_e_r_p/features/inventory/domain/entities/product.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/presentation/providers/forecast_provider.dart';
import 'package:intl/intl.dart';

class ProductListItemWidget extends ConsumerWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductListItemWidget({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final forecastAsync = ref.watch(demandForecastProvider(product.sku));
    
    return CustomCard(
      onTap: onTap,
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'SKU: ${product.sku}',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (product.isLowStock ? tokens.error : tokens.success).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Text(
                      product.isLowStock ? 'Low Stock' : 'In Stock',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: product.isLowStock ? tokens.error : tokens.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  forecastAsync.maybeWhen(
                    data: (forecast) => forecast != null && forecast.isCritical 
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: context.colorScheme.error, borderRadius: BorderRadius.circular(4)),
                          child: const Text('PRIORITY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  PermissionWrapper(
                    requiredPermissions: const [AppPermission.manageInventory],
                    child: _buildActionMenu(context),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 24, color: context.theme.dividerColor.withValues(alpha: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetail(context, 'CATEGORY', product.category),
              _buildDetail(context, 'UNIT', product.unit),
              PermissionWrapper(
                requiredPermissions: const [AppPermission.viewPrices],
                child: _buildDetail(
                  context,
                  'PRICE',
                  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(product.price),
                  isPrimary: true,
                ),
              ),
              _buildDetail(
                context,
                'STOCK',
                '${NumberFormat.decimalPattern().format(product.stock)} ${product.unit}',
                isBold: true,
                color: product.isLowStock ? tokens.error : context.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: context.tokens.textSecondary, size: 20),
      onSelected: (val) {
        if (val == 'edit') onEdit?.call();
        if (val == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit Product'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: context.colorScheme.error),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: context.colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value, {bool isPrimary = false, bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold || isPrimary ? FontWeight.w700 : FontWeight.w500,
            color: color ?? (isPrimary ? context.primaryColor : context.onSurfaceColor),
          ),
        ),
      ],
    );
  }
}
