import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/finance_provider.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeNotifierProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FINANCE & CASH BOOK'),
      ),
      body: financeAsync.when(
        data: (transactions) => SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            children: [
              _buildCashBalance(context, transactions),
              SizedBox(height: tokens.space32),
              _buildEntries(context, transactions),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCashBalance(BuildContext context, dynamic transactions) {
    final tokens = context.tokens;
    final total = transactions.fold(0.0, (double sum, t) => sum + (t.category == 'Income' ? t.amount : -t.amount));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E3A8A)],
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
            style: context.textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##,###').format(total)}',
            style: context.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildEntries(BuildContext context, dynamic transactions) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENT ENTRIES', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        SizedBox(height: tokens.space16),
        ...transactions.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (t.category == 'Income' ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    t.category == 'Income' ? Icons.add_chart_rounded : Icons.payments_rounded,
                    color: t.category == 'Income' ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd MMM yyyy').format(t.date), style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(
                  '${t.category == 'Income' ? '+' : '-'} ₹${t.amount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: t.category == 'Income' ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
