import 'package:flutter/foundation.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats.dart';
import '../../features/crm/data/datasources/crm_remote_data_source.dart';
import '../../features/crm/data/repositories/crm_repository_impl.dart';
import '../../features/crm/domain/repositories/crm_repository.dart';
import '../../features/crm/domain/usecases/get_contacts.dart';
import '../../features/inventory/data/datasources/inventory_remote_data_source.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/get_products.dart';
import '../../features/sales/data/datasources/sales_remote_data_source.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/usecases/create_invoice.dart';
import '../../features/purchases/data/datasources/purchase_remote_data_source.dart';
import '../../features/purchases/data/repositories/purchase_repository_impl.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../../features/employees/data/datasources/employee_remote_data_source.dart';
import '../../features/employees/data/repositories/employee_repository_impl.dart';
import '../../features/employees/domain/repositories/employee_repository.dart';
import '../../features/finance/data/datasources/finance_remote_data_source.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/datasources/auth_mock_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  bool _isInitialized = false;

  late GetProducts getProductsUseCase;
  late GetDashboardStats getStatsUseCase;
  late CreateInvoice createInvoiceUseCase;
  late GetContacts getContactsUseCase;

  late InventoryRepository inventoryRepository;
  late DashboardRepository dashboardRepository;
  late SalesRepository salesRepository;
  late CrmRepository crmRepository;
  late PurchaseRepository purchaseRepository;
  late EmployeeRepository employeeRepository;
  late FinanceRepository financeRepository;
  late AuthRepository authRepository;

  void init(ApiClient client) {
    if (_isInitialized) {
      debugPrint('📦 [DI] Service Locator already initialized');
      return;
    }

    final useMocks = AppConfig.useMocks;
    debugPrint('📦 [DI] Initializing Service Locator (Mocks: $useMocks)...');

    // 1. Authentication
    final authDataSource = useMocks 
        ? AuthMockDataSource() 
        : AuthRemoteDataSourceImpl(client);
    authRepository = AuthRepositoryImpl(authDataSource);

    // 2. Inventory
    final inventoryDataSource = useMocks
        ? InventoryMockDataSourceImpl()
        : InventoryRemoteDataSourceImpl(client);
    inventoryRepository = InventoryRepositoryImpl(remoteDataSource: inventoryDataSource);
    getProductsUseCase = GetProducts(inventoryRepository);

    // 3. Dashboard
    final dashboardDataSource = useMocks
        ? DashboardMockDataSourceImpl()
        : DashboardRemoteDataSourceImpl(client);
    dashboardRepository = DashboardRepositoryImpl(remoteDataSource: dashboardDataSource);
    getStatsUseCase = GetDashboardStats(dashboardRepository);

    // 4. Sales
    final salesDataSource = useMocks
        ? SalesMockDataSourceImpl()
        : SalesRemoteDataSourceImpl(client);
    salesRepository = SalesRepositoryImpl(remoteDataSource: salesDataSource);
    createInvoiceUseCase = CreateInvoice(salesRepository);

    // 5. CRM
    final crmDataSource = useMocks
        ? CrmMockDataSourceImpl()
        : CrmRemoteDataSourceImpl(client);
    crmRepository = CrmRepositoryImpl(remoteDataSource: crmDataSource);
    getContactsUseCase = GetContacts(crmRepository);

    // 6. Purchases
    final purchaseDataSource = useMocks
        ? PurchaseMockDataSourceImpl()
        : PurchaseRemoteDataSourceImpl(client);
    purchaseRepository = PurchaseRepositoryImpl(remoteDataSource: purchaseDataSource);

    // 7. Employees
    final employeeDataSource = useMocks
        ? EmployeeMockDataSourceImpl()
        : EmployeeRemoteDataSourceImpl(client);
    employeeRepository = EmployeeRepositoryImpl(remoteDataSource: employeeDataSource);

    // 8. Finance
    final financeDataSource = useMocks
        ? FinanceMockDataSourceImpl()
        : FinanceRemoteDataSourceImpl(client);
    financeRepository = FinanceRepositoryImpl(remoteDataSource: financeDataSource);

    _isInitialized = true;
    debugPrint('✅ [DI] Service Locator Ready');
  }
}

final sl = InjectionContainer();
