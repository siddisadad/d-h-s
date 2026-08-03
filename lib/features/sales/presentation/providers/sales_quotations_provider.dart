import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/sales_quotation.dart';
import 'sales_provider.dart';

part 'sales_quotations_provider.g.dart';

@riverpod
class SalesQuotations extends _$SalesQuotations {
  @override
  Future<List<SalesQuotation>> build() async {
    final repository = ref.read(salesRepositoryProvider);
    final result = await repository.getQuotations();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (quotations) => quotations,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(salesRepositoryProvider);
      final result = await repository.getQuotations();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (quotations) => quotations,
      );
    });
  }
}
