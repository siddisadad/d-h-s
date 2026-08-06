class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String paymentMode;
  final int lastUpdated;

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMode,
    required this.lastUpdated,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      paymentMode: json['paymentMode'] as String,
      lastUpdated: json['lastUpdated'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'paymentMode': paymentMode,
      'lastUpdated': lastUpdated,
    };
  }
}
