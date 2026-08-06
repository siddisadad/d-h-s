import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/sales_invoice.dart';

import 'sales_provider.dart';

part 'sales_history_provider.g.dart';

@riverpod
class SalesHistory extends _$SalesHistory {
  @override
  Future<List<SalesInvoice>> build() async {
    final repository = ref.read(salesRepositoryProvider);
    final result = await repository.getRecentInvoices();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (invoices) => invoices,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(salesRepositoryProvider);
      final result = await repository.getRecentInvoices();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (invoices) => invoices,
      );
    });
  }
}
