import '../../domain/entities/warehouse.dart';

class WarehouseModel extends Warehouse {
  WarehouseModel({
    required super.id,
    required super.name,
    required super.location,
    super.isDefault,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'isDefault': isDefault,
    };
  }

  factory WarehouseModel.fromEntity(Warehouse entity) {
    return WarehouseModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      isDefault: entity.isDefault,
    );
  }
}
