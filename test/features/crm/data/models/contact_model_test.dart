import 'package:flutter_test/flutter_test.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/data/models/contact_model.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/domain/entities/contact.dart';

void main() {
  group('ContactModel', () {
    final tLastReminderSent = DateTime(2023, 1, 1);
    final tContactModel = ContactModel(
      id: '1',
      name: 'Test Contact',
      initials: 'TC',
      contact: '1234567890',
      gstin: 'GST123',
      balance: 1000.0,
      creditLimit: 5000.0,
      location: 'Test Location',
      type: ContactType.customer,
      lastReminderSent: tLastReminderSent,
      lastUpdated: 123456789,
    );

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'name': 'Test Contact',
        'initials': 'TC',
        'contact': '1234567890',
        'gstin': 'GST123',
        'balance': 1000.0,
        'creditLimit': 5000.0,
        'location': 'Test Location',
        'type': 'customer',
        'lastReminderSent': tLastReminderSent.millisecondsSinceEpoch,
        'lastUpdated': 123456789,
      };

      final result = ContactModel.fromJson(jsonMap);

      expect(result.id, tContactModel.id);
      expect(result.creditLimit, 5000.0);
      expect(result.lastReminderSent, tLastReminderSent);
    });

    test('toJson should return a JSON map containing proper data', () {
      final result = tContactModel.toJson();

      final expectedMap = {
        'id': '1',
        'name': 'Test Contact',
        'initials': 'TC',
        'contact': '1234567890',
        'gstin': 'GST123',
        'balance': 1000.0,
        'creditLimit': 5000.0,
        'location': 'Test Location',
        'type': 'customer',
        'lastReminderSent': tLastReminderSent.millisecondsSinceEpoch,
        'lastUpdated': 123456789,
      };

      expect(result, expectedMap);
    });
  });
}
