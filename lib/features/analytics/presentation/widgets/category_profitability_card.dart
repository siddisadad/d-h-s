import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../inventory/domain/entities/product.dart';

class CategoryProfitabilityCard extends ConsumerWidget {
  const CategoryProfitabilityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PROFIT MARGINS BY CATEGORY',
            style: context.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        productsAsync.when(
          data: (products) {
            final categories = products.map((p) => p.category).toSet().toList();
            final Map<String, List<double>> margins = {};

            for (var cat in categories) {
               final catProducts = products.where((p) => p.category == cat).toList();
               margins[cat] = catProducts.map((p) {
                 if (p.price == 0) return 0.0;
                 return ((p.price - p.costPrice) / p.price) * 100;
               }).toList();
            }

            return CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: categories.map((cat) {
                  final avgMargin = margins[cat]!.reduce((a, b) => a + b) / margins[cat]!.length;
                  return ListTile(
                    title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text('${avgMargin.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: avgMargin > 15 ? Colors.green : (avgMargin > 5 ? Colors.blue : Colors.orange),
                      ),
                    ),
                    subtitle: LinearProgressIndicator(
                      value: avgMargin / 100,
                      backgroundColor: context.colorScheme.outline.withValues(alpha: 0.1),
                      color: avgMargin > 15 ? Colors.green : (avgMargin > 5 ? Colors.blue : Colors.orange),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: LinearProgressIndicator()),
          error: (e, s) => Text('Error calculating margins: $e'),
        ),
      ],
    );
  }
}
