import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/design_system/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/startup_provider.dart';
import 'core/utils/logger.dart';
import 'core/widgets/error_boundary.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Logger with error reporting link
  Log.init(onGlobalError: (error, stack) {
    GlobalErrorBoundary.reportError?.call(error, stack);
  });

  usePathUrlStrategy();

  runApp(
    const ProviderScope(
      child: GlobalErrorBoundary(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterWidgetProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Deshmukh Hardware & Steel ERP',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
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
            return child!;
          },
        );
      },
    );
  }
}
