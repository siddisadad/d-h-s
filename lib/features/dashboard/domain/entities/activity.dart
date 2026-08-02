class Activity {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final ActivityType type;

  Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });
}

enum ActivityType { sale, purchase, stockAdjustment, userLogin }
