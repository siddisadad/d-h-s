import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/crm_repository.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/logger.dart';

part 'crm_provider.g.dart';

@riverpod
CrmRepository crmRepository(CrmRepositoryRef ref) => sl.crmRepository;

@riverpod
GetContacts getContactsUseCase(GetContactsUseCaseRef ref) => sl.getContactsUseCase;

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
}
