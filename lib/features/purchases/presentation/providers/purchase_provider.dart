import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/logger.dart';

part 'purchase_provider.g.dart';

@riverpod
PurchaseRepository purchaseRepository(PurchaseRepositoryRef ref) => sl.purchaseRepository;

@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  Future<List<PurchaseOrder>> build() async {
    return _fetchFromApi();
  }

  Future<List<PurchaseOrder>> _fetchFromApi() async {
    try {
      Log.d('Fetching purchases from API...', name: 'Purchases');
      final repository = ref.read(purchaseRepositoryProvider);
      final result = await repository.getRecentPurchases();

      return result.fold(
        (failure) {
          Log.e('Purchases API Fetch Failed', error: failure.message, name: 'Purchases');
          throw Exception(failure.message);
        },
        (purchases) {
          Log.d('Purchases API Fetch Complete', name: 'Purchases');
          return purchases;
        },
      );
    } catch (e, stack) {
      Log.e('Purchase Provider Error', error: e, stackTrace: stack, name: 'Purchases');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFromApi());
  }

  Future<bool> createPurchase(PurchaseOrder purchase) async {
    final repository = ref.read(purchaseRepositoryProvider);
    final result = await repository.createPurchase(purchase);

    return result.fold(
      (failure) {
        Log.e('Create Purchase Failed', error: failure.message, name: 'Purchases');
        return false;
      },
      (success) {
        ref.invalidateSelf();
        return true;
      },
    );
  }
}
