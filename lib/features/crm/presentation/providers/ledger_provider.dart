import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/crm_repository.dart';
import '../providers/crm_provider.dart';

part 'ledger_provider.g.dart';

@riverpod
class LedgerNotifier extends _$LedgerNotifier {
  @override
  Future<List<LedgerEntry>> build(String contactId) async {
    final repository = ref.read(crmRepositoryProvider);
    final result = await repository.getLedgerByContactId(contactId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (ledger) => ledger,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(crmRepositoryProvider);
      final result = await repository.getLedgerByContactId(contactId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (ledger) => ledger,
      );
    });
  }
}
