import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';
import '../providers/employee_provider.dart';
import '../../../../features/finance/presentation/providers/finance_provider.dart';
import '../../../../core/providers/app_bar_provider.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeeNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'MONTHLY PAYROLL',
      );
    });

    return employeesAsync.when(
      data: (list) {
        final totalPayroll = list.fold(0.0, (sum, e) => sum + (double.tryParse(e.salary.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0));
        
        return Column(
          children: [
            _buildPayrollSummary(context, totalPayroll),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(tokens.space24),
                itemCount: list.length,
                itemBuilder: (context, index) => _buildEmployeePayrollCard(context, list[index], ref),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPayrollSummary(BuildContext context, double total) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.space24),
      color: context.colorScheme.surface,
      child: CustomCard(
        color: context.colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL MONTHLY PAYROLL', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(total), 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
            PermissionWrapper(
              requiredPermissions: const [AppPermission.manageTransactions],
              child: CustomButton(
                text: 'Process All',
                variant: CustomButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeePayrollCard(BuildContext context, dynamic emp, WidgetRef ref) {
    final salary = double.tryParse(emp.salary.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Basic Salary: ${emp.salary}', style: context.textTheme.labelSmall),
                ],
              ),
            ),
            PermissionWrapper(
              requiredPermissions: const [AppPermission.manageTransactions],
              child: CustomButton(
                text: 'Pay Salary',
                variant: CustomButtonVariant.outline,
                onPressed: () => _paySalary(context, ref, emp.name, salary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _paySalary(BuildContext context, WidgetRef ref, String name, double amount) async {
    await ref.read(financeNotifierProvider.notifier).addTransaction(
      title: 'Salary: $name',
      category: 'Expense',
      amount: amount,
      paymentMode: 'Bank Transfer',
    );
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processed salary for $name: ₹$amount'))
      );
    }
  }
}
