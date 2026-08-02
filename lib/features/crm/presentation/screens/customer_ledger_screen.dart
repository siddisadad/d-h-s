import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/crm_provider.dart';
import '../../domain/entities/contact.dart';

class CustomerLedgerScreen extends ConsumerWidget {
  final String? customerId;
  const CustomerLedgerScreen({super.key, this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CUSTOMER LEDGER'),
      ),
      body: customersAsync.when(
        data: (list) {
          final tokens = context.tokens;
          final customer = list.isNotEmpty ? list.first : null;
          if (customer == null) return const Center(child: Text('No customers found'));

          return SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerHeader(context, customer),
                SizedBox(height: tokens.space24),
                _buildStats(context),
                SizedBox(height: tokens.space24),
                _buildActions(context, customer),
                SizedBox(height: tokens.space32),
                Text('TRANSACTION HISTORY', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                SizedBox(height: tokens.space16),
                _buildTransactionList(context),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCustomerHeader(BuildContext context, Contact customer) {
    final tokens = context.tokens;
    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(customer.initials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 20)),
          ),
          SizedBox(width: tokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: context.textTheme.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
                Text('GSTIN: ${customer.gstin}', style: context.textTheme.bodySmall),
                Text(customer.location, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(
          child: _statCard(context, 'Outstanding', '₹45,820', AppColors.error),
        ),
        SizedBox(width: tokens.space16),
        Expanded(
          child: _statCard(context, 'Credit Limit', '₹1,50,000', AppColors.primary),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(value, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Contact customer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionIcon(context, Icons.picture_as_pdf_outlined, 'Statement', AppColors.primary, () {}),
        _actionIcon(context, Icons.chat_outlined, 'WhatsApp', AppColors.success, () async {
          final url = 'whatsapp://send?phone=${customer.contact.replaceAll(' ', '')}';
          if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
        }),
        _actionIcon(context, Icons.payments_outlined, 'Record Pay', AppColors.accent, () {}),
        _actionIcon(context, Icons.notifications_none_rounded, 'Remind', AppColors.warning, () {}),
      ],
    );
  }

  Widget _actionIcon(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _transactionItem(context, '22 May 2024', 'Sales Invoice #SI-882', '₹12,400', true),
          const Divider(height: 1),
          _transactionItem(context, '18 May 2024', 'Payment Received #PAY-912', '₹5,000', false),
        ],
      ),
    );
  }

  Widget _transactionItem(BuildContext context, String date, String ref, String amount, bool isDebit) {
    return ListTile(
      title: Text(ref, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(date, style: context.textTheme.bodySmall),
      trailing: Text(
        (isDebit ? '+' : '-') + ' ' + amount,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDebit ? AppColors.error : AppColors.success,
        ),
      ),
    );
  }
}
