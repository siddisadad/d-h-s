import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/sales_return.dart';
import 'sales_provider.dart';

part 'sales_returns_provider.g.dart';

@riverpod
class SalesReturns extends _$SalesReturns {
  @override
  Future<List<SalesReturn>> build() async {
    final repository = ref.read(salesRepositoryProvider);
    final result = await repository.getReturns();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (returns) => returns,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(salesRepositoryProvider);
      final result = await repository.getReturns();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (returns) => returns,
      );
    });
  }
}
