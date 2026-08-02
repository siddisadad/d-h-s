enum ContactType { customer, supplier }

class Contact {
  final String id;
  final String name;
  final String initials;
  final String contact;
  final String gstin;
  final String balance;
  final String location;
  final ContactType type;

  Contact({
    required this.id,
    required this.name,
    required this.initials,
    required this.contact,
    required this.gstin,
    required this.balance,
    required this.location,
    required this.type,
  });
}
