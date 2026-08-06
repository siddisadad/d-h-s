import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/inventory/presentation/providers/inventory_provider.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/product_detail_screen.dart';
import '../../features/inventory/presentation/screens/product_form_screen.dart';
import '../../features/inventory/presentation/screens/stock_adjustments_screen.dart';
import '../../features/inventory/presentation/screens/categories_screen.dart';
import '../../features/inventory/presentation/screens/warehouse_list_screen.dart';
import '../../features/inventory/presentation/screens/stock_transfer_screen.dart';
import '../../features/sales/presentation/screens/sales_management_screen.dart';
import '../../features/sales/presentation/screens/sales_invoice_screen.dart';
import '../../features/sales/presentation/screens/sales_quotes_screen.dart';
import '../../features/sales/presentation/screens/quotation_form_screen.dart';
import '../../features/sales/presentation/screens/sales_returns_screen.dart';
import '../../features/sales/presentation/screens/return_form_screen.dart';
import '../../features/purchases/presentation/screens/purchases_screen.dart';
import '../../features/purchases/presentation/screens/purchase_entry_screen.dart';
import '../../features/crm/presentation/screens/contact_form_screen.dart';
import '../../features/crm/presentation/screens/customer_directory_screen.dart';
import '../../features/crm/presentation/screens/customer_ledger_screen.dart';
import '../../features/crm/presentation/screens/supplier_directory_screen.dart';
import '../../features/crm/presentation/screens/payment_reminders_screen.dart';
import '../../features/crm/domain/entities/contact.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/sync_center_screen.dart';
import '../../features/employees/presentation/screens/employee_list_screen.dart';
import '../../features/employees/presentation/screens/employee_form_screen.dart';
import '../../features/employees/presentation/screens/attendance_screen.dart';
import '../../features/employees/presentation/screens/payroll_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../design_system/app_scaffold.dart';
import '../security/permissions.dart';

import '../providers/startup_provider.dart';
import 'router_notifier.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouterWidget(AppRouterWidgetRef ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);
      final startupAsync = ref.read(startupProvider);

      debugPrint('🛣️ [Router] path=${state.uri.path}');
      debugPrint('   ↳ Auth: hasValue=${authAsync.hasValue}, isLoading=${authAsync.isLoading}');
      if (authAsync.hasValue && authAsync.value != null) {
        final u = authAsync.value!;
        debugPrint('   ↳ User: ID=${u.id}, Email=${u.email}, Role=${u.role}');
      }
      debugPrint('   ↳ Startup: hasValue=${startupAsync.hasValue}, isLoading=${startupAsync.isLoading}');

      // 1. Wait for Startup & Session recovery
      if (startupAsync.isLoading || authAsync.isLoading) {
        debugPrint('   ↳ Action: WAITING (Loading state)');
        return null;
      }

      final isLogin = state.uri.path == '/login';
      final authUser = authAsync.value;

      // 2. Not Logged In -> Force Login
      if (authUser == null) {
        if (isLogin) return null;
        debugPrint('   ↳ Action: REDIRECT to /login (Unauthenticated)');
        return '/login';
      }

      // 3. Logged In -> Prevent Login Page access
      if (isLogin) {
        debugPrint('   ↳ Action: REDIRECT to /dashboard (Authenticated)');
        return '/dashboard';
      }

      // 4. Authorization Guard
      final path = state.uri.path;
      final role = authUser.role;

      if (path.startsWith('/analytics') && !RolePermissions.hasPermission(role, AppPermission.viewAnalytics)) {
        return '/dashboard';
      }
      if (path.startsWith('/finance') && !RolePermissions.hasPermission(role, AppPermission.viewFinance)) {
        return '/dashboard';
      }
      if (path.startsWith('/employees/payroll') && !RolePermissions.hasPermission(role, AppPermission.viewSalaries)) {
        return '/employees';
      }
      if (path.startsWith('/employees') && !RolePermissions.hasPermission(role, AppPermission.viewEmployees)) {
        return '/dashboard';
      }
      if (path.startsWith('/inventory/adjustments') && !RolePermissions.hasPermission(role, AppPermission.adjustStock)) {
        return '/inventory';
      }
      if (path.startsWith('/customers/') && !RolePermissions.hasPermission(role, AppPermission.viewLedgers)) {
        return '/customers';
      }
      if (path.startsWith('/suppliers/') && !RolePermissions.hasPermission(role, AppPermission.viewLedgers)) {
        return '/suppliers';
      }
      if (path.startsWith('/settings') && !RolePermissions.hasPermission(role, AppPermission.manageSettings)) {
        return '/dashboard';
      }

      debugPrint('   ↳ Action: PROCEED to ${state.uri.path}');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/login',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(
            title: '', // Screens will update the title via provider
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ProductFormScreen(),
              ),
              GoRoute(
                path: 'edit/:sku',
                builder: (context, state) => ProductFormScreen(
                  product: ref.read(inventoryNotifierProvider).value?.firstWhere((p) => p.sku == state.pathParameters['sku']),
                ),
              ),
              GoRoute(
                path: 'adjustments',
                builder: (context, state) => const StockAdjustmentsScreen(),
              ),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
              GoRoute(
                path: 'transfer',
                builder: (context, state) => const StockTransferScreen(),
              ),
              GoRoute(
                path: 'warehouses',
                builder: (context, state) => const WarehouseListScreen(),
              ),
              GoRoute(
                path: ':sku',
                builder: (context, state) => ProductDetailScreen(
                  sku: state.pathParameters['sku']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/sales',
            builder: (context, state) => const SalesManagementScreen(),
            routes: [
              GoRoute(
                path: 'invoice',
                builder: (context, state) => const SalesInvoiceScreen(),
              ),
              GoRoute(
                path: 'quotes',
                builder: (context, state) => const SalesQuotesScreen(),
              ),
              GoRoute(
                path: 'returns',
                builder: (context, state) => const SalesReturnsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const ReturnFormScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'new-quote',
                builder: (context, state) => const QuotationFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/purchases',
            builder: (context, state) => const PurchasesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const PurchaseEntryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerDirectoryScreen(),
            routes: [
              GoRoute(
                path: 'reminders',
                builder: (context, state) => const PaymentRemindersScreen(),
              ),
              GoRoute(
                path: 'new',
                builder: (context, state) => const ContactFormScreen(type: ContactType.customer),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerLedgerScreen(
                  customerId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/suppliers',
            builder: (context, state) => const SupplierDirectoryScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ContactFormScreen(type: ContactType.supplier),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerLedgerScreen(
                  customerId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'sync',
                builder: (context, state) => const SyncCenterScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/employees',
            builder: (context, state) => const EmployeeListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const EmployeeFormScreen(),
              ),
              GoRoute(
                path: 'attendance',
                builder: (context, state) => const AttendanceScreen(),
              ),
              GoRoute(
                path: 'payroll',
                builder: (context, state) => const PayrollScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
