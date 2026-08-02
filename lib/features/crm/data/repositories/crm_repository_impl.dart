import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/crm_repository.dart';
import '../datasources/crm_remote_data_source.dart';

class CrmRepositoryImpl implements CrmRepository {
  final CrmRemoteDataSource remoteDataSource;

  CrmRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<Contact>>> getContacts(ContactType type) async {
    try {
      final contacts = await remoteDataSource.getContacts(type);
      return Result.success(contacts);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LedgerEntry>>> getLedgerByContactId(String contactId) async {
    try {
      final ledger = await remoteDataSource.getLedgerByContactId(contactId);
      return Result.success(ledger);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }
}
