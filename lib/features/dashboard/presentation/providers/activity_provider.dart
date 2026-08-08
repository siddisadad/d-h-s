import 'package:deshmukh_steel_e_r_p/features/dashboard/domain/entities/activity.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/firebase_providers.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/database_providers.dart';
import 'package:flutter/foundation.dart';

part 'activity_provider.g.dart';

@riverpod
Stream<List<Activity>> activityStream(ActivityStreamRef ref) {
  // Merge Local Audit Logs and Firebase Activities
  final firebaseDb = ref.watch(firebaseDatabaseServiceProvider);
  final localDb = ref.watch(localDatabaseProvider);

  if (kIsWeb) {
    return firebaseDb.watchPath('activities').map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final List<Activity> activities = [];
      data.forEach((key, value) {
        activities.add(Activity.fromJson(Map<String, dynamic>.from(value as Map)));
      });
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities;
    });
  }

  // Combine both sources
  return Stream.periodic(const Duration(seconds: 1)).asyncMap((_) async {
    final localLogs = await localDb.audit.getAuditLogs();
    final List<Activity> activities = localLogs.map((l) => Activity(
      id: l['id'],
      title: l['title'],
      subtitle: l['subtitle'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(l['timestamp']),
      type: ActivityType.values.firstWhere((e) => e.name == l['type'], orElse: () => ActivityType.userLogin),
    )).toList();

    // Optionally fetch from Firebase to complement
    try {
      final snapshot = await firebaseDb.getData('activities');
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final remoteActivity = Activity.fromJson(Map<String, dynamic>.from(value as Map));
          if (!activities.any((a) => a.id == remoteActivity.id)) {
            activities.add(remoteActivity);
          }
        });
      }
    } catch (_) {}

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  });
}

@riverpod
class ActivityNotifier extends _$ActivityNotifier {
  @override
  FutureOr<List<Activity>> build() async {
    return [];
  }

  Future<void> addActivity(String title, String subtitle, ActivityType type) async {
    final firebaseDb = ref.read(firebaseDatabaseServiceProvider);
    final localDb = ref.read(localDatabaseProvider);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now();

    final newActivity = Activity(
      id: id,
      title: title,
      subtitle: subtitle,
      timestamp: timestamp,
      type: type,
    );

    // 1. Save to Firebase
    await firebaseDb.pushData('activities', newActivity.toJson());

    // 2. Save Locally (Persistence)
    if (!kIsWeb) {
      await localDb.audit.logActivity(
        id: id,
        title: title,
        subtitle: subtitle,
        timestamp: timestamp.millisecondsSinceEpoch,
        type: type.name,
      );
    }
  }
}
