import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';

part 'movement_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> productMovement(ProductMovementRef ref, String sku) async {
  final localDb = ref.watch(localDatabaseProvider);
  return await localDb.getStockMovements(sku);
}

@riverpod
Future<List<Map<String, dynamic>>> allMovements(AllMovementsRef ref) async {
  final localDb = ref.watch(localDatabaseProvider);
  return await localDb.getAllStockMovements();
}
