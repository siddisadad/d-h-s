import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/sales_returns_provider.dart';


class SalesReturnsScreen extends ConsumerWidget {
  const SalesReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(salesReturnsProvider);
    final tokens = context.tokens;

    return returnsAsync.when(
      data: (returns) {
        if (returns.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.assignment_return_outlined,
            title: 'No Returns Found',
            message: 'Manage product returns and issue credit notes to customers. Keep your inventory and accounts in sync.',
            actionLabel: 'Process New Return',
            onAction: () => context.push('/sales/returns/new'),
          );
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/sales/returns/new'),
            child: const Icon(Icons.add),
          ),
          body: ListView.separated(
            padding: EdgeInsets.all(tokens.space24),
            itemCount: returns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ret = returns[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colorScheme.errorContainer,
                    child: Icon(Icons.assignment_return_outlined, color: context.colorScheme.error),
                  ),
                  title: Text(ret.customerName, style: context.textTheme.titleMedium),
                  subtitle: Text('ID: ${ret.id} • Original Inv: ${ret.originalInvoiceId}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('- ₹${ret.grandTotal.toStringAsFixed(0)}', style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.error)),
                      Text(DateFormat('dd MMM').format(ret.date), style: context.textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}
