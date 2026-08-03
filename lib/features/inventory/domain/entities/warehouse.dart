class Warehouse {
  final String id;
  final String name;
  final String location;
  final bool isDefault;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    this.isDefault = false,
  });
}
