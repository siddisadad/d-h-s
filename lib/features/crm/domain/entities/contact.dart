enum ContactType { customer, supplier }

class Contact {
  final String id;
  final String name;
  final String initials;
  final String contact;
  final String gstin;
  final double balance;
  final double creditLimit;
  final String location;
  final ContactType type;
  final DateTime? lastReminderSent;
  final int lastUpdated;

  const Contact({
    required this.id,
    required this.name,
    required this.initials,
    required this.contact,
    required this.gstin,
    required this.balance,
    this.creditLimit = 0.0,
    required this.location,
    required this.type,
    this.lastReminderSent,
    this.lastUpdated = 0,
  });
}
