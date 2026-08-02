class LedgerEntry {
  final String date;
  final String type;
  final String ref;
  final String amount;
  final String balance;
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
