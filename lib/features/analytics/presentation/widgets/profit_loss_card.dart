import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';
import '../../../employees/presentation/providers/employee_provider.dart';
import '../../../finance/presentation/providers/finance_provider.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../../../../core/security/permissions.dart';

class ProfitLossCard extends ConsumerWidget {
  const ProfitLossCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesHistoryProvider);
    final purchasesAsync = ref.watch(purchaseHistoryProvider);
    final employeesAsync = ref.watch(employeeNotifierProvider);
    final financeAsync = ref.watch(financeNotifierProvider);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return salesAsync.when(
      data: (sales) => purchasesAsync.when(
        data: (purchases) => employeesAsync.when(
          data: (employees) => financeAsync.when(
            data: (transactions) {
              final grossSales = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
              final cogs = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);
              final salaries = employees.fold(0.0, (sum, e) => sum + (double.tryParse(e.salary.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0));

              final otherIncome = transactions.where((t) => t.category == 'Income').fold(0.0, (sum, t) => sum + t.amount);
              final otherExpenses = transactions.where((t) => t.category == 'Expense').fold(0.0, (sum, t) => sum + t.amount);

              final totalIncome = grossSales + otherIncome;
              final totalExpenses = cogs + salaries + otherExpenses;
              final netProfit = totalIncome - totalExpenses;
              final margin = totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0.0;

              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROFIT & LOSS (YTD)', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    _plRow(context, 'Gross Sales', currency.format(grossSales), isPositive: true),
                    _plRow(context, 'Other Income', currency.format(otherIncome), isPositive: true),
                    _plRow(context, 'Cost of Goods', currency.format(cogs), isPositive: false),
                    PermissionWrapper(
                      requiredPermissions: const [AppPermission.viewSalaries],
                      child: _plRow(context, 'Payroll / Salaries', currency.format(salaries), isPositive: false),
                    ),
                    _plRow(context, 'Other Expenses', currency.format(otherExpenses), isPositive: false),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('NET PROFIT', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        Text(currency.format(netProfit), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: netProfit >= 0 ? context.tokens.success : context.colorScheme.error)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Margin: ${margin.toStringAsFixed(1)}%', style: context.textTheme.labelSmall),
                  ],
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text('Error loading finance: $e'),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, s) => Text('Error loading employees: $e'),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, s) => Text('Error loading purchases: $e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error loading sales: $e'),
    );
  }

  Widget _plRow(BuildContext context, String label, String value, {required bool isPositive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            '${isPositive ? '+' : '-'} $value',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPositive ? context.colorScheme.primary : context.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
