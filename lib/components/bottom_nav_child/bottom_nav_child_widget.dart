import '/components/nav_item/nav_item_widget.dart';
import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BottomNavChildWidget extends StatelessWidget {
  const BottomNavChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavItemWidget(
          label: 'Home',
          icon: Icon(
            Icons.dashboard_rounded,
            color: context.colorScheme.onSurface,
            size: 24.0,
          ),
          target: 'MainDashboard',
          selected: true,
        ),
        NavItemWidget(
          label: 'Inventory',
          icon: Icon(
            Icons.inventory_rounded,
            color: context.colorScheme.onSurface,
            size: 24.0,
          ),
          target: 'ProductInventory',
          selected: false,
        ),
        NavItemWidget(
          label: 'Sales',
          icon: Icon(
            Icons.receipt_long_rounded,
            color: context.colorScheme.onSurface,
            size: 24.0,
          ),
          target: 'SalesInvoiceEntry',
          selected: false,
        ),
        NavItemWidget(
          label: 'Finance',
          icon: Icon(
            Icons.account_balance_rounded,
            color: context.colorScheme.onSurface,
            size: 24.0,
          ),
          target: 'FinanceCashBook',
          selected: false,
        ),
        NavItemWidget(
          label: 'Settings',
          icon: Icon(
            Icons.settings_rounded,
            color: context.colorScheme.onSurface,
            size: 24.0,
          ),
          target: 'BusinessSettings',
          selected: false,
        ),
      ],
    );
  }
}
