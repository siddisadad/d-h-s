import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../utils/logger.dart';
import 'database_schema.dart';
import 'daos/inventory_dao.dart';
import 'daos/crm_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/finance_dao.dart';
import 'daos/employee_dao.dart';
import 'daos/purchases_dao.dart';
import 'daos/audit_dao.dart';
import 'daos/stock_audit_dao.dart';
import 'daos/closing_dao.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Database? _database;

  InventoryDao? _inventoryDao;
  CrmDao? _crmDao;
  SalesDao? _salesDao;
  SyncDao? _syncDao;
  FinanceDao? _financeDao;
  EmployeeDao? _employeeDao;
  PurchasesDao? _purchasesDao;
  AuditDao? _auditDao;
  StockAuditDao? _stockAuditDao;
  ClosingDao? _closingDao;

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('Local Database is not supported on Web');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    _initDaos(_database!);
    return _database!;
  }

  void _initDaos(Database db) {
    _inventoryDao = InventoryDao(db);
    _crmDao = CrmDao(db);
    _salesDao = SalesDao(db);
    _syncDao = SyncDao(db);
    _financeDao = FinanceDao(db);
    _employeeDao = EmployeeDao(db);
    _purchasesDao = PurchasesDao(db);
    _auditDao = AuditDao(db);
    _stockAuditDao = StockAuditDao(db);
    _closingDao = ClosingDao(db);
  }

  Future<Database> _initDatabase() async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      try {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        Log.i('🖥️ sqflite_ffi initialized for LocalDatabase', name: 'Database');
      } catch (e) {
        Log.e('Failed to initialize sqflite_ffi', error: e, name: 'Database');
      }
    }

    String path;
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final directory = await getApplicationSupportDirectory();
      path = join(directory.path, 'dci_erp_v1.db');
    } else {
      path = join(await getDatabasesPath(), 'dci_erp_v1.db');
    }
    Log.d('Initializing Local Database at: $path', name: 'Database');

    return await openDatabase(
      path,
      version: 16,
      onCreate: DatabaseSchema.create,
      onUpgrade: DatabaseSchema.upgrade,
    );
  }

  // --- DAO Accessors ---
  InventoryDao get inventory => _inventoryDao!;
  CrmDao get crm => _crmDao!;
  SalesDao get sales => _salesDao!;
  SyncDao get sync => _syncDao!;
  FinanceDao get finance => _financeDao!;
  EmployeeDao get employee => _employeeDao!;
  AuditDao get audit => _auditDao!;
  StockAuditDao get stockAudit => _stockAuditDao!;
  ClosingDao get closing => _closingDao!;

  // --- Delegated Methods (Backward Compatibility) ---

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    await database;
    await _inventoryDao!.saveProducts(products);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    await database;
    return await _inventoryDao!.getProducts();
  }

  Future<void> deleteProduct(String sku) async {
    await database;
    await _inventoryDao!.deleteProduct(sku);
  }

  Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    await database;
    await _crmDao!.saveContacts(contacts);
  }

  Future<List<Map<String, dynamic>>> getContacts(String type) async {
    await database;
    return await _crmDao!.getContacts(type);
  }

  Future<List<Map<String, dynamic>>> getLedgerByContactId(String contactId) async {
    await database;
    return await _crmDao!.getLedgerByContactId(contactId);
  }

  Future<void> saveInvoice(Map<String, dynamic> invoice) async {
    await database;
    await _salesDao!.saveInvoice(invoice);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    await database;
    return await _salesDao!.getInvoices();
  }

  Future<void> saveQuotation(Map<String, dynamic> quotation) async {
    await database;
    await _salesDao!.saveQuotation(quotation);
  }

  Future<List<Map<String, dynamic>>> getQuotations() async {
    await database;
    return await _salesDao!.getQuotations();
  }

  Future<void> saveReturn(Map<String, dynamic> salesReturn) async {
    await database;
    await _salesDao!.saveReturn(salesReturn);
  }

  Future<List<Map<String, dynamic>>> getReturns() async {
    await database;
    return await _salesDao!.getReturns();
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    await database;
    await _purchasesDao!.savePurchase(purchase);
  }

  Future<List<Map<String, dynamic>>> getPurchases() async {
    await database;
    return await _purchasesDao!.getPurchases();
  }

  Future<void> saveFinanceEntry(Map<String, dynamic> entry) async {
    await database;
    await _financeDao!.saveFinanceEntry(entry);
  }

  Future<List<Map<String, dynamic>>> getFinanceEntries() async {
    await database;
    return await _financeDao!.getFinanceEntries();
  }

  Future<void> saveEmployees(List<Map<String, dynamic>> employees) async {
    await database;
    await _employeeDao!.saveEmployees(employees);
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    await database;
    return await _employeeDao!.getEmployees();
  }

  Future<void> updateEmployeeAttendance(String id, String status) async {
    await database;
    await _employeeDao!.updateEmployeeAttendance(id, status);
  }

  Future<void> addToSyncQueue({required String method, required String path, Map<String, dynamic>? body}) async {
    await database;
    await _syncDao!.addToSyncQueue(method: method, path: path, body: body);
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    await database;
    return await _syncDao!.getSyncQueue();
  }

  Future<void> removeFromSyncQueue(int id) async {
    await database;
    await _syncDao!.removeFromSyncQueue(id);
  }

  Future<List<Map<String, dynamic>>> getWarehouses() async {
    final db = await database;
    return await db.query('warehouses', orderBy: 'isDefault DESC, name ASC');
  }

  Future<void> saveWarehouse(Map<String, dynamic> warehouse) async {
    final db = await database;
    await db.insert('warehouses', warehouse, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStockLevels(String sku) async {
    await database;
    return await _inventoryDao!.getStockLevels(sku);
  }

  Future<void> updateStockLevel(String sku, String warehouseId, double delta, {DatabaseExecutor? executor}) async {
    await database;
    await _inventoryDao!.updateStockLevel(sku, warehouseId, delta, executor: executor);
  }

  Future<void> saveStockMovement(Map<String, dynamic> movement, {DatabaseExecutor? executor}) async {
    await database;
    await _inventoryDao!.saveStockMovement(movement, executor: executor);
  }

  Future<List<Map<String, dynamic>>> getStockMovements(String sku) async {
    await database;
    return await _inventoryDao!.getStockMovements(sku);
  }

  Future<List<Map<String, dynamic>>> getAllStockMovements() async {
    await database;
    return await _inventoryDao!.getAllStockMovements();
  }

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
    await db.delete('stock_movements');
    await db.insert('warehouses', {
      'id': 'main_yard',
      'name': 'Main Yard',
      'location': 'Primary yard location',
      'isDefault': 1,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    Log.w('All local tables cleared and reset', name: 'Database');
  }
}
