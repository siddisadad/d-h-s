import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/ledger_entry.dart';
import '../models/contact_model.dart';

abstract class CrmRemoteDataSource {
  Future<List<Contact>> getContacts(ContactType type);
  Future<List<LedgerEntry>> getLedgerByContactId(String contactId);
}

class CrmRemoteDataSourceImpl implements CrmRemoteDataSource {
  final ApiClient _client;

  CrmRemoteDataSourceImpl(this._client);

  @override
  Future<List<Contact>> getContacts(ContactType type) async {
    try {
      final response = await _client.dio.get(
        '/contacts',
        queryParameters: {'type': type == ContactType.supplier ? 'supplier' : 'customer'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ContactModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      debugPrint('⚠️ [CRM API] Fetch Failed: $e');
      if (kDebugMode) {
        return type == ContactType.supplier ? _mockSuppliers : _mockCustomers;
      }
      rethrow;
    }
  }

  @override
  Future<List<LedgerEntry>> getLedgerByContactId(String contactId) async {
    try {
      final response = await _client.dio.get('/contacts/$contactId/ledger');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => LedgerEntry(
          amount: json['amount'],
          balance: json['balance'],
          date: json['date'],
          ref: json['ref'],
          type: json['type'],
          isDebit: json['isDebit'],
        )).toList();
      } else {
        throw Exception('Failed to load ledger');
      }
    } catch (e) {
      debugPrint('⚠️ [CRM API] Ledger Fetch Failed: $e');
      if (kDebugMode) return _mockLedger;
      rethrow;
    }
  }

  final List<Contact> _mockSuppliers = [
    Contact(id: 'S1', name: 'Adarsh Steel Industries', initials: 'AS', contact: '+91 98765 43210', gstin: '27AAACA1234A1Z5', balance: '₹4,50,000', location: 'Industrial Area, Pune', type: ContactType.supplier),
    Contact(id: 'S2', name: 'Mahadev Khatape Steel', initials: 'MK', contact: '+91 88888 77777', gstin: '27BBBCB5678B2Z1', balance: '₹1,25,500', location: 'Loni Kalbhor', type: ContactType.supplier),
  ];

  final List<Contact> _mockCustomers = [
    Contact(id: 'C1', name: 'Rohan Construction', initials: 'RC', contact: '+91 98765 43210', gstin: '27AAACA1234A1Z5', balance: '₹45,820', location: 'MIDC Area, Pune', type: ContactType.customer),
  ];

  final List<LedgerEntry> _mockLedger = [
    LedgerEntry(amount: '12,400', balance: '45,820', date: '22 May 2024', ref: '#SI-2024-882', type: 'Sales Invoice', isDebit: true),
    LedgerEntry(amount: '5,000', balance: '33,420', date: '18 May 2024', ref: '#PAY-9912', type: 'Payment Received', isDebit: false),
  ];
}

class CrmMockDataSourceImpl implements CrmRemoteDataSource {
  @override
  Future<List<Contact>> getContacts(ContactType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return type == ContactType.supplier 
      ? [Contact(id: 'S1', name: 'Adarsh Steel', initials: 'AS', contact: '123', gstin: 'GST', balance: '0', location: 'Pune', type: ContactType.supplier)]
      : [Contact(id: 'C1', name: 'Rohan Const', initials: 'RC', contact: '123', gstin: 'GST', balance: '0', location: 'Pune', type: ContactType.customer)];
  }

  @override
  Future<List<LedgerEntry>> getLedgerByContactId(String contactId) async {
    return [];
  }
}
