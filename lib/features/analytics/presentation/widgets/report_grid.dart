import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/services/excel_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../purchases/presentation/providers/purchase_history_provider.dart';
import '../../../../features/inventory/presentation/providers/inventory_provider.dart';
import '../../../employees/presentation/providers/employee_provider.dart';
import '../../../finance/presentation/providers/finance_provider.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../../../../core/security/permissions.dart';
import 'package:printing/printing.dart';

class ReportGrid extends ConsumerWidget {
  const ReportGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = [
      {'icon': Icons.trending_up, 'label': 'Sales Register', 'action': 'sales'},
      {'icon': Icons.shopping_cart_checkout, 'label': 'Purchase Register', 'action': 'purchases'},
      {'icon': Icons.inventory_2, 'label': 'Stock Ledger', 'action': 'inventory'},
      {'icon': Icons.account_balance, 'label': 'Profit & Loss', 'action': 'pl'},
      {'icon': Icons.pie_chart, 'label': 'GST Reports', 'action': 'gst'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: reports.map((r) {
        final action = r['action'] as String;
        final List<AppPermission> requiredPermissions = [];
        if (action == 'pl') {
          requiredPermissions.add(AppPermission.viewFinance);
        } else {
          requiredPermissions.add(AppPermission.exportData);
        }

        return PermissionWrapper(
          requiredPermissions: requiredPermissions,
          child: CustomCard(
            onTap: () => _handleReportAction(context, ref, action),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(r['icon'] as IconData,
                    color: context.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleReportAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'sales':
        final sales = ref.read(salesHistoryProvider).value ?? [];
        ref.read(excelServiceProvider.notifier).exportSalesReport(sales);
        break;
      case 'purchases':
        final purchases = ref.read(purchaseHistoryProvider).value ?? [];
        ref.read(excelServiceProvider.notifier).exportPurchaseReport(purchases);
        break;
      case 'inventory':
        final products = ref.read(inventoryNotifierProvider).value ?? [];
        ref.read(excelServiceProvider.notifier).exportInventory(products);
        break;
      case 'pl':
        _generatePlPdf(context, ref);
        break;
      case 'gst':
        final sales = ref.read(salesHistoryProvider).value ?? [];
        ref.read(excelServiceProvider.notifier).exportGstReport(sales);
        break;
    }
  }

  Future<void> _generatePlPdf(BuildContext context, WidgetRef ref) async {
    final sales = ref.read(salesHistoryProvider).value ?? [];
    final purchases = ref.read(purchaseHistoryProvider).value ?? [];
    final employees = ref.read(employeeNotifierProvider).value ?? [];
    final transactions = ref.read(financeNotifierProvider).value ?? [];

    final grossSales = sales.fold(0.0, (sum, s) => sum + s.grandTotal);
    final cogs = purchases.fold(0.0, (sum, p) => sum + p.grandTotal);
    final salaries = employees.fold(0.0, (sum, e) => sum + (double.tryParse(e.salary.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0));
    final otherIncome = transactions.where((t) => t.category == 'Income').fold(0.0, (sum, t) => sum + t.amount);
    final otherExpenses = transactions.where((t) => t.category == 'Expense').fold(0.0, (sum, t) => sum + t.amount);

    final totalIncome = grossSales + otherIncome;
    final totalExpenses = cogs + salaries + otherExpenses;
    final netProfit = totalIncome - totalExpenses;
    final margin = totalIncome > 0 ? (netProfit / totalIncome) * 100 : 0.0;

    final pdfBytes = await ref.read(pdfServiceProvider.notifier).generateProfitAndLossReport(
      grossSales: grossSales,
      otherIncome: otherIncome,
      cogs: cogs,
      salaries: salaries,
      otherExpenses: otherExpenses,
      netProfit: netProfit,
      margin: margin,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
