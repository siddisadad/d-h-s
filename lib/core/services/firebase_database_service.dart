import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class FirebaseDatabaseService {
  FirebaseDatabase? _db;

  FirebaseDatabaseService() {
    _initialize();
  }

  void _initialize() {
    try {
      if (Firebase.apps.isEmpty) {
        Log.w('RTDB: Firebase App not initialized. Waiting for Main...', name: 'Firebase');
        return;
      }

      _db = FirebaseDatabase.instance;
      // Enable offline persistence for real-time sync when connection is lost
      if (!kIsWeb) {
        _db?.setPersistenceEnabled(true);
      }
      Log.i('RTDB: Connected Successfully', name: 'Firebase');
    } catch (e) {
      Log.w('RTDB: Firebase Database not available: $e', name: 'Firebase');
    }
  }

  bool get isInitialized => _db != null;

  /// Write data to a specific path
  Future<void> setData(String path, dynamic value) async {
    if (_db == null) {
      _initialize();
      if (_db == null) throw Exception('Firebase Database not initialized');
    }
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
    final db = _db;
    if (db == null) {
      Log.w('RTDB: Cannot fetch $path - Database not initialized', name: 'Firebase');
      return _MockDataSnapshot();
    }
    try {
      final snapshot = await db.ref(path).get();
      return snapshot;
    } catch (e) {
      debugPrint('❌ [RTDB] Error fetching data at $path: $e');
      rethrow;
    }
  }

  /// Listen to real-time changes at a path
  Stream<DatabaseEvent> watchPath(String path) {
    final db = _db;
    if (db == null) return const Stream.empty();
    return db.ref(path).onValue;
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

/// A simple mock class to return when Firebase is not initialized
class _MockDataSnapshot implements DataSnapshot {
  @override
  bool get exists => false;

  @override
  String? get key => null;

  @override
  Object? get value => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  DataSnapshot child(String path) => this;

  @override
  Iterable<DataSnapshot> get children => const [];

  @override
  bool hasChild(String path) => false;

  @override
  int get priority => 0;

  @override
  DatabaseReference get ref => throw UnimplementedError();
}
