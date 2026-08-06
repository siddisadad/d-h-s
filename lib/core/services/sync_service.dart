import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';
import '../providers/database_providers.dart';
import '../database/local_database.dart';
import '../network/api_client.dart';
import 'connectivity_service.dart';
import '../providers/firebase_providers.dart';
import '../utils/logger.dart';
import '../../features/inventory/data/models/product_model.dart';
import '../../features/crm/data/models/contact_model.dart';
import '../../features/employees/data/models/employee_model.dart';
import '../../features/sales/data/models/invoice_model.dart';
import '../../features/purchases/data/models/purchase_model.dart';
import '../../features/finance/data/models/transaction_model.dart';

part 'sync_service.g.dart';

@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  late LocalDatabase _localDb;
  late ApiClient _apiClient;
  bool _isSyncing = false;
  final List<StreamSubscription> _subscriptions = [];

  @override
  bool build() {
    _apiClient = ref.watch(apiClientProvider);

    if (kIsWeb) {
      Log.i('🛠️ Sync Service: Running in Web mode (Local Sync Queue disabled)', name: 'Sync');
      // On Web, we can still listen to Cloud Sync if Firebase is available
      if (!AppConfig.useMocks) {
        _initCloudSync();
      }
      return false;
    }

    _localDb = ref.watch(localDatabaseProvider);

    // 1. Listen to connectivity changes for legacy queue
    ref.listen(connectivityNotifierProvider, (previous, next) {
      next.whenData((status) {
        if (status == ConnectivityStatus.online) {
          Log.i('Back Online: Triggering legacy sync queue...', name: 'Sync');
          processQueue();
        }
      });
    });

    // 2. Initialize Real-time Cloud Sync (Firebase)
    // Only initialize if NOT in mock mode
    if (!AppConfig.useMocks) {
      _initCloudSync();
    } else {
      Log.i('🛠️ Sync Service: Running in Mock Mode (Cloud Sync Disabled)', name: 'Sync');
    }

    ref.onDispose(() {
      for (var sub in _subscriptions) {
        sub.cancel();
      }
    });

    return false;
  }

  void _initCloudSync() {
    try {
      final firebaseDb = ref.read(firebaseDatabaseServiceProvider);

      if (!firebaseDb.isInitialized) {
        Log.w('☁️ Cloud Sync deferred: Firebase Database not initialized', name: 'Sync');
        return;
      }

      Log.i('☁️ Initializing Cloud Sync Listeners...', name: 'Sync');

      // Sync Inventory
      _subscriptions.add(firebaseDb.watchPath('inventory').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final products = await compute(_parseInventoryData, data);

      if (!kIsWeb) {
        await _localDb.saveProducts(products);
        Log.d('✓ Inventory synced from Cloud (${products.length} items)', name: 'Sync');
      }
    }));

    // Sync Contacts
    _subscriptions.add(firebaseDb.watchPath('contacts').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final contacts = await compute(_parseContactData, data);

      if (!kIsWeb) {
        await _localDb.saveContacts(contacts);
        Log.d('✓ Contacts synced from Cloud (${contacts.length} items)', name: 'Sync');
      }
    }));

    // Sync Quotations
    _subscriptions.add(firebaseDb.watchPath('quotations').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (kIsWeb) return;
      data.forEach((key, value) async {
        final Map<String, dynamic> qMap = Map<String, dynamic>.from(value as Map);
        await _localDb.saveQuotation(qMap..['items'] = jsonEncode(qMap['items']));
      });
      Log.d('✓ Quotations synced from Cloud', name: 'Sync');
    }));

    // Sync Returns
    _subscriptions.add(firebaseDb.watchPath('returns').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (kIsWeb) return;
      data.forEach((key, value) async {
        final Map<String, dynamic> rMap = Map<String, dynamic>.from(value as Map);
        await _localDb.saveReturn(rMap..['items'] = jsonEncode(rMap['items']));
      });
      Log.d('✓ Returns synced from Cloud', name: 'Sync');
    }));

    // Sync Employees
    _subscriptions.add(firebaseDb.watchPath('employees').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final employees = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        final model = EmployeeModel.fromJson(Map<String, dynamic>.from(value as Map));
        employees.add(model.toJson());
      });

      if (!kIsWeb) {
        await _localDb.saveEmployees(employees);
        Log.d('✓ Employees synced from Cloud (${employees.length} items)', name: 'Sync');
      }
    }));

    // Sync Sales (Invoices)
    _subscriptions.add(firebaseDb.watchPath('sales').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (kIsWeb) return;

      data.forEach((key, value) async {
        final Map<String, dynamic> invMap = Map<String, dynamic>.from(value as Map);
        final model = InvoiceModel.fromJson(invMap);
        await _localDb.saveInvoice({
          'id': model.id,
          'customerId': model.customerId,
          'customerName': model.customerName,
          'date': model.date.millisecondsSinceEpoch,
          'discount': model.discount,
          'grandTotal': model.grandTotal,
          'items': jsonEncode(invMap['items']),
          'lastUpdated': model.lastUpdated,
        });
      });
      Log.d('✓ Sales synced from Cloud', name: 'Sync');
    }));

    // Sync Purchases
    _subscriptions.add(firebaseDb.watchPath('purchases').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (kIsWeb) return;

      data.forEach((key, value) async {
        final Map<String, dynamic> purMap = Map<String, dynamic>.from(value as Map);
        final model = PurchaseModel.fromJson(purMap);
        await _localDb.savePurchase({
          'id': model.id,
          'supplierId': model.supplierId,
          'supplierName': model.supplierName,
          'date': model.date.millisecondsSinceEpoch,
          'discount': model.discount,
          'totalAmount': model.grandTotal,
          'status': model.status,
          'items': jsonEncode(purMap['items']),
          'lastUpdated': model.lastUpdated,
        });
      });
      Log.d('✓ Purchases synced from Cloud', name: 'Sync');
    }));

    // Sync Finance
    _subscriptions.add(firebaseDb.watchPath('finance').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (kIsWeb) return;

      data.forEach((key, value) async {
        final Map<String, dynamic> finMap = Map<String, dynamic>.from(value as Map);
        final model = TransactionModel.fromJson(finMap);
        await _localDb.saveFinanceEntry({
          'id': model.id,
          'title': model.title,
          'category': model.category,
          'amount': model.amount,
          'date': model.date.millisecondsSinceEpoch,
          'paymentMode': model.paymentMode,
          'lastUpdated': model.lastUpdated,
        });
      });
      Log.d('✓ Finance synced from Cloud', name: 'Sync');
    }));

    // Sync Ledgers
    _subscriptions.add(firebaseDb.watchPath('ledgers').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      if (kIsWeb) return;

      final db = await _localDb.database;
      data.forEach((contactId, entries) {
        if (entries is Map) {
          entries.forEach((ref, value) async {
            final Map<String, dynamic> ledgerMap = Map<String, dynamic>.from(value as Map);
            await db.insert('ledgers', {
              'contactId': contactId,
              'date': DateTime.parse(ledgerMap['date'] as String).millisecondsSinceEpoch,
              'type': ledgerMap['type'],
              'ref': ref,
              'amount': (ledgerMap['amount'] as num).toDouble(),
              'balanceAfter': (ledgerMap['balance'] as num).toDouble(),
              'isDebit': (ledgerMap['isDebit'] as bool) ? 1 : 0,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          });
        }
      });
      Log.d('✓ Ledgers synced from Cloud', name: 'Sync');
    }));
    } catch (e) {
      Log.e('❌ Cloud Sync Initialization Failed', error: e, name: 'Sync');
    }
  }

  Future<void> processQueue() async {
    if (kIsWeb) return;
    if (_isSyncing) return;
    _isSyncing = true;
    state = true;

    try {
      final db = await _localDb.database;
      final List<Map<String, dynamic>> queue = await db.query('sync_queue', orderBy: 'timestamp ASC');

      if (queue.isEmpty) return;

      for (final item in queue) {
        final id = item['id'] as int;
        final method = item['method'] as String;
        final path = item['path'] as String;
        final body = item['body'] != null ? jsonDecode(item['body'] as String) : null;

        try {
          if (method == 'POST') await _apiClient.dio.post(path, data: body);
          else if (method == 'PUT') await _apiClient.dio.put(path, data: body);
          else if (method == 'DELETE') await _apiClient.dio.delete(path);
          else if (method == 'PATCH') await _apiClient.dio.patch(path, data: body);

          await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
        } catch (e) {
          Log.e('Failed to sync legacy task: $method $path', error: e, name: 'Sync');
          break;
        }
      }
    } finally {
      _isSyncing = false;
      state = false;
    }
  }
}

// Top-level parsing functions for compute()
List<Map<String, dynamic>> _parseInventoryData(Map data) {
  final products = <Map<String, dynamic>>[];
  data.forEach((key, value) {
    final model = ProductModel.fromJson(Map<String, dynamic>.from(value as Map));
    products.add({
      'sku': model.sku,
      'name': model.name,
      'category': model.category,
      'price': model.price,
      'stock': model.stock,
      'unit': model.unit,
      'isLowStock': model.isLowStock ? 1 : 0,
      'hsnCode': model.hsnCode,
      'lastUpdated': model.lastUpdated,
    });
  });
  return products;
}

List<Map<String, dynamic>> _parseContactData(Map data) {
  final contacts = <Map<String, dynamic>>[];
  data.forEach((key, value) {
    final model = ContactModel.fromJson(Map<String, dynamic>.from(value as Map));
    contacts.add({
      'id': model.id,
      'name': model.name,
      'initials': model.initials,
      'contact': model.contact,
      'gstin': model.gstin,
      'balance': model.balance,
      'creditLimit': model.creditLimit,
      'location': model.location,
      'type': model.type.name,
      'lastUpdated': model.lastUpdated,
    });
  });
  return contacts;
}
