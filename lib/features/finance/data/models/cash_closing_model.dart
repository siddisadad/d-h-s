import '../../domain/entities/cash_closing.dart';

class CashClosingModel extends CashClosing {
  CashClosingModel({
    required super.id,
    required super.date,
    required super.openingBalance,
    required super.totalCashSales,
    required super.totalCashExpenses,
    required super.physicalCashCount,
    super.notes,
    required super.performedBy,
    super.lastUpdated,
  });

  factory CashClosingModel.fromJson(Map<String, dynamic> json) {
    return CashClosingModel(
      id: json['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      openingBalance: (json['openingBalance'] as num).toDouble(),
      totalCashSales: (json['totalCashSales'] as num).toDouble(),
      totalCashExpenses: (json['totalCashExpenses'] as num).toDouble(),
      physicalCashCount: (json['physicalCashCount'] as num).toDouble(),
      notes: json['notes'] as String?,
      performedBy: json['performedBy'] as String,
      lastUpdated: json['lastUpdated'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'openingBalance': openingBalance,
      'totalCashSales': totalCashSales,
      'totalCashExpenses': totalCashExpenses,
      'physicalCashCount': physicalCashCount,
      'notes': notes,
      'performedBy': performedBy,
      'lastUpdated': lastUpdated,
    };
  }
}
