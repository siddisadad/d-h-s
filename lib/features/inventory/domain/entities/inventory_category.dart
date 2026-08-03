import 'package:flutter/material.dart';

class InventoryCategory {
  final String id;
  final String name;
  final String? description;
  final IconData icon;
  final int productCount;

  const InventoryCategory({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    this.productCount = 0,
  });

  InventoryCategory copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    int? productCount,
  }) {
    return InventoryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      productCount: productCount ?? this.productCount,
    );
  }
}
