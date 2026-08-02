import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../di/injection_container.dart';
import '../network/api_client.dart';

part 'startup_provider.g.dart';

@riverpod
Future<void> startup(StartupRef ref) async {
  debugPrint('🚀 [Startup] Beginning sequence...');
  
  try {
    // 1. Initialize Service Locator (Legacy bridge)
    debugPrint('📦 [Startup] Step 1: Initializing Service Locator...');
    final client = ref.read(apiClientProvider);
    sl.init(client);

    debugPrint('✅ [Startup] Complete!');
  } catch (e, stack) {
    debugPrint('❌ [Startup] Critical Failure: $e');
    debugPrint(stack.toString());
    rethrow;
  }
}
