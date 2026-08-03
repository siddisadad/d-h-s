import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/sales_quotations_provider.dart';
import 'quotation_form_screen.dart';
import '../../domain/entities/sales_quotation.dart';
import '../providers/sales_provider.dart';
import '../../../crm/presentation/providers/crm_provider.dart';
import '../../../crm/domain/entities/contact.dart';

class SalesQuotesScreen extends ConsumerWidget {
  const SalesQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(salesQuotationsProvider);
    final tokens = context.tokens;

    return quotesAsync.when(
      data: (quotes) {
        if (quotes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.request_page_outlined,
            title: 'No Quotations Yet',
            message: 'Create and manage professional quotes for your customers. This module helps you track pending offers and convert them to invoices.',
            actionLabel: 'Create Your First Quote',
            onAction: () => context.push('/sales/new-quote'),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(tokens.space24),
          itemCount: quotes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final quote = quotes[index];
            return Card(
              child: ListTile(
                title: Text(quote.customerName, style: context.textTheme.titleMedium),
                subtitle: Text('ID: ${quote.id} • Expiry: ${DateFormat('dd MMM yyyy').format(quote.expiryDate)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${quote.grandTotal.toStringAsFixed(0)}', style: context.textTheme.titleMedium?.copyWith(color: context.colorScheme.primary)),
                        _buildStatusChip(context, quote.status.name),
                      ],
                    ),
                    if (quote.status == QuotationStatus.pending)
                      IconButton(
                        icon: const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                        tooltip: 'Convert to Invoice',
                        onPressed: () => _convertToInvoice(context, ref, quote),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted': color = Colors.green; break;
      case 'sent': color = Colors.blue; break;
      case 'expired': color = Colors.red; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status.toUpperCase(), style: context.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }

  void _convertToInvoice(BuildContext context, WidgetRef ref, SalesQuotation quote) async {
    final customers = await ref.read(crmNotifierProvider(ContactType.customer).future);
    final customer = customers.firstWhere((c) => c.id == quote.customerId, orElse: () => null as dynamic);
    
    ref.read(salesInvoiceNotifierProvider.notifier).loadFromQuotation(quote, customer);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation loaded into Invoice Draft')));
  }
}
