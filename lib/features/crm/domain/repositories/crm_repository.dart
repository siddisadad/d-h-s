import '../../../../core/error/result.dart';
import '../entities/contact.dart';
import '../entities/ledger_entry.dart';

abstract class CrmRepository {
  Future<Result<List<Contact>>> getContacts(ContactType type);
  Future<Result<List<LedgerEntry>>> getLedgerByContactId(String contactId);
  Future<Result<bool>> createContact(Contact contact);
  Future<Result<bool>> updateContact(Contact contact);
}
