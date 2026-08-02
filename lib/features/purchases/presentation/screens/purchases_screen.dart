import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/purchase_provider.dart';
import '../../../../components/purchase_stat_card/purchase_stat_card_widget.dart';
import '../../../../components/purchase_transaction_item/purchase_transaction_item_widget.dart';
import '../../../../core/widgets/custom_charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'purchase_entry_screen.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseNotifierProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PURCHASE MANAGEMENT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
          SizedBox(width: tokens.space8),
          CustomButton(
            text: 'New Purchase',
            variant: CustomButtonVariant.primary,
            icon: Icons.add_rounded,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseEntryScreen())),
          ),
          SizedBox(width: tokens.space16),
        ],
      ),
      body: purchasesAsync.when(
        data: (purchases) => RefreshIndicator(
          onRefresh: () => ref.read(purchaseNotifierProvider.notifier).refresh(),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilters(context),
                SizedBox(height: tokens.space24),
                _buildStats(context),
                SizedBox(height: tokens.space32),
                _buildPurchaseVolumeChart(context),
                SizedBox(height: tokens.space32),
                _buildRecentEntries(context, purchases),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        const Expanded(
          child: CustomTextField(
            label: 'Search Purchases',
            hint: 'Search by Supplier or SKU...',
            prefixIcon: Icons.search_rounded,
          ),
        ),
        SizedBox(width: tokens.space16),
        Container(
          margin: const EdgeInsets.only(top: 28),
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: PurchaseStatCardWidget(
            label: 'Pending GRN',
            value: '12 Orders',
            icon: Icons.pending_actions_rounded,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: context.tokens.space16),
        const Expanded(
          child: PurchaseStatCardWidget(
            label: 'Due Amount',
            value: '₹4.2L',
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseVolumeChart(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(context.tokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PURCHASE VOLUME (7 DAYS)',
            style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textSecondary),
          ),
          SizedBox(height: context.tokens.space24),
          SizedBox(
            height: 160,
            child: CustomLineChart(
              spots: const [
                FlSpot(0, 45),
                FlSpot(1, 80),
                FlSpot(2, 55),
                FlSpot(3, 90),
                FlSpot(4, 120),
                FlSpot(5, 70),
                FlSpot(6, 110),
              ],
              xLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
              color: AppColors.success,
              maxY: 140,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, List<dynamic> purchases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ENTRIES',
              style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.textSecondary),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        SizedBox(height: context.tokens.space12),
        ...purchases.map((p) => Padding(
          padding: EdgeInsets.only(bottom: context.tokens.space12),
          child: PurchaseTransactionItemWidget(
            amount: p.amount,
            date: p.date,
            sku: p.id,
            supplier: p.supplierName,
            status: p.status,
          ),
        )),
      ],
    );
  }
}
