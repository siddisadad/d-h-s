import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../di/injection_container.dart';
import '../network/api_client.dart';

import '../services/sync_service.dart';

part 'startup_provider.g.dart';

@riverpod
Future<void> startup(StartupRef ref) async {
  debugPrint('🚀 [Startup] Beginning sequence...');
  
  try {
    // 1. Initialize Service Locator (Legacy bridge)
    debugPrint('📦 [Startup] Step 1: Initializing Service Locator...');
    final client = ref.read(apiClientProvider);
    sl.init(client);

    // 2. Initialize Sync Service
    debugPrint('🔄 [Startup] Step 2: Booting Sync Engine...');
    ref.read(syncServiceProvider);

    debugPrint('✅ [Startup] Complete!');
  } catch (e, stack) {
    debugPrint('❌ [Startup] Critical Failure: $e');
    debugPrint(stack.toString());
    rethrow;
  }
}
