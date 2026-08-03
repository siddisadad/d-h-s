import '../../domain/entities/restock_suggestion.dart';
import '../../domain/entities/demand_forecast.dart';
import '../../../inventory/domain/entities/product.dart';

class ProcurementService {
  List<RestockSuggestion> generateSuggestions({
    required List<Product> products,
    required Map<String, DemandForecast> forecasts,
  }) {
    final List<RestockSuggestion> suggestions = [];

    for (var product in products) {
      final forecast = forecasts[product.sku];
      if (forecast == null) continue;

      bool needsRestock = false;
      RestockUrgency urgency = RestockUrgency.low;
      String reason = "";
      double suggestedQty = 0;

      // 1. Check against hard reorder point
      if (product.reorderPoint > 0 && product.stock <= product.reorderPoint) {
        needsRestock = true;
        urgency = RestockUrgency.high;
        reason = "Stock below reorder point (${product.reorderPoint} ${product.unit})";
        // Suggest enough for 14 days of demand or at least 2x the deficit
        suggestedQty = (forecast.predictedWeeklyDemand * 2).clamp(product.reorderPoint - product.stock + 100, 10000);
      } 
      // 2. Check AI forecast for stock-out
      else if (forecast.isCritical) {
        needsRestock = true;
        urgency = RestockUrgency.critical;
        reason = "AI predicts stock-out in ${forecast.estimatedDaysUntilStockOut} days";
        suggestedQty = forecast.predictedWeeklyDemand * 3; // 3 weeks supply
      } 
      else if (forecast.isWarning) {
        needsRestock = true;
        urgency = RestockUrgency.medium;
        reason = "AI predicts rising demand; stock low for next 7 days";
        suggestedQty = forecast.predictedWeeklyDemand * 2;
      }

      if (needsRestock && suggestedQty > 0) {
        suggestions.add(RestockSuggestion(
          product: product,
          suggestedQty: suggestedQty,
          urgency: urgency,
          supplierId: product.preferredSupplierId,
          reason: reason,
        ));
      }
    }

    // Sort by urgency
    suggestions.sort((a, b) => b.urgency.index.compareTo(a.urgency.index));
    return suggestions;
  }
}
