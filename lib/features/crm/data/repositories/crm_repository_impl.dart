import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/firebase_database_service.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/crm_repository.dart';
import '../models/contact_model.dart';
import '../datasources/crm_remote_data_source.dart';
import '../../../../core/config/app_config.dart';

class CrmRepositoryImpl implements CrmRepository {
  final CrmRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;
  final FirebaseDatabaseService firebaseDb;

  CrmRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
    required this.firebaseDb,
  });

  @override
  Future<Result<List<Contact>>> getContacts(ContactType type) async {
    try {
      if (kIsWeb) {
        if (AppConfig.useFirebase) {
          final snapshot = await firebaseDb.getData('contacts');
          if (!snapshot.exists || snapshot.value == null) return Result.success([]);
          
          final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          final List<Contact> contacts = [];
          data.forEach((key, value) {
            final model = ContactModel.fromJson(Map<String, dynamic>.from(value as Map));
            if (model.type == type) contacts.add(model);
          });
          return Result.success(contacts);
        } else {
          final contacts = await remoteDataSource.getContacts(type);
          return Result.success(contacts);
        }
      }

      if (AppConfig.useFirebase) {
        final snapshot = await firebaseDb.getData('contacts');
        if (!snapshot.exists || snapshot.value == null) return Result.success([]);
        
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<Contact> contacts = [];
        data.forEach((key, value) {
          final model = ContactModel.fromJson(Map<String, dynamic>.from(value as Map));
          if (model.type == type) contacts.add(model);
        });
        return Result.success(contacts);
      }

      final db = await localDatabase.database;
      
      // 1. Background refresh from remote
      _refreshContactsInBackground(type);

      // 2. Return from Local DB
      final typeStr = type == ContactType.customer ? 'customer' : 'supplier';
      final List<Map<String, dynamic>> maps = await db.query(
        'contacts',
        where: 'type = ?',
        whereArgs: [typeStr],
        orderBy: 'name ASC',
      );

      final contacts = maps.map((m) => Contact(
        id: m['id'],
        name: m['name'],
        initials: m['initials'],
        contact: m['contact'],
        gstin: m['gstin'],
        balance: m['balance'],
        location: m['location'],
        type: m['type'] == 'customer' ? ContactType.customer : ContactType.supplier,
        lastReminderSent: m['lastReminderSent'] != null ? DateTime.fromMillisecondsSinceEpoch(m['lastReminderSent']) : null,
      )).toList();

      return Result.success(contacts);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LedgerEntry>>> getLedgerByContactId(String contactId) async {
    try {
      if (kIsWeb) {
        final remoteLedger = await remoteDataSource.getLedgerByContactId(contactId);
        return Result.success(remoteLedger);
      }

      final db = await localDatabase.database;

      // 1. Return from Local DB (Real-time source)
      final List<Map<String, dynamic>> maps = await db.query(
        'ledgers',
        where: 'contactId = ?',
        whereArgs: [contactId],
        orderBy: 'date DESC',
      );

      if (maps.isNotEmpty) {
        final ledger = maps.map((m) => LedgerEntry(
          date: DateTime.fromMillisecondsSinceEpoch(m['date']),
          type: m['type'],
          ref: m['ref'],
          amount: (m['amount'] as num).toDouble(),
          balance: (m['balanceAfter'] as num).toDouble(),
          isDebit: m['isDebit'] == 1,
        )).toList();
        return Result.success(ledger);
      }

      // 2. Fallback to remote if local is empty
      final remoteLedger = await remoteDataSource.getLedgerByContactId(contactId);
      return Result.success(remoteLedger);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> createContact(Contact contact) async {
    try {
      if (!kIsWeb) {
        final db = await localDatabase.database;
        
        // 1. Save locally
        await db.insert('contacts', {
          'id': contact.id,
          'name': contact.name,
          'initials': contact.initials,
          'contact': contact.contact,
          'gstin': contact.gstin,
          'balance': contact.balance,
          'location': contact.location,
          'type': contact.type == ContactType.customer ? 'customer' : 'supplier',
          'lastReminderSent': contact.lastReminderSent?.millisecondsSinceEpoch,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 2. Push to Cloud
      try {
        await firebaseDb.setData('contacts/${contact.id}', {
          'id': contact.id,
          'name': contact.name,
          'initials': contact.initials,
          'contact': contact.contact,
          'gstin': contact.gstin,
          'balance': contact.balance,
          'location': contact.location,
          'type': contact.type.name,
        });

        // Record Activity
        await firebaseDb.pushData('activities', {
          'id': 'CONT-${contact.id}',
          'title': contact.type == ContactType.customer ? 'New Customer Added' : 'New Supplier Added',
          'subtitle': '${contact.name} (${contact.location})',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'type': 'userLogin', // Reusing type for simplicity or map to a better one
        });
      } catch (e) {
        Log.w('Firebase contact sync failed: $e', name: 'CRM');
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> updateContact(Contact contact) async {
    try {
      if (!kIsWeb) {
        final db = await localDatabase.database;
        
        // 1. Update locally
        await db.update(
          'contacts',
          {
            'name': contact.name,
            'initials': contact.initials,
            'contact': contact.contact,
            'gstin': contact.gstin,
            'balance': contact.balance,
            'location': contact.location,
            'lastReminderSent': contact.lastReminderSent?.millisecondsSinceEpoch,
            'lastUpdated': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [contact.id],
        );
      }

      // 2. Push to Cloud
      try {
        await firebaseDb.updateData('contacts/${contact.id}', {
          'name': contact.name,
          'initials': contact.initials,
          'contact': contact.contact,
          'gstin': contact.gstin,
          'balance': contact.balance,
          'location': contact.location,
        });
      } catch (e) {
        Log.w('Firebase contact update failed: $e', name: 'CRM');
      }

      return Result.success(true);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // --- Helpers ---

  Future<void> _refreshContactsInBackground(ContactType type) async {
    if (kIsWeb) return;
    try {
      final remoteContacts = await remoteDataSource.getContacts(type);
      await _mirrorToLocal(remoteContacts);
    } catch (e) {
      Log.w('Could not refresh contacts: $e', name: 'CRM');
    }
  }

  Future<void> _mirrorToLocal(List<Contact> contacts) async {
    if (kIsWeb) return;
    final db = await localDatabase.database;
    final batch = db.batch();
    for (var c in contacts) {
      batch.insert('contacts', {
        'id': c.id,
        'name': c.name,
        'initials': c.initials,
        'contact': c.contact,
        'gstin': c.gstin,
        'balance': c.balance,
        'location': c.location,
        'type': c.type == ContactType.customer ? 'customer' : 'supplier',
        'lastReminderSent': c.lastReminderSent?.millisecondsSinceEpoch,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
