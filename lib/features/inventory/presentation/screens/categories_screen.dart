import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../../../../core/design_system/app_scaffold.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/inventory_category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'PRODUCT CATEGORIES',
        actions: [
          CustomButton(
            text: 'New Category',
            variant: CustomButtonVariant.primary,
            icon: Icons.add_rounded,
            onPressed: () => _showCategoryDialog(context, ref),
          ),
        ],
      );
    });

    return AppScaffold(
      title: '', // Title handled by AppBarNotifier
      body: Padding(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage and organize your product catalog by categories.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: tokens.space16,
                      mainAxisSpacing: tokens.space16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(context, ref, category);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, InventoryCategory category) {
    final tokens = context.tokens;
    return CustomCard(
      padding: EdgeInsets.all(tokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: context.colorScheme.primary, size: 24),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
                onSelected: (value) {
                  if (value == 'edit') _showCategoryDialog(context, ref, category: category);
                  if (value == 'delete') _confirmDeletion(context, ref, category);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Category')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: context.colorScheme.error)),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            category.name,
            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${category.productCount} Products',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {InventoryCategory? category}) {
    final nameController = TextEditingController(text: category?.name);
    final descController = TextEditingController(text: category?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'New Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newCategory = InventoryCategory(
                id: category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                description: descController.text,
                icon: category?.icon ?? Icons.inventory_2_rounded,
                productCount: category?.productCount ?? 0,
              );
              if (category == null) {
                ref.read(categoryNotifierProvider.notifier).addCategory(newCategory);
              } else {
                ref.read(categoryNotifierProvider.notifier).updateCategory(newCategory);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context, WidgetRef ref, InventoryCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"? All products will remain but will be uncategorized.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(categoryNotifierProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: context.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
