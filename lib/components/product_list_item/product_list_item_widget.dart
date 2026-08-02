import '../../core/design_system/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import '../../features/inventory/domain/entities/product.dart';

class ProductListItemWidget extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductListItemWidget({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return CustomCard(
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
                      color: (product.isLowStock ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Text(
                      product.isLowStock ? 'Low Stock' : 'In Stock',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: product.isLowStock ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionMenu(context),
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
              _buildDetail(context, 'PRICE', product.price, isPrimary: true),
              _buildDetail(context, 'STOCK', '${product.stock} ${product.unit}', isBold: true, color: product.isLowStock ? AppColors.error : AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
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
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppColors.error)),
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
            color: color ?? (isPrimary ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
