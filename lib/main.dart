import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/theme_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/startup_provider.dart';
import 'package:deshmukh_steel_e_r_p/core/router/app_router.dart';
import 'package:deshmukh_steel_e_r_p/core/services/sync_service.dart';
import 'package:deshmukh_steel_e_r_p/features/authentication/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux) {
      try {
        debugPrint('🖥️ [Main] Initializing sqflite_ffi for Desktop');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } catch (e) {
        debugPrint('❌ [Main] sqflite_ffi initialization failed: $e');
      }
    }
  }

  try {
    await Firebase.initializeApp();
    debugPrint('🔥 [Main] Firebase Initialized Successfully');
  } catch (e) {
    debugPrint('⚠️ [Main] Firebase Initialization Failed: $e');
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterWidgetProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Deshmukh Hardware & Steel ERP',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, _) {
            final startupAsync = ref.watch(startupProvider);
            final authAsync = ref.watch(authProvider);

            if (startupAsync.isLoading || authAsync.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Start background services only AFTER startup is complete
            ref.watch(syncServiceProvider);

            return child!;
          },
        );
      },
    );
  }
}
