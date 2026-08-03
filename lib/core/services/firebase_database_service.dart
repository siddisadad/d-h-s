import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../di/injection_container.dart';

part 'firebase_database_service.g.dart';

@riverpod
FirebaseDatabaseService firebaseDatabaseService(FirebaseDatabaseServiceRef ref) => sl.firebaseDb;

class FirebaseDatabaseService {
  FirebaseDatabase? _db;

  FirebaseDatabaseService() {
    try {
      _db = FirebaseDatabase.instance;
      // Enable offline persistence for real-time sync when connection is lost
      _db?.setPersistenceEnabled(true);
    } catch (e) {
      debugPrint('⚠️ [RTDB] Firebase Database not available: $e');
    }
  }

  /// Write data to a specific path
  Future<void> setData(String path, dynamic value) async {
    if (_db == null) return;
    try {
      await _db!.ref(path).set(value);
    } catch (e) {
      debugPrint('❌ [RTDB] Error setting data at $path: $e');
      rethrow;
    }
  }

  /// Update multiple values at a path
  Future<void> updateData(String path, Map<String, dynamic> values) async {
    if (_db == null) return;
    try {
      await _db!.ref(path).update(values);
    } catch (e) {
      debugPrint('❌ [RTDB] Error updating data at $path: $e');
      rethrow;
    }
  }

  /// Read data once from a path
  Future<DataSnapshot> getData(String path) async {
    if (_db == null) throw Exception('Firebase Database not initialized');
    try {
      final snapshot = await _db!.ref(path).get();
      return snapshot;
    } catch (e) {
      debugPrint('❌ [RTDB] Error fetching data at $path: $e');
      rethrow;
    }
  }

  /// Listen to real-time changes at a path
  Stream<DatabaseEvent> watchPath(String path) {
    if (_db == null) return const Stream.empty();
    return _db!.ref(path).onValue;
  }

  /// Delete data at a path
  Future<void> deleteData(String path) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref(path).remove();
    } catch (e) {
      debugPrint('❌ [RTDB] Error deleting data at $path: $e');
      rethrow;
    }
  }

  /// Push a new item to a list and return its key
  Future<String?> pushData(String path, dynamic value) async {
    final db = _db;
    if (db == null) return null;
    try {
      final newRef = db.ref(path).push();
      await newRef.set(value);
      return newRef.key;
    } catch (e) {
      debugPrint('❌ [RTDB] Error pushing data to $path: $e');
      rethrow;
    }
  }
}
