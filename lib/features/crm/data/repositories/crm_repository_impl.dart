import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/database/local_database.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/crm_repository.dart';
import '../datasources/crm_remote_data_source.dart';

class CrmRepositoryImpl implements CrmRepository {
  final CrmRemoteDataSource remoteDataSource;
  final LocalDatabase localDatabase;

  CrmRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatabase,
  });

  @override
  Future<Result<List<Contact>>> getContacts(ContactType type) async {
    try {
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
      )).toList();

      return Result.success(contacts);
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LedgerEntry>>> getLedgerByContactId(String contactId) async {
    try {
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
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 2. Push to Cloud
      try {
        await sl.firebaseDb.setData('contacts/${contact.id}', {
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
        await sl.firebaseDb.pushData('activities', {
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
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [contact.id],
      );

      // 2. Push to Cloud
      try {
        await sl.firebaseDb.updateData('contacts/${contact.id}', {
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

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _refreshContactsInBackground(ContactType type) async {
    try {
      final remoteContacts = await remoteDataSource.getContacts(type);
      await _mirrorToLocal(remoteContacts);
    } catch (e) {
      Log.w('Could not refresh contacts: $e', name: 'CRM');
    }
  }

  Future<void> _mirrorToLocal(List<Contact> contacts) async {
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
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
