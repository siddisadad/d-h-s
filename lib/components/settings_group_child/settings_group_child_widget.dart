import '/components/settings_item/settings_item_widget.dart';
import '../../core/design_system/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsGroupChildWidget extends StatelessWidget {
  const SettingsGroupChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsItemWidget(
          hasSubtitle: true,
          icon: Icon(
            Icons.store_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Business Details',
          subtitle: 'Name, Address, Contact info',
        ),
        Divider(
          height: 16.0,
          thickness: 1.0,
          indent: 56.0,
          endIndent: 0.0,
          color: context.colorScheme.outline,
        ),
        SettingsItemWidget(
          hasSubtitle: true,
          icon: Icon(
            Icons.receipt_long_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Invoice Settings',
          subtitle: 'Prefix, Logo, Signature, Terms',
        ),
        Divider(
          height: 16.0,
          thickness: 1.0,
          indent: 56.0,
          endIndent: 0.0,
          color: context.colorScheme.outline,
        ),
        SettingsItemWidget(
          hasSubtitle: true,
          icon: Icon(
            Icons.percent_rounded,
            color: context.colorScheme.primary,
            size: 22.0,
          ),
          label: 'Tax & Pricing Rules',
          subtitle: 'GST rates, HSN codes, Currency',
        ),
      ],
    );
  }
}
