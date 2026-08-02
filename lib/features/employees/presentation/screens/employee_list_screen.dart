import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../providers/employee_provider.dart';
import '../../domain/entities/employee.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeeNotifierProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EMPLOYEE MANAGEMENT'),
        actions: [
          CustomButton(
            text: 'Add Employee',
            icon: Icons.person_add_rounded,
            onPressed: () {},
          ),
          SizedBox(width: tokens.space16),
        ],
      ),
      body: employeesAsync.when(
        data: (employees) => ListView.separated(
          padding: EdgeInsets.all(tokens.space24),
          itemCount: employees.length,
          separatorBuilder: (context, index) => SizedBox(height: tokens.space16),
          itemBuilder: (context, index) => _buildEmployeeCard(context, ref, employees[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, WidgetRef ref, Employee employee) {
    final tokens = context.tokens;
    final isPresent = employee.attendanceStatus == 'Present';

    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(employee.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              SizedBox(width: tokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(employee.role, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              _buildAttendanceBadge(context, employee.attendanceStatus),
            ],
          ),
          Divider(height: tokens.space24, color: context.theme.dividerColor.withValues(alpha: 0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTACT', style: context.textTheme.labelSmall?.copyWith(fontSize: 10, letterSpacing: 1.1)),
                  Text(employee.phone, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              PermissionWrapper(
                allowedRoles: const ['Admin'],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SALARY', style: context.textTheme.labelSmall?.copyWith(fontSize: 10, letterSpacing: 1.1)),
                    Text('₹${employee.salary}', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.success)),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle_outline, color: isPresent ? AppColors.success : AppColors.disabled),
                    onPressed: () => ref.read(employeeNotifierProvider.notifier).updateAttendance(employee.id, 'Present'),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_outlined, color: !isPresent ? AppColors.error : AppColors.disabled),
                    onPressed: () => ref.read(employeeNotifierProvider.notifier).updateAttendance(employee.id, 'Absent'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBadge(BuildContext context, String status) {
    final color = status == 'Present' ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
