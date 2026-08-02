import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:deshmukh_steel_e_r_p/features/dashboard/domain/entities/activity.dart';

part 'activity_provider.g.dart';

@riverpod
class ActivityNotifier extends _$ActivityNotifier {
  @override
  Future<List<Activity>> build() async {
    // Initial In-Memory Log
    return [
      Activity(
        id: '1',
        title: 'System Initialized',
        subtitle: 'Deshmukh ERP Cloud Mode Active',
        timestamp: DateTime.now(),
        type: ActivityType.userLogin,
      ),
    ];
  }

  Future<void> addActivity(String title, String subtitle, ActivityType type) async {
    final currentActivities = await future;
    
    final newActivity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      type: type,
    );

    state = AsyncData([newActivity, ...currentActivities]);
  }
}
