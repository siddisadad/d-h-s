import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/sales_history_provider.dart';
import '../../domain/entities/sales_invoice.dart';
import '../providers/sales_provider.dart';
import '../../../../core/services/sharing_service.dart';
import '../../../crm/presentation/providers/crm_provider.dart';
import '../../../crm/domain/entities/contact.dart';

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(salesHistoryProvider);
    final tokens = context.tokens;

    return historyAsync.when(
      data: (invoices) {
        if (invoices.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history_rounded,
            title: 'No Invoices Yet',
            message: 'All your completed sales will appear here. You can share or print them anytime.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(tokens.space24),
          itemCount: invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return _InvoiceHistoryCard(invoice: invoice);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

class _InvoiceHistoryCard extends ConsumerWidget {
  final SalesInvoice invoice;
  const _InvoiceHistoryCard({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return CustomCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('INV: ${invoice.id} • ${DateFormat('dd MMM yyyy').format(invoice.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currency.format(invoice.grandTotal),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.share_outlined, color: context.colorScheme.secondary),
              onPressed: () => _shareToWhatsApp(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _shareToWhatsApp(BuildContext context, WidgetRef ref) async {
    final pdfBytes = await ref.read(salesInvoiceNotifierProvider.notifier).generatePdfPreview(invoice);
    if (pdfBytes == null) return;

    final customers = await ref.read(crmNotifierProvider(ContactType.customer).future);
    final customer = customers.firstWhere((c) => c.id == invoice.customerId, orElse: () => null as dynamic);

    if (customer != null && customer.contact.isNotEmpty) {
       final message = 'Namaste ${customer.name},\n\nPlease find your invoice *#${invoice.id}* from *Deshmukh Hardware & Steel* for the amount of *₹${invoice.grandTotal.toStringAsFixed(0)}*.\n\nThank you for your business!';

       await ref.read(sharingServiceProvider.notifier).sendWhatsAppMessage(
         phone: customer.contact,
         message: message,
       );

       // Note: In a real mobile app, we would share the actual PDF file here using share_plus.
       // For this environment, we're launching the WhatsApp intent with the summary.
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp launched with Invoice details')));
       }
    }
  }
}
