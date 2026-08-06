import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import '../providers/employee_provider.dart';
import '../../../../core/providers/app_bar_provider.dart';


class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeeNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'MARK ATTENDANCE',
      );
    });

    return employeesAsync.when(
      data: (list) => ListView.builder(
        padding: EdgeInsets.all(tokens.space24),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final emp = list[index];
          final isPresent = emp.attendanceStatus == 'Present';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(emp.name[0], style: TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(emp.role, style: context.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, emp.attendanceStatus),
                  const SizedBox(width: 12),
                  Switch(
                    value: isPresent,
                    activeThumbColor: context.tokens.success,
                    onChanged: (val) {
                      ref.read(employeeNotifierProvider.notifier).updateAttendance(
                        emp.id, 
                        val ? 'Present' : 'Absent',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final isPresent = status == 'Present';
    final color = isPresent ? context.tokens.success : context.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
