import '../../../../components/base_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import '../providers/finance_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';
import 'package:intl/intl.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeNotifierProvider);
    final salesAsync = ref.watch(salesHistoryProvider);
    final purchasesAsync = ref.watch(purchaseHistoryProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
            title: 'FINANCE & CASH BOOK',
          );
    });

    return financeAsync.when(
      data: (transactions) {
        double totalBalance = 0;
        
        final salesData = salesAsync.asData?.value;
        final purchasesData = purchasesAsync.asData?.value;

        if (salesData != null && purchasesData != null) {
          final totalSales = salesData.fold(0.0, (sum, s) => sum + s.grandTotal);
          final totalPurchases = purchasesData.fold(0.0, (sum, p) => sum + p.grandTotal);
          totalBalance = totalSales - totalPurchases;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            children: [
              _buildCashBalance(context, totalBalance),
              const SizedBox(height: 32),
              _buildEntries(context, transactions),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildCashBalance(BuildContext context, double total) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.primary,
            context.colorScheme.primaryContainer
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        boxShadow: [tokens.shadowMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL CASH BALANCE',
            style: context.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###').format(total)}',
            style: context.textTheme.headlineLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildEntries(BuildContext context, List<TransactionModel> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENT ENTRIES',
            style: context.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(
              transactions.length,
              (index) {
                final t = transactions[index];
                final isIncome = t.category == 'Income';
                return BaseListItem(
                  title: t.title,
                  subtitle: DateFormat('dd MMM yyyy').format(t.date),
                  showDivider: index < transactions.length - 1,
                  leadingIcon: isIncome
                      ? Icons.add_chart_rounded
                      : Icons.payments_rounded,
                  leadingIconColor:
                      isIncome ? context.tokens.success : context.colorScheme.error,
                  leadingBackgroundColor:
                      (isIncome ? context.tokens.success : context.colorScheme.error)
                          .withValues(alpha: 0.1),
                  trailing: Text(
                    '${isIncome ? '+' : '-'} ₹${t.amount}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isIncome
                          ? context.tokens.success
                          : context.colorScheme.error,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
