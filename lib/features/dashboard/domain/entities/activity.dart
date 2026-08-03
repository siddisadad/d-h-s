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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.name,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      type: ActivityType.values.byName(json['type'] as String),
    );
  }
}

enum ActivityType { sale, purchase, stockAdjustment, userLogin }
