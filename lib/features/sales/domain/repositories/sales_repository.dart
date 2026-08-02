import '../../../../core/error/result.dart';
import '../entities/sales_invoice.dart';

abstract class SalesRepository {
  Future<Result<bool>> createInvoice(SalesInvoice invoice);
  Future<Result<List<SalesInvoice>>> getRecentInvoices();
}
