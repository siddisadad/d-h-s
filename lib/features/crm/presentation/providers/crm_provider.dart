import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../data/repositories/crm_repository_impl.dart';
import '../../data/datasources/crm_remote_data_source.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

part 'crm_provider.g.dart';

@riverpod
CrmRepository crmRepository(CrmRepositoryRef ref) {
  final client = ref.watch(apiClientProvider);
  final firebaseDb = ref.watch(firebaseDatabaseServiceProvider);
  final localDb = ref.watch(localDatabaseProvider);

  final crmDataSource = CrmRemoteDataSourceImpl(client);

  return CrmRepositoryImpl(
    remoteDataSource: crmDataSource,
    localDatabase: localDb,
    firebaseDb: firebaseDb,
  );
}

@riverpod
GetContacts getContactsUseCase(GetContactsUseCaseRef ref) {
  final repository = ref.watch(crmRepositoryProvider);
  return GetContacts(repository);
}

@riverpod
class CrmNotifier extends _$CrmNotifier {
  @override
  Future<List<Contact>> build(ContactType type) async {
    return _fetchFromApi(type);
  }

  Future<List<Contact>> _fetchFromApi(ContactType type) async {
    try {
      Log.d('Fetching contacts type: $type', name: 'CRM');
      final useCase = ref.read(getContactsUseCaseProvider);
      final result = await useCase(type);

      return result.fold(
        (failure) {
          Log.e('CRM API Fetch Failed', error: failure.message, name: 'CRM');
          throw Exception(failure.message);
        },
        (contacts) {
          Log.d('CRM API Fetch Complete for $type', name: 'CRM');
          return contacts;
        },
      );
    } catch (e, stack) {
      Log.e('CRM Provider Error', error: e, stackTrace: stack, name: 'CRM');
      rethrow;
    }
  }

  Future<void> refresh(ContactType type) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFromApi(type));
  }

  Future<void> addContact(Contact contact) async {
    state = const AsyncLoading();
    final repository = ref.read(crmRepositoryProvider);
    final result = await repository.createContact(contact);
    
    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (success) => _fetchFromApi(contact.type),
      );
    });
  }

  Future<void> updateContact(Contact contact) async {
    state = const AsyncLoading();
    final repository = ref.read(crmRepositoryProvider);
    final result = await repository.updateContact(contact);
    
    state = await AsyncValue.guard(() async {
      return result.fold(
        (failure) => throw Exception(failure.message),
        (success) => _fetchFromApi(contact.type),
      );
    });
  }

  Future<bool> sendPaymentReminder(Contact contact) async {
    final updatedContact = Contact(
      id: contact.id,
      name: contact.name,
      initials: contact.initials,
      contact: contact.contact,
      gstin: contact.gstin,
      balance: contact.balance,
      location: contact.location,
      type: contact.type,
      lastReminderSent: DateTime.now(),
    );

    final repository = ref.read(crmRepositoryProvider);
    final result = await repository.updateContact(updatedContact);

    return result.fold(
      (failure) => false,
      (success) {
        refresh(contact.type);
        return true;
      },
    );
  }
}
