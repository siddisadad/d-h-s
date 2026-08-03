import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/forecast_provider.dart';
import '../../domain/entities/restock_suggestion.dart';
import '../../domain/entities/demand_forecast.dart';
import '../../data/services/procurement_service.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

part 'procurement_provider.g.dart';

@riverpod
ProcurementService procurementService(ProcurementServiceRef ref) => ProcurementService();

@riverpod
Future<List<RestockSuggestion>> restockSuggestions(RestockSuggestionsRef ref) async {
  final products = await ref.watch(inventoryNotifierProvider.future);
  final service = ref.watch(procurementServiceProvider);
  
  final Map<String, DemandForecast> forecasts = {};
  
  // Fetch forecasts for all products (ideally in parallel)
  // For performance in a large inventory, we might only forecast items with low stock
  for (var p in products) {
    try {
      final f = await ref.watch(demandForecastProvider(p.sku).future);
      if (f != null) forecasts[p.sku] = f;
    } catch (_) {}
  }

  return service.generateSuggestions(
    products: products,
    forecasts: forecasts,
  );
}

@riverpod
Future<Map<String?, List<RestockSuggestion>>> suggestionsBySupplier(SuggestionsBySupplierRef ref) async {
  final suggestions = await ref.watch(restockSuggestionsProvider.future);
  
  final Map<String?, List<RestockSuggestion>> grouped = {};
  for (var s in suggestions) {
    grouped.putIfAbsent(s.supplierId, () => []).add(s);
  }
  
  return grouped;
}
