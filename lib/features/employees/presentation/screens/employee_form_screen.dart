import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_text_field.dart';
import '../providers/employee_provider.dart';
import '../../domain/entities/employee.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final Employee? employee;
  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name);
    _roleController = TextEditingController(text: widget.employee?.role);
    _emailController = TextEditingController(text: widget.employee?.email);
    _phoneController = TextEditingController(text: widget.employee?.phone);
    _salaryController = TextEditingController(text: widget.employee?.salary.replaceAll('₹', '').replaceAll(',', ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newEmployee = Employee(
      id: widget.employee?.id ?? 'EMP-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      salary: '₹${_salaryController.text.trim()}',
      attendanceStatus: widget.employee?.attendanceStatus ?? 'Absent',
    );

    try {
      await ref.read(employeeNotifierProvider.notifier).addEmployee(newEmployee);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEdit = widget.employee != null;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text('${isEdit ? 'EDIT' : 'ADD'} EMPLOYEE'.toUpperCase()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Full Name',
                hint: 'Staff Member Name',
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Designation / Role',
                hint: 'e.g. Sales Manager, Yard Supervisor',
                controller: _roleController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email Address',
                hint: 'name@deshmukhsteel.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Phone Number',
                hint: '+91 XXXXX XXXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Monthly Salary (₹)',
                hint: '0.00',
                controller: _salaryController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: isEdit ? 'Update Profile' : 'Register Employee',
                fullWidth: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
