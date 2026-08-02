import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../providers/sales_provider.dart';
import '../../../crm/presentation/providers/crm_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../crm/domain/entities/contact.dart';
import '../../domain/entities/sales_invoice.dart';
import '../../domain/entities/invoice_item.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NEW SALES INVOICE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerSection(context, draft),
            SizedBox(height: tokens.space24),
            _buildItemsSection(context, draft),
            SizedBox(height: tokens.space24),
            _buildSummarySection(context, draft),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, draft),
    );
  }

  Widget _buildCustomerSection(BuildContext context, SalesInvoiceDraft draft) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CUSTOMER DETAILS',
          style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
        SizedBox(height: tokens.space12),
        if (draft.selectedCustomer == null)
          CustomButton(
            text: 'Select Customer',
            variant: CustomButtonVariant.outline,
            icon: Icons.person_add_alt_1_rounded,
            fullWidth: true,
            onPressed: () => _showCustomerSelection(context),
          )
        else
          CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(draft.selectedCustomer!.initials, style: const TextStyle(color: AppColors.primary)),
                ),
                SizedBox(width: tokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(draft.selectedCustomer!.name, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text('GSTIN: ${draft.selectedCustomer!.gstin}', style: context.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showCustomerSelection(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.error),
                  onPressed: () => ref.read(salesInvoiceNotifierProvider.notifier).setSelectedCustomer(null),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showCustomerSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomerSelectionSheet(),
    );
  }

  Widget _buildItemsSection(BuildContext context, SalesInvoiceDraft draft) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INVOICE ITEMS',
              style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
            TextButton.icon(
              onPressed: () => _showProductSelection(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Item'),
            ),
          ],
        ),
        SizedBox(height: tokens.space12),
        if (draft.items.isEmpty)
          CustomCard(
            padding: EdgeInsets.all(tokens.space32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.disabled.withValues(alpha: 0.5)),
                  SizedBox(height: tokens.space12),
                  const Text('No items added to this invoice'),
                ],
              ),
            ),
          )
        else
          ...draft.items.asMap().entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: tokens.space12),
            child: _buildItemCard(context, entry.value, entry.key),
          )),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, InvoiceItem item, int index) {
    final tokens = context.tokens;
    return CustomCard(
      padding: EdgeInsets.all(tokens.space12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '₹${item.price.toStringAsFixed(2)} x ${item.qty}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.subtotal.toStringAsFixed(2)}',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              Text(
                'GST (${item.gstRate}%)',
                style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
          SizedBox(width: tokens.space12),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: () => ref.read(salesInvoiceNotifierProvider.notifier).removeItem(index),
          ),
        ],
      ),
    );
  }

  void _showProductSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductSelectionSheet(),
    );
  }

  Widget _buildSummarySection(BuildContext context, SalesInvoiceDraft draft) {
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');

    return CustomCard(
      color: AppColors.primary.withValues(alpha: 0.02),
      padding: EdgeInsets.all(tokens.space20),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', currency.format(draft.subtotal)),
          SizedBox(height: tokens.space8),
          _buildSummaryRow('Total GST', currency.format(draft.totalGst)),
          SizedBox(height: tokens.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _discountController,
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: (val) {
                    final d = double.tryParse(val) ?? 0;
                    ref.read(salesInvoiceNotifierProvider.notifier).updateDiscount(d);
                  },
                ),
              ),
            ],
          ),
          Divider(height: tokens.space32, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GRAND TOTAL', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(
                currency.format(draft.grandTotal),
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, SalesInvoiceDraft draft) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.space24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
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
              SizedBox(width: tokens.space8),
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
              SizedBox(width: tokens.space8),
              Expanded(
                child: CustomButton(
                  text: 'WHATSAPP',
                  variant: CustomButtonVariant.secondary,
                  icon: Icons.chat_outlined,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space16),
          CustomButton(
            text: 'GENERATE FINAL INVOICE',
            fullWidth: true,
            onPressed: () async {
              if (draft.selectedCustomer == null || draft.items.isEmpty) return;
              final success = await ref.read(salesInvoiceNotifierProvider.notifier).createInvoice(
                SalesInvoice(
                  id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                  customerName: draft.selectedCustomer!.name,
                  date: DateTime.now(),
                  items: draft.items,
                  discount: draft.discount,
                ),
              );
              if (success && mounted) {
                ref.read(salesInvoiceNotifierProvider.notifier).clearDraft();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice Created!')));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CustomerSelectionSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));
    final tokens = context.tokens;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.space24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SELECT CUSTOMER', style: context.textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final c = list[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.initials)),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.gstin),
                    onTap: () {
                      ref.read(salesInvoiceNotifierProvider.notifier).setSelectedCustomer(c);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSelectionSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryNotifierProvider);
    final tokens = context.tokens;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.space24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ADD PRODUCT', style: context.textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final p = list[index];
                  return ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('SKU: ${p.sku} • Stock: ${p.stock}'),
                    trailing: Text(p.price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    onTap: () {
                      ref.read(salesInvoiceNotifierProvider.notifier).addItem(InvoiceItem(
                        name: p.name,
                        price: double.parse(p.price.replaceAll('₹', '').replaceAll(',', '')),
                        qty: 1,
                        gstRate: 18,
                      ));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
