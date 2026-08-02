import 'package:flutter/material.dart';
import '../design_system/theme/app_theme.dart';

class CustomDataTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> items;
  final Widget Function(T item) rowBuilder;
  final VoidCallback? onLoadMore;
  final bool isLoading;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.items,
    required this.rowBuilder,
    this.onLoadMore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: context.theme.dividerColor),
        boxShadow: [tokens.shadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: tokens.space16, vertical: tokens.space12),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(tokens.radiusLg),
                topRight: Radius.circular(tokens.radiusLg),
              ),
              border: Border(bottom: BorderSide(color: context.theme.dividerColor)),
            ),
            child: Row(
              children: columns.map((col) => Expanded(
                child: Text(
                  col.toUpperCase(),
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.primary,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
          ),
          
          // Body
          if (items.isEmpty && !isLoading)
            Padding(
              padding: EdgeInsets.all(tokens.space32),
              child: Center(
                child: Text(
                  'No data available',
                  style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length + (isLoading ? 1 : 0),
              separatorBuilder: (context, index) => Divider(height: 1, color: context.theme.dividerColor),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return Padding(
                    padding: EdgeInsets.all(tokens.space16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return rowBuilder(items[index]);
              },
            ),
        ],
      ),
    );
  }
}

class CustomDataRow extends StatelessWidget {
  final List<Widget> cells;
  final VoidCallback? onTap;

  const CustomDataRow({
    super.key,
    required this.cells,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space16, vertical: tokens.space16),
        child: Row(
          children: cells.map((cell) => Expanded(child: cell)).toList(),
        ),
      ),
    );
  }
}
