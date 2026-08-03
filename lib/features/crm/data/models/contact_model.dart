import '../../domain/entities/contact.dart';

class ContactModel extends Contact {
  ContactModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.contact,
    required super.gstin,
    required super.balance,
    required super.location,
    required super.type,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      initials: json['initials'] as String,
      contact: json['contact'] as String,
      gstin: json['gstin'] as String,
      balance: (json['balance'] as num).toDouble(),
      location: json['location'] as String,
      type: json['type'] == 'supplier' ? ContactType.supplier : ContactType.customer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'contact': contact,
      'gstin': gstin,
      'balance': balance,
      'location': location,
      'type': type == ContactType.supplier ? 'supplier' : 'customer',
    };
  }
}
