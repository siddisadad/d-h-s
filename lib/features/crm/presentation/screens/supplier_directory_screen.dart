import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_text_field.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/presentation/providers/crm_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/domain/entities/contact.dart';
import 'package:deshmukh_steel_e_r_p/core/security/permissions.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/permission_wrapper.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';


class SupplierDirectoryScreen extends ConsumerWidget {
  const SupplierDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(crmNotifierProvider(ContactType.supplier));
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'SUPPLIER DIRECTORY',
        actions: [
          PermissionWrapper(
            requiredPermissions: const [AppPermission.manageContacts],
            child: CustomButton(
              text: 'Add Supplier',
              variant: CustomButtonVariant.primary,
              icon: Icons.add_business_rounded,
              onPressed: () => _showAddSupplierDialog(context, ref),
            ),
          ),
        ],
      );
    });
// ...

    return Column(
      children: [
        _buildSearchHeader(context),
        suppliersAsync.when(
          data: (list) => _buildQuickStats(context, list),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: suppliersAsync.when(
            data: (list) => ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: tokens.space24),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildSupplierCard(context, list[index]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: context.colorScheme.surface,
      padding: EdgeInsets.all(tokens.space24),
      child: Row(
        children: [
          const Expanded(
            child: CustomTextField(
              label: 'Search Suppliers',
              hint: 'Search by Name or GSTIN...',
              prefixIcon: Icons.search_rounded,
            ),
          ),
          const SizedBox(width: 16),
          _filterButton(context),
        ],
      ),
    );
  }

  Widget _filterButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Icon(Icons.tune_rounded, color: context.colorScheme.primary),
    );
  }

  Widget _buildQuickStats(BuildContext context, List<Contact> suppliers) {
    final tokens = context.tokens;
    final totalPayable = suppliers.fold(0.0, (sum, s) => sum + s.balance);

    return Padding(
      padding: EdgeInsets.all(tokens.space24),
      child: Row(
        children: [
          Expanded(child: _statBox(context, 'Total Payable', _formatLargeValue(totalPayable), context.colorScheme.error)),
          const SizedBox(width: 16),
          Expanded(child: _statBox(context, 'Active Vendors', suppliers.length.toString(), context.tokens.success)),
        ],
      ),
    );
  }

  String _formatLargeValue(double value) {
    final val = value.abs();
    if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(1)}L';
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(val);
  }

  Widget _statBox(BuildContext context, String label, String value, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.textTheme.labelSmall),
          SizedBox(height: context.tokens.space4),
          Text(value, style: context.textTheme.headlineMedium?.copyWith(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, Contact supplier) {
    return CustomCard(
      onTap: () => context.go('/suppliers/${supplier.id}'),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colorScheme.secondary.withValues(alpha: 0.1),
            child: Text(
              supplier.initials,
              style: TextStyle(color: context.colorScheme.secondary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('GSTIN: ${supplier.gstin}', style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(supplier.balance),
                style: TextStyle(fontWeight: FontWeight.w700, color: context.colorScheme.error),
              ),
              Text('Outstanding', style: context.textTheme.labelSmall?.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context, WidgetRef ref) {
    context.push('/suppliers/new');
  }
}
