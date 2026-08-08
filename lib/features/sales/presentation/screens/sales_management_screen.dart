import 'package:deshmukh_steel_e_r_p/features/sales/presentation/providers/sales_history_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/services/excel_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'sales_invoice_screen.dart';
import 'sales_quotes_screen.dart';
import 'sales_returns_screen.dart';
import 'sales_history_screen.dart';

class SalesManagementScreen extends ConsumerStatefulWidget {
  const SalesManagementScreen({super.key});

  @override
  ConsumerState<SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends ConsumerState<SalesManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'SALES MANAGEMENT',
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
               final sales = ref.read(salesHistoryProvider).value ?? [];
               ref.read(excelServiceProvider.notifier).exportSalesReport(sales);
            },
          ),
        ],
      );
    });

    return Column(
      children: [
        _buildTabBar(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              SalesInvoiceScreen(),
              SalesHistoryScreen(),
              SalesQuotesScreen(),
              SalesReturnsScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: context.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: context.colorScheme.primary,
        unselectedLabelColor: context.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: context.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'NEW SALE'),
          Tab(text: 'HISTORY'),
          Tab(text: 'QUOTATIONS'),
          Tab(text: 'RETURNS'),
        ],
      ),
    );
  }
}
