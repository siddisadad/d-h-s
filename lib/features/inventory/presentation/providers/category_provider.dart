import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/inventory_category.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  List<InventoryCategory> build() {
    return const [
      InventoryCategory(
        id: '1',
        name: 'Steel & Iron',
        description: 'TMT bars, structural steel, and sheets.',
        icon: Icons.architecture_rounded,
        productCount: 450,
      ),
      InventoryCategory(
        id: '2',
        name: 'Power Tools',
        description: 'Drills, grinders, and industrial machinery.',
        icon: Icons.handyman_rounded,
        productCount: 120,
      ),
      InventoryCategory(
        id: '3',
        name: 'Plumbing',
        description: 'Pipes, valves, and bathroom fittings.',
        icon: Icons.plumbing_rounded,
        productCount: 380,
      ),
      InventoryCategory(
        id: '4',
        name: 'Electrical',
        description: 'Cables, switches, and lighting solutions.',
        icon: Icons.electric_bolt_rounded,
        productCount: 210,
      ),
      InventoryCategory(
        id: '5',
        name: 'Fasteners',
        description: 'Nuts, bolts, and screws.',
        icon: Icons.settings_input_component_rounded,
        productCount: 850,
      ),
    ];
  }

  void addCategory(InventoryCategory category) {
    state = [...state, category];
  }

  void updateCategory(InventoryCategory category) {
    state = [
      for (final cat in state)
        if (cat.id == category.id) category else cat
    ];
  }

  void deleteCategory(String id) {
    state = state.where((cat) => cat.id != id).toList();
  }
}

@riverpod
List<String> categoryNames(CategoryNamesRef ref) {
  final categories = ref.watch(categoryNotifierProvider);
  return ['All Items', ...categories.map((c) => c.name)];
}
