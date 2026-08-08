import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../providers/finance_provider.dart';

class CashClosingScreen extends ConsumerStatefulWidget {
  const CashClosingScreen({super.key});

  @override
  ConsumerState<CashClosingScreen> createState() => _CashClosingScreenState();
}

class _CashClosingScreenState extends ConsumerState<CashClosingScreen> {
  final _physicalCashController = TextEditingController();
  final _notesController = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesHistoryProvider);
    final financeAsync = ref.watch(financeNotifierProvider);
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'DAILY CASH CLOSING',
      );
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context),
            const SizedBox(height: 24),
            _buildCalculatedSection(context, salesAsync, financeAsync, currency),
            const SizedBox(height: 24),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHYSICAL CASH COUNT', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Actual Cash in Drawer',
                    hint: '0.00',
                    controller: _physicalCashController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Notes / Remarks',
                    hint: 'e.g. Minor difference due to coins',
                    controller: _notesController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'VALIDATE & CLOSE DAY',
              fullWidth: true,
              loading: isSaving,
              onPressed: _handleClosing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today_rounded, size: 16, color: context.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Closing for: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
          style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCalculatedSection(BuildContext context, dynamic salesAsync, dynamic financeAsync, NumberFormat currency) {
    final lastClosingAsync = ref.watch(lastCashClosingProvider);

    // Mocking calculations based on current day data
    double openingBalance = 0;
    double cashSales = 0;
    double cashExpenses = 0;

    if (lastClosingAsync is AsyncData && lastClosingAsync.value != null) {
      openingBalance = lastClosingAsync.value!.physicalCashCount;
    }

    if (salesAsync is AsyncData) {
      final today = DateTime.now();
      cashSales = salesAsync.value!.where((s) =>
        s.date.year == today.year && s.date.month == today.month && s.date.day == today.day
      ).fold(0.0, (sum, s) => sum + s.grandTotal);
    }

    if (financeAsync is AsyncData) {
      final today = DateTime.now();
      cashExpenses = financeAsync.value!.where((t) =>
        t.category == 'Expense' && t.paymentMode == 'Cash' &&
        t.date.year == today.year && t.date.month == today.month && t.date.day == today.day
      ).fold(0.0, (sum, t) => sum + t.amount);
    }

    final expectedClosing = openingBalance + cashSales - cashExpenses;

    return CustomCard(
      color: context.colorScheme.primary.withValues(alpha: 0.05),
      child: Column(
        children: [
          _buildRow('Opening Balance (System)', currency.format(openingBalance)),
          _buildRow('Total Cash Sales', '+ ${currency.format(cashSales)}', color: context.successColor),
          _buildRow('Total Cash Expenses', '- ${currency.format(cashExpenses)}', color: context.colorScheme.error),
          const Divider(height: 32),
          _buildRow('Expected Closing', currency.format(expectedClosing), isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _handleClosing() async {
    if (_physicalCashController.text.isEmpty) return;

    setState(() => isSaving = true);

    final physicalCount = double.tryParse(_physicalCashController.text) ?? 0.0;

    // Get current data for persistence
    final sales = ref.read(salesHistoryProvider).value ?? [];
    final transactions = ref.read(financeNotifierProvider).value ?? [];
    final lastClosing = ref.read(lastCashClosingProvider).value;

    final today = DateTime.now();
    final openingBalance = lastClosing?.physicalCashCount ?? 0.0;
    final cashSales = sales.where((s) =>
      s.date.year == today.year && s.date.month == today.month && s.date.day == today.day
    ).fold(0.0, (sum, s) => sum + s.grandTotal);

    final cashExpenses = transactions.where((t) =>
      t.category == 'Expense' && t.paymentMode == 'Cash' &&
      t.date.year == today.year && t.date.month == today.month && t.date.day == today.day
    ).fold(0.0, (sum, t) => sum + t.amount);

    final success = await ref.read(financeNotifierProvider.notifier).performClosing(
      openingBalance: openingBalance,
      totalCashSales: cashSales,
      totalCashExpenses: cashExpenses,
      physicalCashCount: physicalCount,
      notes: _notesController.text,
    );

    setState(() => isSaving = false);

    if (success && mounted) {
      ref.invalidate(lastCashClosingProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day Closed Successfully! Summary synced to Cloud.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
