import '../../../../components/base_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/presentation/providers/crm_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/presentation/providers/ledger_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/domain/entities/contact.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/services/pdf_service.dart';
import 'package:deshmukh_steel_e_r_p/core/services/sharing_service.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class CustomerLedgerScreen extends ConsumerWidget {
  final String? customerId;
  const CustomerLedgerScreen({super.key, this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));

    return customersAsync.when(
      data: (list) {
        final tokens = context.tokens;
        // Find the specific customer by ID, or default to the first one for demonstration
        final customer = customerId != null 
          ? list.firstWhere((c) => c.id == customerId, orElse: () => list.first)
          : (list.isNotEmpty ? list.first : null);

        if (customer == null) return const Center(child: Text('Customer not found'));

        // Update Global AppBar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(appBarNotifierProvider.notifier).update(
            title: customer.name.toUpperCase(),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _showShareOptions(context, ref, customer),
                tooltip: 'Share Statement',
              ),
            ],
          );
        });

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerHeader(context, customer),
              const SizedBox(height: 24),
              _buildStats(context, customer),
              const SizedBox(height: 24),
              _buildActions(context, ref, customer),
              const SizedBox(height: 32),
              Text('TRANSACTION HISTORY', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              _buildTransactionList(context, ref, customer.id),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildCustomerHeader(BuildContext context, Contact customer) {
    return CustomCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              customer.initials,
              style: TextStyle(fontWeight: FontWeight.bold, color: context.colorScheme.primary, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
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

  Widget _buildStats(BuildContext context, Contact customer) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context, 
            'Outstanding', 
            NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(customer.balance), 
            context.colorScheme.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(context, 'Credit Limit', '₹1,50,000', context.colorScheme.primary),
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

  Widget _buildActions(BuildContext context, WidgetRef ref, Contact customer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionIcon(context, Icons.picture_as_pdf_outlined, 'Statement', context.colorScheme.primary, () async {
          final entries = await ref.read(ledgerNotifierProvider(customer.id).future);
          final pdfBytes = await ref.read(pdfServiceProvider.notifier).generateLedgerStatement(customer, entries);
          await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
        }),
        _actionIcon(context, Icons.chat_outlined, 'WhatsApp', context.tokens.success, () async {
          final url = 'whatsapp://send?phone=${customer.contact.replaceAll(' ', '')}';
          if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
        }),
        _actionIcon(context, Icons.payments_outlined, 'Record Pay', context.colorScheme.tertiary, () {}),
        _actionIcon(context, Icons.notifications_none_rounded, 'Remind', context.tokens.warning, () {}),
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

  Widget _buildTransactionList(BuildContext context, WidgetRef ref, String customerId) {
    final ledgerAsync = ref.watch(ledgerNotifierProvider(customerId));

    return CustomCard(
      padding: EdgeInsets.zero,
      child: ledgerAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No transactions found')),
            );
          }
          return Column(
            children: List.generate(entries.length, (index) {
              final entry = entries[index];
              return BaseListItem(
                title: '${entry.type} #${entry.ref}',
                subtitle: DateFormat('dd MMM yyyy').format(entry.date),
                trailing: _amountText(context, NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(entry.amount), entry.isDebit),
                leadingIcon: entry.isDebit ? Icons.description_rounded : Icons.payments_rounded,
                leadingIconColor: entry.isDebit ? context.colorScheme.error : context.tokens.success,
                leadingBackgroundColor: (entry.isDebit ? context.colorScheme.error : context.tokens.success).withValues(alpha: 0.1),
                showDivider: index < entries.length - 1,
              );
            }),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _amountText(BuildContext context, String amount, bool isDebit) {
    return Text(
      (isDebit ? '+' : '-') + ' ' + amount,
      style: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: isDebit ? context.colorScheme.error : context.tokens.success,
      ),
    );
  }

  void _showShareOptions(BuildContext context, WidgetRef ref, Contact customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SHARE STATEMENT', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: context.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.picture_as_pdf_rounded, color: context.colorScheme.primary),
              ),
              title: const Text('Share as PDF'),
              subtitle: const Text('Branded statement with transaction history'),
              onTap: () async {
                Navigator.pop(context);
                final entries = await ref.read(ledgerNotifierProvider(customer.id).future);
                final pdfBytes = await ref.read(pdfServiceProvider.notifier).generateLedgerStatement(customer, entries);
                await ref.read(sharingServiceProvider.notifier).shareFile(
                  pdfBytes,
                  'Statement_${customer.name}_${DateTime.now().millisecondsSinceEpoch}.pdf',
                  phoneNumber: customer.contact,
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: context.tokens.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.text_fields_rounded, color: context.tokens.success),
              ),
              title: const Text('Share as Text Summary'),
              subtitle: const Text('Quick balance summary for WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                final summary = 'Hello ${customer.name},\n\n'
                    'This is a summary of your account with Deshmukh Hardware & Steel.\n'
                    'Current Outstanding Balance: ₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0).format(customer.balance)}\n\n'
                    'Please settle the dues at your earliest convenience.\n\n'
                    'Thank you!';
                await ref.read(sharingServiceProvider.notifier).shareText(summary);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
