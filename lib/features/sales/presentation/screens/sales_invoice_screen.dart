import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import '../providers/sales_provider.dart';
import '../../domain/entities/sales_invoice.dart';
import '../widgets/sales_builder_widgets.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../../../../core/security/permissions.dart';

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
        Padding(
          padding: EdgeInsets.fromLTRB(tokens.space24, tokens.space16, tokens.space24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEW INVOICE',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: context.onSurfaceVariantColor,
                ),
              ),
              if (draft.items.isNotEmpty || draft.selectedCustomer != null)
                TextButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset Draft', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
                ),
            ],
          ),
        ),
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
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: 'CHALLAN',
                  variant: CustomButtonVariant.outline,
                  icon: Icons.assignment_turned_in_rounded,
                  onPressed: () async {
                    if (draft.items.isEmpty) return;
                    final pdfBytes = await ref.read(pdfServiceProvider.notifier).generateDeliveryChallan(
                      SalesInvoice(
                        id: 'DRAFT',
                        customerId: draft.selectedCustomer?.id ?? 'GUEST',
                        customerName: draft.selectedCustomer?.name ?? 'Walking Customer',
                        date: DateTime.now(),
                        items: draft.items,
                        discount: draft.discount,
                      ),
                    );
                    await ref.read(printerServiceProvider.notifier).directPrint(pdfBytes, jobName: 'Yard_Challan');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PermissionWrapper(
            requiredPermissions: const [AppPermission.createInvoice],
            child: CustomButton(
              text: 'GENERATE FINAL INVOICE & QUICK PRINT',
              fullWidth: true,
              onPressed: () async {
                if (draft.selectedCustomer == null || draft.items.isEmpty) return;

                // Credit Limit Check
                final customer = draft.selectedCustomer!;
                final newBalance = customer.balance + draft.grandTotal;
                if (customer.creditLimit > 0 && newBalance > customer.creditLimit) {
                  final proceed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: context.colorScheme.error),
                          const SizedBox(width: 8),
                          const Text('Credit Limit Exceeded'),
                        ],
                      ),
                      content: Text(
                        'This invoice of ₹${draft.grandTotal.toStringAsFixed(2)} will take ${customer.name}\'s balance to ₹${newBalance.toStringAsFixed(2)}, which exceeds their credit limit of ₹${customer.creditLimit.toStringAsFixed(2)}.\n\nDo you want to proceed anyway?',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        CustomButton(
                          text: 'Proceed Anyway',
                          variant: CustomButtonVariant.outline,
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (proceed != true) return;
                }

                final invoice = SalesInvoice(
                  id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                  customerId: draft.selectedCustomer!.id,
                  customerName: draft.selectedCustomer!.name,
                  date: DateTime.now(),
                  items: draft.items,
                  discount: draft.discount,
                );

                final success = await ref.read(salesInvoiceNotifierProvider.notifier).createInvoice(invoice);

                if (success && mounted) {
                  // Auto-print Receipt
                  final pdfBytes = await ref.read(salesInvoiceNotifierProvider.notifier).generateThermalReceiptPreview(invoice);
                  if (pdfBytes != null) {
                    await ref.read(printerServiceProvider.notifier).directPrint(pdfBytes, jobName: 'Sale_Receipt');
                  }

                  ref.read(salesInvoiceNotifierProvider.notifier).clearDraft();
                  _discountController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice Created & Sent to Printer!')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Draft?'),
        content: const Text('Are you sure you want to clear all items and customer details from this invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(salesInvoiceNotifierProvider.notifier).clearDraft();
              _discountController.clear();
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: context.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
