import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import '../providers/sales_provider.dart';
import '../../domain/entities/sales_invoice.dart';
import '../widgets/sales_builder_widgets.dart';

class SalesInvoiceScreen extends ConsumerStatefulWidget {
  final String? invoiceId;
  const SalesInvoiceScreen({super.key, this.invoiceId});

  @override
  ConsumerState<SalesInvoiceScreen> createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends ConsumerState<SalesInvoiceScreen> {
  final _discountController = TextEditingController();

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomerSelector(),
                const SizedBox(height: 24),
                const InvoiceItemsList(),
                const SizedBox(height: 24),
                InvoiceSummarySection(discountController: _discountController),
              ],
            ),
          ),
        ),
        _buildBottomBar(context, draft),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, SalesInvoiceDraft draft) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.space24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(top: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.5))),
        boxShadow: [tokens.shadowLg],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'PDF',
                  variant: CustomButtonVariant.outline,
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () async {
                    if (draft.items.isEmpty) return;
                    final pdfBytes = await ref.read(salesInvoiceNotifierProvider.notifier).generatePdfPreview(
                      SalesInvoice(
                        id: 'DRAFT',
                        customerId: draft.selectedCustomer?.id ?? 'GUEST',
                        customerName: draft.selectedCustomer?.name ?? 'Walking Customer',
                        date: DateTime.now(),
                        items: draft.items,
                        discount: draft.discount,
                      ),
                    );
                    if (pdfBytes != null) {
                      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: 'RECEIPT',
                  variant: CustomButtonVariant.outline,
                  icon: Icons.receipt_long_rounded,
                  onPressed: () async {
                    if (draft.items.isEmpty) return;
                    final pdfBytes = await ref.read(salesInvoiceNotifierProvider.notifier).generateThermalReceiptPreview(
                      SalesInvoice(
                        id: 'DRAFT',
                        customerId: draft.selectedCustomer?.id ?? 'GUEST',
                        customerName: draft.selectedCustomer?.name ?? 'Walking Customer',
                        date: DateTime.now(),
                        items: draft.items,
                        discount: draft.discount,
                      ),
                    );
                    if (pdfBytes != null) {
                      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'GENERATE FINAL INVOICE',
            fullWidth: true,
            onPressed: () async {
              if (draft.selectedCustomer == null || draft.items.isEmpty) return;
              final success = await ref.read(salesInvoiceNotifierProvider.notifier).createInvoice(
                SalesInvoice(
                  id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                  customerId: draft.selectedCustomer!.id,
                  customerName: draft.selectedCustomer!.name,
                  date: DateTime.now(),
                  items: draft.items,
                  discount: draft.discount,
                ),
              );
              if (success && mounted) {
                ref.read(salesInvoiceNotifierProvider.notifier).clearDraft();
                _discountController.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice Created!')));
              }
            },
          ),
        ],
      ),
    );
  }
}
