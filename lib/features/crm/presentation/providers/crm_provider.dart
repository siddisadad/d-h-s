import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/contact.dart';
import '../../../../core/di/injection_container.dart';

part 'crm_provider.g.dart';

@riverpod
class CrmNotifier extends _$CrmNotifier {
  @override
  Future<List<Contact>> build(ContactType type) async {
    return _fetchFromApi(type);
  }

  Future<List<Contact>> _fetchFromApi(ContactType type) async {
    try {
      debugPrint('🌐 [CRM] Fetching contacts type: $type');
      final getContactsUseCase = sl.getContactsUseCase;
      final result = await getContactsUseCase(type);

      return result.fold(
        (failure) {
          debugPrint('❌ [CRM] API Fetch Failed: ${failure.message}');
          throw Exception(failure.message);
        },
        (contacts) {
          debugPrint('✅ [CRM] API Fetch Complete for $type');
          return contacts;
        },
      );
    } catch (e) {
      debugPrint('⚠️ [CRM] Error: $e');
      rethrow;
    }
  }

  Future<void> refresh(ContactType type) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFromApi(type));
  }
}
