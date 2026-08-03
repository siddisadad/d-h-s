import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/empty_state_widget.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/presentation/providers/procurement_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/analytics/domain/entities/restock_suggestion.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/presentation/providers/crm_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/crm/domain/entities/contact.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/providers/purchase_provider.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/domain/entities/purchase_item.dart';
import 'package:deshmukh_steel_e_r_p/features/purchases/presentation/screens/purchase_entry_screen.dart';

class ProcurementPlannerScreen extends ConsumerWidget {
  const ProcurementPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(suggestionsBySupplierProvider);
    final suppliersAsync = ref.watch(crmNotifierProvider(ContactType.supplier));
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'SMART PROCUREMENT PLANNER',
      );
    });

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: groupedAsync.when(
        data: (grouped) {
          if (grouped.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.auto_awesome_rounded,
              title: 'All Stocked Up',
              message: 'AI predictions show no urgent restock requirements for your inventory.',
            );
          }

          return suppliersAsync.when(
            data: (suppliers) => ListView.builder(
              padding: EdgeInsets.all(tokens.space24),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final supplierId = grouped.keys.elementAt(index);
                final suggestions = grouped[supplierId]!;
                final supplier = suppliers.firstWhere(
                  (s) => s.id == supplierId, 
                  orElse: () => const Contact(
                    id: 'unknown', 
                    name: 'Unknown Supplier', 
                    initials: '?', 
                    contact: '', 
                    gstin: '', 
                    balance: 0, 
                    location: '', 
                    type: ContactType.supplier
                  )
                );

                return _buildSupplierGroup(context, supplier, suggestions);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading suppliers: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading suggestions: $e')),
      ),
    );
  }

  Widget _buildSupplierGroup(BuildContext context, Contact supplier, List<RestockSuggestion> suggestions) {
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);
    final totalValue = suggestions.fold(0.0, (sum, s) => sum + (s.suggestedQty * s.product.price));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(supplier.initials, style: TextStyle(fontSize: 10, color: context.colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(supplier.name.toUpperCase(), style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            const Spacer(),
            Text(currency.format(totalValue), style: context.textTheme.labelLarge?.copyWith(color: context.colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 12),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ...suggestions.map((s) => _buildSuggestionItem(context, s)),
              _buildActionFooter(context, supplier, suggestions),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSuggestionItem(BuildContext context, RestockSuggestion s) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Text(s.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _urgencyBadge(context, s.urgency),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.reason, style: TextStyle(fontSize: 11, color: context.colorScheme.error)),
          Text('Current Stock: ${s.product.stock} ${s.product.unit}', style: context.textTheme.bodySmall),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('SUGGESTED', style: context.textTheme.labelSmall?.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
          Text('${s.suggestedQty.toStringAsFixed(0)} ${s.product.unit}', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: context.colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context, Contact supplier, List<RestockSuggestion> suggestions) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: CustomButton(
        text: 'CREATE DRAFT PURCHASE ORDER',
        fullWidth: true,
        variant: CustomButtonVariant.outline,
        onPressed: () {
          final items = suggestions.map((s) => PurchaseItem(
            name: s.product.name,
            sku: s.product.sku,
            costPrice: s.product.price * 0.9, // Estimate 10% discount from master price
            qty: s.suggestedQty,
            gstRate: 18,
          )).toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseEntryScreen(
                prefilledSupplier: supplier,
                prefilledItems: items,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _urgencyBadge(BuildContext context, RestockUrgency urgency) {
    Color color;
    switch (urgency) {
      case RestockUrgency.critical: color = context.colorScheme.error; break;
      case RestockUrgency.high: color = Colors.orange; break;
      case RestockUrgency.medium: color = context.colorScheme.primary; break;
      case RestockUrgency.low: color = context.colorScheme.secondary; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Text(urgency.name.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}
