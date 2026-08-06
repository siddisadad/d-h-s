class CashEntry {
  final String id;
  final String date;
  final String description;
  final String amount;
  final bool isIncome;
  final int lastUpdated;

  CashEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.isIncome,
    required this.lastUpdated,
  });
}
