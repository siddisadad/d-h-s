import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/demand_forecast.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/data/services/forecasting_service.dart';
import '../../../sales/presentation/providers/sales_history_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';

part 'forecast_provider.g.dart';

@riverpod
Future<DemandForecast?> demandForecast(DemandForecastRef ref, String sku) async {
  final salesHistoryAsync = ref.watch(salesHistoryProvider);
  final productAsync = ref.watch(productProvider(sku));

  if (salesHistoryAsync is AsyncData && productAsync is AsyncData) {
    final history = salesHistoryAsync.value!;
    final product = productAsync.value;

    if (product == null) return null;

    return ForecastingService().calculateForecast(
      sku: sku,
      history: history,
      currentStock: product.stock,
    );
  }

  return null;
}

@riverpod
Future<Map<String, DemandForecast>> allDemandForecasts(AllDemandForecastsRef ref) async {
  final salesHistoryAsync = ref.watch(salesHistoryProvider);
  final productsAsync = ref.watch(inventoryNotifierProvider);

  if (salesHistoryAsync is AsyncData && productsAsync is AsyncData) {
    final history = salesHistoryAsync.value!;
    final products = productsAsync.value!;
    final service = ForecastingService();
    
    final Map<String, DemandForecast> forecasts = {};
    for (var p in products) {
      forecasts[p.sku] = service.calculateForecast(
        sku: p.sku,
        history: history,
        currentStock: p.stock,
      );
    }
    return forecasts;
  }

  return {};
}
