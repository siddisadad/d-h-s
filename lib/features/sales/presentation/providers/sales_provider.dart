import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/sales_invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/usecases/create_invoice.dart';
import '../../../crm/domain/entities/contact.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../dashboard/presentation/providers/activity_provider.dart';
import '../../../dashboard/domain/entities/activity.dart';

part 'sales_provider.g.dart';

@riverpod
SalesRepository salesRepository(SalesRepositoryRef ref) => sl.salesRepository;

@riverpod
CreateInvoice createInvoiceUseCase(CreateInvoiceUseCaseRef ref) => sl.createInvoiceUseCase;

@riverpod
class SalesInvoiceNotifier extends _$SalesInvoiceNotifier {
  @override
  SalesInvoiceDraft build() {
    return SalesInvoiceDraft(
      items: [],
      discount: 0,
    );
  }

  void setSelectedCustomer(Contact? customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void addItem(InvoiceItem item) {
    final updatedItems = [...state.items, item];
    state = state.copyWith(items: updatedItems);
  }

  void removeItem(int index) {
    final updatedItems = List<InvoiceItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: updatedItems);
  }

  void updateDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  Future<bool> createInvoice(SalesInvoice invoice) async {
    final useCase = ref.read(createInvoiceUseCaseProvider);
    final result = await useCase(invoice);
    
    return result.fold(
      (failure) {
        Log.e('Create Invoice Failed', error: failure.message, name: 'Sales');
        return false;
      },
      (success) {
        // Audit Log (In-Memory)
        ref.read(activityNotifierProvider.notifier).addActivity(
          'New Sale Created',
          '${invoice.customerName} - ₹${invoice.grandTotal.toStringAsFixed(0)}',
          ActivityType.sale,
        );

        return true;
      },
    );
  }

  Future<Uint8List?> generatePdfPreview(SalesInvoice invoice) async {
    return ref.read(pdfServiceProvider.notifier).generateInvoice(invoice);
  }

  Future<Uint8List?> generateThermalReceiptPreview(SalesInvoice invoice) async {
    return ref.read(pdfServiceProvider.notifier).generateThermalReceipt(invoice);
  }

  void clearDraft() {
    state = SalesInvoiceDraft(items: [], discount: 0);
  }
}

class SalesInvoiceDraft {
  final Contact? selectedCustomer;
  final List<InvoiceItem> items;
  final double discount;

  SalesInvoiceDraft({
    this.selectedCustomer,
    required this.items,
    required this.discount,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get totalGst => items.fold(0, (sum, item) => sum + (item.subtotal * (item.gstRate / 100)));
  double get grandTotal => subtotal + totalGst - discount;

  SalesInvoiceDraft copyWith({
    Contact? selectedCustomer,
    List<InvoiceItem>? items,
    double? discount,
  }) {
    return SalesInvoiceDraft(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      items: items ?? this.items,
      discount: discount ?? this.discount,
    );
  }
}
