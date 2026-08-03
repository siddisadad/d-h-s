import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../providers/sales_provider.dart';
import '../../domain/entities/sales_quotation.dart';
import '../widgets/sales_builder_widgets.dart';

class QuotationFormScreen extends ConsumerStatefulWidget {
  final SalesQuotation? quotation;
  const QuotationFormScreen({super.key, this.quotation});

  @override
  ConsumerState<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends ConsumerState<QuotationFormScreen> {
  final _discountController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    if (widget.quotation != null) {
      _discountController.text = widget.quotation!.discount.toString();
      _expiryDate = widget.quotation!.expiryDate;
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: widget.quotation == null ? 'NEW QUOTATION' : 'EDIT QUOTATION',
      );
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(widget.quotation == null ? 'NEW QUOTATION' : 'EDIT QUOTATION')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpirySection(context),
                  const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildExpirySection(BuildContext context) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('VALID UNTIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text(DateFormat('dd MMM yyyy').format(_expiryDate), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _expiryDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) setState(() => _expiryDate = picked);
            },
            icon: const Icon(Icons.event_note_rounded),
            label: const Text('Change Date'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, SalesInvoiceDraft draft) {
    return Container(
      padding: EdgeInsets.all(context.tokens.space24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.5))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'PREVIEW PDF',
                  variant: CustomButtonVariant.outline,
                  icon: Icons.picture_as_pdf_rounded,
                  onPressed: () async {
                    if (draft.items.isEmpty) return;
                    final quotation = SalesQuotation(
                      id: 'DRAFT',
                      customerId: draft.selectedCustomer?.id ?? 'GUEST',
                      customerName: draft.selectedCustomer?.name ?? 'Guest Customer',
                      date: DateTime.now(),
                      expiryDate: _expiryDate,
                      items: draft.items,
                      discount: draft.discount,
                    );
                    final pdfBytes = await ref.read(salesInvoiceNotifierProvider.notifier).generateQuotationPreview(quotation);
                    if (pdfBytes != null) {
                      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'SAVE QUOTATION',
                  onPressed: () => _saveQuotation(draft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveQuotation(SalesInvoiceDraft draft) async {
    if (draft.selectedCustomer == null || draft.items.isEmpty) return;

    final quotation = SalesQuotation(
      id: widget.quotation?.id ?? 'QT-${DateTime.now().millisecondsSinceEpoch}',
      customerId: draft.selectedCustomer!.id,
      customerName: draft.selectedCustomer!.name,
      date: DateTime.now(),
      expiryDate: _expiryDate,
      items: draft.items,
      discount: draft.discount,
    );

    final result = await ref.read(salesRepositoryProvider).createQuotation(quotation);
    if (result.isSuccess && mounted) {
      ref.read(salesInvoiceNotifierProvider.notifier).clearDraft();
      _discountController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation Created!')));
    }
  }
}
