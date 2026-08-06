import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database_providers.dart';

part 'sync_providers.g.dart';

@riverpod
Stream<int> syncQueueCount(SyncQueueCountRef ref) async* {
  final localDb = ref.watch(localDatabaseProvider);

  while (true) {
    final queue = await localDb.getSyncQueue();
    yield queue.length;
    await Future.delayed(const Duration(seconds: 5));
  }
}
