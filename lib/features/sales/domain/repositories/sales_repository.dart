import '../../../../core/error/result.dart';
import '../entities/sales_invoice.dart';
import '../entities/sales_quotation.dart';
import '../entities/sales_return.dart';

abstract class SalesRepository {
  Future<Result<bool>> createInvoice(SalesInvoice invoice);
  Future<Result<List<SalesInvoice>>> getRecentInvoices();
  
  // Quotations
  Future<Result<bool>> createQuotation(SalesQuotation quotation);
  Future<Result<List<SalesQuotation>>> getQuotations();
  Future<Result<bool>> convertQuotationToInvoice(String quotationId);
  
  // Returns
  Future<Result<bool>> processReturn(SalesReturn salesReturn);
  Future<Result<List<SalesReturn>>> getReturns();
}
