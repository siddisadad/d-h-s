import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/crm_provider.dart';
import '../../domain/entities/contact.dart';

class SupplierDirectoryScreen extends ConsumerWidget {
  const SupplierDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(crmNotifierProvider(ContactType.supplier));
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SUPPLIER DIRECTORY'),
      ),
      body: Column(
        children: [
          _buildSearchHeader(context),
          _buildQuickStats(context),
          Expanded(
            child: suppliersAsync.when(
              data: (list) => ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: tokens.space24),
                itemCount: list.length,
                separatorBuilder: (context, index) => SizedBox(height: tokens.space16),
                itemBuilder: (context, index) => _buildSupplierCard(context, list[index]),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: AppColors.surface,
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
          SizedBox(width: tokens.space16),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.tune_rounded, color: AppColors.primary),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.all(tokens.space24),
      child: Row(
        children: [
          Expanded(child: _statBox(context, 'Total Payable', '₹12.4L', AppColors.error)),
          SizedBox(width: tokens.space16),
          Expanded(child: _statBox(context, 'Active Vendors', '48', AppColors.success)),
        ],
      ),
    );
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
    final tokens = context.tokens;
    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            child: Text(supplier.initials, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: tokens.space16),
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
              Text(supplier.balance, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.error)),
              Text('Outstanding', style: context.textTheme.labelSmall?.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
