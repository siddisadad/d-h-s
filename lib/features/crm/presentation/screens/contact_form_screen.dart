import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_text_field.dart';
import '../providers/crm_provider.dart';
import '../../domain/entities/contact.dart';

class ContactFormScreen extends ConsumerStatefulWidget {
  final ContactType type;
  final Contact? contact;

  const ContactFormScreen({super.key, required this.type, this.contact});

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _gstinController;
  late TextEditingController _locationController;
  late TextEditingController _balanceController;
  late TextEditingController _creditLimitController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _contactController = TextEditingController(text: widget.contact?.contact);
    _gstinController = TextEditingController(text: widget.contact?.gstin);
    _locationController = TextEditingController(text: widget.contact?.location);
    _balanceController = TextEditingController(text: widget.contact?.balance.toString() ?? '0');
    _creditLimitController = TextEditingController(text: widget.contact?.creditLimit.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _gstinController.dispose();
    _locationController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name[0].toUpperCase();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newContact = Contact(
      id: widget.contact?.id ?? 'CON-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      initials: _getInitials(_nameController.text.trim()),
      contact: _contactController.text.trim(),
      gstin: _gstinController.text.trim().toUpperCase(),
      balance: double.tryParse(_balanceController.text.trim()) ?? 0,
      creditLimit: double.tryParse(_creditLimitController.text.trim()) ?? 0,
      location: _locationController.text.trim(),
      type: widget.type,
    );

    try {
      if (widget.contact == null) {
        await ref.read(crmNotifierProvider(widget.type).notifier).addContact(newContact);
      } else {
        await ref.read(crmNotifierProvider(widget.type).notifier).updateContact(newContact);
      }
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
    final isEdit = widget.contact != null;
    final typeLabel = widget.type == ContactType.customer ? 'Customer' : 'Supplier';

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: Text('${isEdit ? 'EDIT' : 'ADD'} $typeLabel'.toUpperCase()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: '$typeLabel Name',
                hint: 'Full Business Name',
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Phone Number',
                hint: 'Primary Contact No',
                controller: _contactController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'GSTIN',
                hint: 'e.g. 27AAAAA0000A1Z5',
                controller: _gstinController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Location / City',
                hint: 'e.g. Pune, Maharashtra',
                controller: _locationController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Initial Balance (₹)',
                hint: '0.00',
                controller: _balanceController,
                keyboardType: TextInputType.number,
                enabled: !isEdit, // Only set initial balance on create
              ),
              if (widget.type == ContactType.customer) ...[
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Credit Limit (₹)',
                  hint: '0.00',
                  controller: _creditLimitController,
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(
                text: isEdit ? 'Update Details' : 'Create Account',
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
