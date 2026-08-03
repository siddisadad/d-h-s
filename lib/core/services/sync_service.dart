import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';
import '../database/local_database.dart';
import '../network/api_client.dart';
import 'connectivity_service.dart';
import '../utils/logger.dart';
import '../di/injection_container.dart';
import '../../features/inventory/data/models/product_model.dart';
import '../../features/crm/data/models/contact_model.dart';

part 'sync_service.g.dart';

@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  late LocalDatabase _localDb;
  late ApiClient _apiClient;
  bool _isSyncing = false;
  final List<StreamSubscription> _subscriptions = [];

  @override
  bool build() {
    _localDb = LocalDatabase();
    _apiClient = ref.read(apiClientProvider);

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
      Log.i('☁️ Initializing Cloud Sync Listeners...', name: 'Sync');

      // Sync Inventory
      _subscriptions.add(sl.firebaseDb.watchPath('inventory').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

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
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        });
      });

      await _localDb.saveProducts(products);
      Log.d('✓ Inventory synced from Cloud (${products.length} items)', name: 'Sync');
    }));

    // Sync Contacts
    _subscriptions.add(sl.firebaseDb.watchPath('contacts').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

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
          'location': model.location,
          'type': model.type.name,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        });
      });

      await _localDb.saveContacts(contacts);
      Log.d('✓ Contacts synced from Cloud (${contacts.length} items)', name: 'Sync');
    }));

    // Sync Quotations
    _subscriptions.add(sl.firebaseDb.watchPath('quotations').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      data.forEach((key, value) async {
        final Map<String, dynamic> qMap = Map<String, dynamic>.from(value as Map);
        await _localDb.saveQuotation(qMap..['items'] = jsonEncode(qMap['items']));
      });
      Log.d('✓ Quotations synced from Cloud', name: 'Sync');
    }));

    // Sync Returns
    _subscriptions.add(sl.firebaseDb.watchPath('returns').listen((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return;
      data.forEach((key, value) async {
        final Map<String, dynamic> rMap = Map<String, dynamic>.from(value as Map);
        await _localDb.saveReturn(rMap..['returnedItems'] = jsonEncode(rMap['returnedItems']));
      });
      Log.d('✓ Returns synced from Cloud', name: 'Sync');
    }));
    } catch (e) {
      Log.e('❌ Cloud Sync Initialization Failed', error: e, name: 'Sync');
    }
  }

  Future<void> processQueue() async {
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
