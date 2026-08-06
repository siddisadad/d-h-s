import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../services/sync_service.dart';

part 'startup_provider.g.dart';

@riverpod
Future<void> startup(StartupRef ref) async {
  debugPrint('🚀 [Startup] Beginning sequence...');
  
  try {
    // 1. Initialize Sync Service
    debugPrint('🔄 [Startup] Step 1: Booting Sync Engine...');
    ref.read(syncServiceProvider);

    // 2. Initialize Notification Service
    debugPrint('🔔 [Startup] Step 2: Initializing Notifications...');
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.onNotificationReceived = (title, body, path) {
      ref.read(notificationNotifierProvider.notifier).addNotification(title, body, path: path);
    };
    await notificationService.init();

    debugPrint('✅ [Startup] Complete!');
  } catch (e, stack) {
    debugPrint('❌ [Startup] Critical Failure: $e');
    debugPrint(stack.toString());
    rethrow;
  }
}
