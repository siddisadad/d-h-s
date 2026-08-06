import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../providers/sync_providers.dart';
import '../design_system/theme/app_theme.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityNotifierProvider);
    final isSyncing = ref.watch(syncServiceProvider);
    final queueCount = ref.watch(syncQueueCountProvider).value ?? 0;

    return connectivity.when(
      data: (status) {
        final isOnline = status == ConnectivityStatus.online;

        String tooltip = isOnline
            ? (isSyncing ? 'Syncing with Cloud...' : 'Cloud Connected')
            : 'Offline Mode (Local Storage Only)';

        if (queueCount > 0) {
          tooltip += ' ($queueCount pending tasks)';
        }

        return Tooltip(
          message: tooltip,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: isOnline
                    ? (isSyncing ? context.colorScheme.primary : context.tokens.success)
                    : context.colorScheme.error,
                  size: 20,
                ),
                if (queueCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                      child: Text(
                        queueCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (isSyncing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const Icon(Icons.error_outline, color: Colors.red, size: 20),
    );
  }
}
