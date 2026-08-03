import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/logger.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Desktop initialization guard
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      try {
        // We use a try-catch because accessing databaseFactory before it is set
        // can throw "Bad state: databaseFactory not initialized" on some platforms.
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        Log.i('🖥️ sqflite_ffi initialized for LocalDatabase', name: 'Database');
      } catch (e) {
        Log.e('Failed to initialize sqflite_ffi', error: e, name: 'Database');
      }
    }

    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final directory = await getApplicationSupportDirectory();
      path = join(directory.path, 'dci_erp_v1.db');
    } else {
      path = join(await getDatabasesPath(), 'dci_erp_v1.db');
    }
    Log.d('Initializing Local Database at: $path', name: 'Database');

    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    Log.i('Creating local tables (v$version)...', name: 'Database');

    // ... existing tables ...
    await _createTables(db);
    await _insertDefaultWarehouse(db);
  }

  Future<void> _insertDefaultWarehouse(Database db) async {
    await db.insert('warehouses', {
      'id': 'main_yard',
      'name': 'Main Yard',
      'location': 'Primary yard location',
      'isDefault': 1,
    });
  }

  Future<void> _createTables(Database db) async {
    // 1. Inventory Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        sku TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock REAL NOT NULL,
        unit TEXT NOT NULL,
        isLowStock INTEGER DEFAULT 0,
        lastUpdated INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_inventory_sku ON inventory(sku)');

    // 2. Contacts Table (CRM)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        initials TEXT NOT NULL,
        contact TEXT NOT NULL,
        gstin TEXT NOT NULL,
        balance REAL NOT NULL,
        location TEXT NOT NULL,
        type TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // 3. Sync Queue Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT NOT NULL,
        path TEXT NOT NULL,
        body TEXT,
        timestamp INTEGER NOT NULL,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // 4. Sales Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        date INTEGER NOT NULL,
        discount REAL NOT NULL,
        grandTotal REAL NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    // 5. Ledgers Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ledgers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contactId TEXT NOT NULL,
        date INTEGER NOT NULL,
        type TEXT NOT NULL,
        ref TEXT NOT NULL,
        amount REAL NOT NULL,
        balanceAfter REAL NOT NULL,
        isDebit INTEGER NOT NULL
      )
    ''');

    // 6. Employees Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        salary TEXT NOT NULL,
        attendanceStatus TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // 7. Purchases Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchases (
        id TEXT PRIMARY KEY,
        supplierId TEXT NOT NULL,
        supplierName TEXT NOT NULL,
        date INTEGER NOT NULL,
        discount REAL NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    // 8. Quotations Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quotations (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        date INTEGER NOT NULL,
        expiryDate INTEGER NOT NULL,
        discount REAL NOT NULL,
        grandTotal REAL NOT NULL,
        status TEXT NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    // 9. Returns Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS returns (
        id TEXT PRIMARY KEY,
        originalInvoiceId TEXT NOT NULL,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        date INTEGER NOT NULL,
        grandTotal REAL NOT NULL,
        reason TEXT NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    // 10. Warehouses Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS warehouses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        isDefault INTEGER DEFAULT 0
      )
    ''');

    // 11. Stock Levels Table (Multi-Warehouse tracking)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_levels (
        productSku TEXT NOT NULL,
        warehouseId TEXT NOT NULL,
        quantity REAL NOT NULL,
        PRIMARY KEY (productSku, warehouseId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.i('Upgrading database from $oldVersion to $newVersion', name: 'Database');
    if (oldVersion < 2) {
      try { await db.execute('ALTER TABLE sales ADD COLUMN customerId TEXT NOT NULL DEFAULT ""'); } catch (_) {}
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ledgers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contactId TEXT NOT NULL,
          date INTEGER NOT NULL,
          type TEXT NOT NULL,
          ref TEXT NOT NULL,
          amount REAL NOT NULL,
          balanceAfter REAL NOT NULL,
          isDebit INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_inventory_sku ON inventory(sku)');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS employees (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          role TEXT NOT NULL,
          email TEXT NOT NULL,
          phone TEXT NOT NULL,
          salary TEXT NOT NULL,
          attendanceStatus TEXT NOT NULL,
          lastUpdated INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS purchases (
          id TEXT PRIMARY KEY,
          supplierId TEXT NOT NULL,
          supplierName TEXT NOT NULL,
          date INTEGER NOT NULL,
          discount REAL NOT NULL,
          totalAmount REAL NOT NULL,
          status TEXT NOT NULL,
          items TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 5) {
      Log.i('Migrating to v5: Changing TEXT columns to REAL', name: 'Database');
      
      // Migrate inventory
      await db.execute('ALTER TABLE inventory RENAME TO inventory_old');
      await db.execute('''
        CREATE TABLE inventory (
          sku TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          price REAL NOT NULL,
          stock REAL NOT NULL,
          unit TEXT NOT NULL,
          isLowStock INTEGER DEFAULT 0,
          lastUpdated INTEGER NOT NULL
        )
      ''');
      final List<Map<String, dynamic>> oldInventory = await db.query('inventory_old');
      for (var row in oldInventory) {
        final Map<String, dynamic> newRow = Map.from(row);
        newRow['price'] = double.tryParse(row['price'].toString().replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
        newRow['stock'] = double.tryParse(row['stock'].toString().replaceAll(',', '')) ?? 0.0;
        await db.insert('inventory', newRow);
      }
      await db.execute('DROP TABLE inventory_old');
      await db.execute('CREATE INDEX idx_inventory_sku ON inventory(sku)');

      // Migrate contacts
      await db.execute('ALTER TABLE contacts RENAME TO contacts_old');
      await db.execute('''
        CREATE TABLE contacts (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          initials TEXT NOT NULL,
          contact TEXT NOT NULL,
          gstin TEXT NOT NULL,
          balance REAL NOT NULL,
          location TEXT NOT NULL,
          type TEXT NOT NULL,
          lastUpdated INTEGER NOT NULL
        )
      ''');
      final List<Map<String, dynamic>> oldContacts = await db.query('contacts_old');
      for (var row in oldContacts) {
        final Map<String, dynamic> newRow = Map.from(row);
        newRow['balance'] = double.tryParse(row['balance'].toString().replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
        await db.insert('contacts', newRow);
      }
      await db.execute('DROP TABLE contacts_old');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quotations (
          id TEXT PRIMARY KEY,
          customerId TEXT NOT NULL,
          customerName TEXT NOT NULL,
          date INTEGER NOT NULL,
          expiryDate INTEGER NOT NULL,
          discount REAL NOT NULL,
          grandTotal REAL NOT NULL,
          status TEXT NOT NULL,
          items TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS returns (
          id TEXT PRIMARY KEY,
          originalInvoiceId TEXT NOT NULL,
          customerId TEXT NOT NULL,
          customerName TEXT NOT NULL,
          date INTEGER NOT NULL,
          grandTotal REAL NOT NULL,
          reason TEXT NOT NULL,
          items TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 7) {
      Log.i('Migrating to v7: Adding Warehouses and Stock Levels', name: 'Database');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS warehouses (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          location TEXT NOT NULL,
          isDefault INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_levels (
          productSku TEXT NOT NULL,
          warehouseId TEXT NOT NULL,
          quantity REAL NOT NULL,
          PRIMARY KEY (productSku, warehouseId)
        )
      ''');
      
      // Initialize Main Yard
      await _insertDefaultWarehouse(db);
      
      // Migrate existing inventory stock to Main Yard
      final products = await db.query('inventory');
      for (var p in products) {
        await db.insert('stock_levels', {
          'productSku': p['sku'],
          'warehouseId': 'main_yard',
          'quantity': p['stock'],
        });
      }
    }
  }

  // --- Inventory ---

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();
    for (var product in products) {
      batch.insert('inventory', product, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('inventory', orderBy: 'name ASC');
  }

  Future<void> deleteProduct(String sku) async {
    final db = await database;
    await db.delete('inventory', where: 'sku = ?', whereArgs: [sku]);
  }

  // --- CRM ---

  Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    final db = await database;
    final batch = db.batch();
    for (var contact in contacts) {
      batch.insert('contacts', contact, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getContacts(String type) async {
    final db = await database;
    return await db.query('contacts', where: 'type = ?', whereArgs: [type], orderBy: 'name ASC');
  }

  // --- Ledgers ---

  Future<List<Map<String, dynamic>>> getLedgerByContactId(String contactId) async {
    final db = await database;
    return await db.query('ledgers', where: 'contactId = ?', whereArgs: [contactId], orderBy: 'date DESC');
  }

  // --- Sales ---

  Future<void> saveInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    await db.insert('sales', invoice, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await database;
    return await db.query('sales', orderBy: 'date DESC');
  }

  Future<void> saveQuotation(Map<String, dynamic> quotation) async {
    final db = await database;
    await db.insert('quotations', quotation, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getQuotations() async {
    final db = await database;
    return await db.query('quotations', orderBy: 'date DESC');
  }

  Future<void> saveReturn(Map<String, dynamic> salesReturn) async {
    final db = await database;
    await db.insert('returns', salesReturn, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReturns() async {
    final db = await database;
    return await db.query('returns', orderBy: 'date DESC');
  }

  // --- Purchases ---

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    final db = await database;
    await db.insert('purchases', purchase, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPurchases() async {
    final db = await database;
    return await db.query('purchases', orderBy: 'date DESC');
  }

  // --- Employees ---

  Future<void> saveEmployees(List<Map<String, dynamic>> employees) async {
    final db = await database;
    final batch = db.batch();
    for (var emp in employees) {
      batch.insert('employees', emp, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    final db = await database;
    return await db.query('employees', orderBy: 'name ASC');
  }

  Future<void> updateEmployeeAttendance(String id, String status) async {
    final db = await database;
    await db.update('employees', {'attendanceStatus': status}, where: 'id = ?', whereArgs: [id]);
  }

  // --- Sync Queue ---

  Future<void> addToSyncQueue({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final db = await database;
    await db.insert('sync_queue', {
      'method': method,
      'path': path,
      'body': body != null ? jsonEncode(body) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    Log.i('➡️ Task added to Sync Queue: $method $path', name: 'Database');
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'timestamp ASC');
  }

  Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // --- Warehouses ---

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    final db = await database;
    return await db.query('warehouses', orderBy: 'isDefault DESC, name ASC');
  }

  Future<void> saveWarehouse(Map<String, dynamic> warehouse) async {
    final db = await database;
    await db.insert('warehouses', warehouse, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Stock Levels ---

  Future<List<Map<String, dynamic>>> getStockLevels(String sku) async {
    final db = await database;
    return await db.query('stock_levels', where: 'productSku = ?', whereArgs: [sku]);
  }

  Future<void> updateStockLevel(String sku, String warehouseId, double delta) async {
    final db = await database;
    await db.transaction((txn) async {
      final results = await txn.query(
        'stock_levels', 
        where: 'productSku = ? AND warehouseId = ?', 
        whereArgs: [sku, warehouseId],
      );

      if (results.isEmpty) {
        await txn.insert('stock_levels', {
          'productSku': sku,
          'warehouseId': warehouseId,
          'quantity': delta,
        });
      } else {
        final current = (results.first['quantity'] as num).toDouble();
        await txn.update(
          'stock_levels',
          {'quantity': current + delta},
          where: 'productSku = ? AND warehouseId = ?',
          whereArgs: [sku, warehouseId],
        );
      }
    });
  }

  // --- Utility Methods ---

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('inventory');
    await db.delete('contacts');
    await db.delete('sales');
    await db.delete('ledgers');
    await db.delete('employees');
    await db.delete('purchases');
    await db.delete('sync_queue');
    await db.delete('warehouses');
    await db.delete('stock_levels');
    await _insertDefaultWarehouse(db);
    Log.w('All local tables cleared and reset', name: 'Database');
  }
}
