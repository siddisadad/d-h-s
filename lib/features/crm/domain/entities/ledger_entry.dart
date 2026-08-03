class LedgerEntry {
  final DateTime date;
  final String type;
  final String ref;
  final double amount;
  final double balance;
  final bool isDebit;

  LedgerEntry({
    required this.date,
    required this.type,
    required this.ref,
    required this.amount,
    required this.balance,
    required this.isDebit,
  });
}
