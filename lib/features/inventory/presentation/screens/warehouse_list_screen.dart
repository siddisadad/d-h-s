import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/inventory_provider.dart';
import '../../../../core/providers/app_bar_provider.dart';

import '../../domain/entities/warehouse.dart';

class WarehouseListScreen extends ConsumerWidget {
  const WarehouseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehouseNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'MANAGE YARDS / WAREHOUSES',
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddWarehouseDialog(context, ref),
          label: const Text('Add Yard'),
          icon: const Icon(Icons.add_location_alt_rounded),
        ),
      );
    });

    return warehousesAsync.when(
      data: (list) => ListView.separated(
        padding: EdgeInsets.all(tokens.space24),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final w = list[index];
          return CustomCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.location_on_rounded, color: context.colorScheme.primary),
              ),
              title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(w.location),
              trailing: w.isDefault
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: context.tokens.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('DEFAULT', style: TextStyle(color: context.tokens.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                : null,
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showAddWarehouseDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Yard / Warehouse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(label: 'Yard Name', hint: 'e.g. South Branch Yard', controller: nameController),
            const SizedBox(height: 16),
            CustomTextField(label: 'Location', hint: 'e.g. Pune, Maharashtra', controller: locationController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final w = Warehouse(
                id: nameController.text.toLowerCase().replaceAll(' ', '_'),
                name: nameController.text,
                location: locationController.text,
              );
              await ref.read(warehouseNotifierProvider.notifier).addWarehouse(w);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
