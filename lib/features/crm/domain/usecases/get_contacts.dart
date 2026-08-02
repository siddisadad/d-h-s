import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/contact.dart';
import '../repositories/crm_repository.dart';

class GetContacts implements UseCase<List<Contact>, ContactType> {
  final CrmRepository repository;

  GetContacts(this.repository);

  @override
  Future<Result<List<Contact>>> call(ContactType params) async {
    return await repository.getContacts(params);
  }
}
