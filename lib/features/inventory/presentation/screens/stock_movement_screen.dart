import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../providers/movement_provider.dart';

class StockMovementScreen extends ConsumerWidget {
  const StockMovementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(allMovementsProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'STOCK AUDIT TRAIL',
      );
    });

    return movementsAsync.when(
      data: (movements) => ListView.separated(
        padding: EdgeInsets.all(tokens.space24),
        itemCount: movements.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final m = movements[index];
          final qty = (m['quantity'] as num).toDouble();
          final isPositive = qty > 0;

          return CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPositive ? context.tokens.success.withValues(alpha: 0.1) : context.colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPositive ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                    color: isPositive ? context.tokens.success : context.colorScheme.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${m['reason']} • ${m['warehouseId']}', style: context.textTheme.labelSmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isPositive ? "+" : ""}$qty',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isPositive ? context.tokens.success : context.colorScheme.error,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(m['timestamp'])),
                      style: context.textTheme.labelSmall?.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
