import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/sales/presentation/screens/sales_invoice_screen.dart';
import '../../features/purchases/presentation/screens/purchases_screen.dart';
import '../../features/crm/presentation/screens/customer_ledger_screen.dart';
import '../../features/crm/presentation/screens/supplier_directory_screen.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/employees/presentation/screens/employee_list_screen.dart';

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
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesInvoiceScreen(),
      ),
      GoRoute(
        path: '/purchases',
        builder: (context, state) => const PurchasesScreen(),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerLedgerScreen(),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SupplierDirectoryScreen(),
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
      ),
      GoRoute(
        path: '/employees',
        builder: (context, state) => const EmployeeListScreen(),
      ),
    ],
  );
}
