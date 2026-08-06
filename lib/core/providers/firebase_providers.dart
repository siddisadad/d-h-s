import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/firebase_database_service.dart';

part 'firebase_providers.g.dart';

@riverpod
FirebaseDatabaseService firebaseDatabaseService(FirebaseDatabaseServiceRef ref) {
  return FirebaseDatabaseService();
}
