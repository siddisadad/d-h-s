import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';

class DatabaseSchema {
  static Future<void> create(Database db, int version) async {
    Log.i('Creating local tables (v$version)...', name: 'Database');
    await _createTables(db);
    await _insertDefaultWarehouse(db);
  }

  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
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
    // ... all other migrations from LocalDatabase._onUpgrade ...
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
      await _insertDefaultWarehouse(db);
      final products = await db.query('inventory');
      for (var p in products) {
        await db.insert('stock_levels', {
          'productSku': p['sku'],
          'warehouseId': 'main_yard',
          'quantity': p['stock'],
        });
      }
    }
    if (oldVersion < 9) {
      Log.i('Migrating to v9: Adding Stock Movements Table', name: 'Database');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_movements (
          id TEXT PRIMARY KEY,
          productSku TEXT NOT NULL,
          productName TEXT NOT NULL,
          warehouseId TEXT NOT NULL,
          toWarehouseId TEXT,
          quantity REAL NOT NULL,
          reason TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          performedBy TEXT NOT NULL,
          notes TEXT
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_movements_product ON stock_movements(productSku)');
    }
    if (oldVersion < 10) {
      Log.i('Migrating to v10: Adding HSN Code and Credit Limit', name: 'Database');
      try {
        await db.execute('ALTER TABLE inventory ADD COLUMN hsnCode TEXT');
      } catch (e) {
        Log.w('Column hsnCode already exists in inventory');
      }
      try {
        await db.execute('ALTER TABLE contacts ADD COLUMN creditLimit REAL DEFAULT 0.0');
      } catch (e) {
        Log.w('Column creditLimit already exists in contacts');
      }
    }
    if (oldVersion < 12) {
      Log.i('Migrating to v12: Global Standardization (lastUpdated & String IDs)', name: 'Database');

      // Update Finance Entries
      await db.execute('ALTER TABLE finance_entries RENAME TO finance_entries_old');
      await db.execute('''
        CREATE TABLE finance_entries (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          paymentMode TEXT NOT NULL,
          lastUpdated INTEGER NOT NULL
        )
      ''');
      final finance = await db.query('finance_entries_old');
      for (var row in finance) {
        await db.insert('finance_entries', {
          'id': 'FIN-${row['id']}-${DateTime.now().millisecondsSinceEpoch}',
          'title': row['title'],
          'category': row['category'],
          'amount': row['amount'],
          'date': row['date'],
          'paymentMode': row['paymentMode'],
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await db.execute('DROP TABLE finance_entries_old');

      // Update Quotations
      try {
        await db.execute('ALTER TABLE quotations ADD COLUMN lastUpdated INTEGER DEFAULT 0');
      } catch (_) {}

      // Update Returns
      try {
        await db.execute('ALTER TABLE returns ADD COLUMN lastUpdated INTEGER DEFAULT 0');
      } catch (_) {}

      // Update Sales
      try {
        await db.execute('ALTER TABLE sales ADD COLUMN lastUpdated INTEGER DEFAULT 0');
      } catch (_) {}

      // Update Purchases
      try {
        await db.execute('ALTER TABLE purchases ADD COLUMN lastUpdated INTEGER DEFAULT 0');
      } catch (_) {}
    }
    if (oldVersion < 13) {
      Log.i('Migrating to v13: Hardening Database (Indexing & Audit Logs)', name: 'Database');

      // 1. Audit Logs Table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS audit_logs (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subtitle TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          type TEXT NOT NULL,
          metadata TEXT
        )
      ''');

      // 2. Indexing for Performance
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_finance_date ON finance_entries(date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ledgers_date ON ledgers(date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ledgers_contact_date ON ledgers(contactId, date)');
    }
    if (oldVersion < 14) {
      Log.i('Migrating to v14: Adding Stock Audit Tables', name: 'Database');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_audits (
          id TEXT PRIMARY KEY,
          warehouseId TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          performedBy TEXT NOT NULL,
          status TEXT NOT NULL,
          lastUpdated INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS stock_audit_items (
          auditId TEXT NOT NULL,
          productSku TEXT NOT NULL,
          productName TEXT NOT NULL,
          systemQuantity REAL NOT NULL,
          physicalQuantity REAL NOT NULL,
          PRIMARY KEY (auditId, productSku)
        )
      ''');
    }
    if (oldVersion < 15) {
      Log.i('Migrating to v15: Adding Daily Cash Closing', name: 'Database');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_closings (
          id TEXT PRIMARY KEY,
          date INTEGER NOT NULL,
          openingBalance REAL NOT NULL,
          totalCashSales REAL NOT NULL,
          totalCashExpenses REAL NOT NULL,
          closingBalance REAL NOT NULL,
          physicalCashCount REAL NOT NULL,
          difference REAL NOT NULL,
          notes TEXT,
          performedBy TEXT NOT NULL,
          lastUpdated INTEGER NOT NULL
        )
      ''');

      // Indexing for closures
      await db.execute('CREATE INDEX IF NOT EXISTS idx_closings_date ON daily_closings(date)');
    }
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        sku TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock REAL NOT NULL,
        unit TEXT NOT NULL,
        isLowStock INTEGER DEFAULT 0,
        hsnCode TEXT,
        lastUpdated INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_inventory_sku ON inventory(sku)');

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
        creditLimit REAL DEFAULT 0.0,
        lastReminderSent INTEGER,
        lastUpdated INTEGER NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        customerName TEXT NOT NULL,
        date INTEGER NOT NULL,
        discount REAL NOT NULL,
        grandTotal REAL NOT NULL,
        items TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

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
    await db.execute('CREATE INDEX IF NOT EXISTS idx_ledgers_contact ON ledgers(contactId)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS finance_entries (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        paymentMode TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchases (
        id TEXT PRIMARY KEY,
        supplierId TEXT NOT NULL,
        supplierName TEXT NOT NULL,
        date INTEGER NOT NULL,
        discount REAL NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        items TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

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
        items TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
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
        items TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS warehouses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        isDefault INTEGER DEFAULT 0
      )
    ''');

    // 12. Stock Movements Table (Audit Trail)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_movements (
        id TEXT PRIMARY KEY,
        productSku TEXT NOT NULL,
        productName TEXT NOT NULL,
        warehouseId TEXT NOT NULL,
        toWarehouseId TEXT,
        quantity REAL NOT NULL,
        reason TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        performedBy TEXT NOT NULL,
        notes TEXT
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_movements_product ON stock_movements(productSku)');

    // 13. Audit Logs Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL,
        metadata TEXT
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp)');

    // Performance Indices
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_purchases_date ON purchases(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finance_date ON finance_entries(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_ledgers_date ON ledgers(date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_ledgers_contact_date ON ledgers(contactId, date)');

    // 14. Stock Audit Tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_audits (
        id TEXT PRIMARY KEY,
        warehouseId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        performedBy TEXT NOT NULL,
        status TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_audit_items (
        auditId TEXT NOT NULL,
        productSku TEXT NOT NULL,
        productName TEXT NOT NULL,
        systemQuantity REAL NOT NULL,
        physicalQuantity REAL NOT NULL,
        PRIMARY KEY (auditId, productSku)
      )
    ''');

    // 15. Daily Cash Closing
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_closings (
        id TEXT PRIMARY KEY,
        date INTEGER NOT NULL,
        openingBalance REAL NOT NULL,
        totalCashSales REAL NOT NULL,
        totalCashExpenses REAL NOT NULL,
        closingBalance REAL NOT NULL,
        physicalCashCount REAL NOT NULL,
        difference REAL NOT NULL,
        notes TEXT,
        performedBy TEXT NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_closings_date ON daily_closings(date)');
  }

  static Future<void> _insertDefaultWarehouse(Database db) async {
    await db.insert('warehouses', {
      'id': 'main_yard',
      'name': 'Main Yard',
      'location': 'Primary yard location',
      'isDefault': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
