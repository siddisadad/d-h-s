import '../../../../features/inventory/domain/entities/product.dart';

enum RestockUrgency { low, medium, high, critical }

class RestockSuggestion {
  final Product product;
  final double suggestedQty;
  final RestockUrgency urgency;
  final String? supplierId;
  final String reason;

  RestockSuggestion({
    required this.product,
    required this.suggestedQty,
    required this.urgency,
    this.supplierId,
    required this.reason,
  });
}
