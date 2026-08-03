import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/providers/app_bar_provider.dart';
import '../providers/sales_provider.dart';
import '../../domain/entities/sales_return.dart';
import '../widgets/sales_builder_widgets.dart';

class ReturnFormScreen extends ConsumerStatefulWidget {
  const ReturnFormScreen({super.key});

  @override
  ConsumerState<ReturnFormScreen> createState() => _ReturnFormScreenState();
}

class _ReturnFormScreenState extends ConsumerState<ReturnFormScreen> {
  final _invoiceIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _dummyDiscountController = TextEditingController();

  @override
  void dispose() {
    _invoiceIdController.dispose();
    _reasonController.dispose();
    _dummyDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(salesInvoiceNotifierProvider);
    final tokens = context.tokens;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(title: 'PROCESS RETURN');
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('PROCESS RETURN')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.space24),
              child: Column(
                children: [
                  CustomCard(
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Original Invoice ID',
                          controller: _invoiceIdController,
                          hint: 'SI-XXXX',
                          prefixIcon: Icons.receipt_long_rounded,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Return Reason',
                          controller: _reasonController,
                          maxLines: 2,
                          hint: 'e.g. Damaged during transit',
                          prefixIcon: Icons.info_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CustomerSelector(),
                  const SizedBox(height: 24),
                  const InvoiceItemsList(),
                  const SizedBox(height: 24),
                  InvoiceSummarySection(discountController: _dummyDiscountController),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, draft),
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
      child: CustomButton(
        text: 'GENERATE CREDIT NOTE',
        fullWidth: true,
        variant: CustomButtonVariant.primary,
        onPressed: () => _processReturn(draft),
      ),
    );
  }

  void _processReturn(SalesInvoiceDraft draft) async {
    if (draft.selectedCustomer == null || draft.items.isEmpty) return;

    final salesReturn = SalesReturn(
      id: 'RET-${DateTime.now().millisecondsSinceEpoch}',
      originalInvoiceId: _invoiceIdController.text,
      customerId: draft.selectedCustomer!.id,
      customerName: draft.selectedCustomer!.name,
      date: DateTime.now(),
      items: draft.items,
      reason: _reasonController.text,
      grandTotal: draft.grandTotal,
    );

    final result = await ref.read(salesRepositoryProvider).processReturn(salesReturn);
    if (result.isSuccess && mounted) {
      ref.read(salesInvoiceNotifierProvider.notifier).clearDraft();
      _dummyDiscountController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return Processed Successfully!')));
    }
  }
}
