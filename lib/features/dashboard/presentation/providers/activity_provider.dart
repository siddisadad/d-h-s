import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/domain/entities/activity.dart';
import 'package:deshmukh_steel_e_r_p/core/di/injection_container.dart';

part 'activity_provider.g.dart';

@riverpod
Stream<List<Activity>> activityStream(ActivityStreamRef ref) {
  return sl.firebaseDb.watchPath('activities').map((event) {
    final snapshot = event.snapshot;
    if (!snapshot.exists || snapshot.value == null) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    final List<Activity> activities = [];

    data.forEach((key, value) {
      activities.add(Activity.fromJson(Map<String, dynamic>.from(value as Map)));
    });

    // Sort by timestamp descending (newest first)
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
    final newActivity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      type: type,
    );

    await sl.firebaseDb.pushData('activities', newActivity.toJson());
  }
}
