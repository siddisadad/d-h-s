import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/purchase_order.dart';
import '../../../../core/di/injection_container.dart';

part 'purchase_provider.g.dart';

@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  Future<List<PurchaseOrder>> build() async {
    return _fetchFromApi();
  }

  Future<List<PurchaseOrder>> _fetchFromApi() async {
    try {
      debugPrint('🌐 [Purchases] Fetching from API...');
      final repository = sl.purchaseRepository;
      final result = await repository.getRecentPurchases();

      return result.fold(
        (failure) {
          debugPrint('❌ [Purchases] API Fetch Failed: ${failure.message}');
          throw Exception(failure.message);
        },
        (purchases) {
          debugPrint('✅ [Purchases] API Fetch Complete');
          return purchases;
        },
      );
    } catch (e) {
      debugPrint('⚠️ [Purchases] Error: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchFromApi());
  }
}
