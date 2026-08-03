import 'package:flutter/material.dart';

enum AdjustmentReason {
  damaged('Damaged', Icons.broken_image_rounded),
  lost('Lost/Stolen', Icons.search_off_rounded),
  found('Found/Audit', Icons.add_moderator_rounded),
  restock('Manual Restock', Icons.inventory_2_rounded),
  correction('Correction', Icons.edit_note_rounded),
  expired('Expired', Icons.event_busy_rounded);

  final String label;
  final IconData icon;
  const AdjustmentReason(this.label, this.icon);
}

class StockAdjustment {
  final String id;
  final String productSku;
  final String productName;
  final String warehouseId;
  final double quantityChange;
  final AdjustmentReason reason;
  final DateTime timestamp;
  final String performedBy;
  final String? notes;

  const StockAdjustment({
    required this.id,
    required this.productSku,
    required this.productName,
    required this.warehouseId,
    required this.quantityChange,
    required this.reason,
    required this.timestamp,
    required this.performedBy,
    this.notes,
  });
}
