import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/local_database.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
LocalDatabase localDatabase(LocalDatabaseRef ref) {
  return LocalDatabase();
}

@riverpod
Future<List<Map<String, dynamic>>> syncQueue(SyncQueueRef ref) {
  return ref.watch(localDatabaseProvider).getSyncQueue();
}
