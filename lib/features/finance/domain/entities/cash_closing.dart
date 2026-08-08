class CashClosing {
  final String id;
  final DateTime date;
  final double openingBalance;
  final double totalCashSales;
  final double totalCashExpenses;
  final double physicalCashCount;
  final String? notes;
  final String performedBy;
  final int lastUpdated;

  CashClosing({
    required this.id,
    required this.date,
    required this.openingBalance,
    required this.totalCashSales,
    required this.totalCashExpenses,
    required this.physicalCashCount,
    this.notes,
    required this.performedBy,
    this.lastUpdated = 0,
  });

  double get expectedClosingBalance => openingBalance + totalCashSales - totalCashExpenses;
  double get difference => physicalCashCount - expectedClosingBalance;
}
