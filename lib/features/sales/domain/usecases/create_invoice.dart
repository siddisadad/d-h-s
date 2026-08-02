import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sales_invoice.dart';
import '../repositories/sales_repository.dart';

class CreateInvoice implements UseCase<bool, SalesInvoice> {
  final SalesRepository repository;

  CreateInvoice(this.repository);

  @override
  Future<Result<bool>> call(SalesInvoice invoice) async {
    return await repository.createInvoice(invoice);
  }
}
