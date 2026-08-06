import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_button.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/database_providers.dart';
import 'package:deshmukh_steel_e_r_p/core/services/sync_service.dart';
import 'package:intl/intl.dart';

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(syncQueueProvider);
    final isSyncing = ref.watch(syncServiceProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: const Text('SYNC CENTER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(syncQueueProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(context, isSyncing),
          Expanded(
            child: queueAsync.when(
              data: (queue) => queue.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.all(tokens.space24),
                      itemCount: queue.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = queue[index];
                        return _buildQueueItem(context, ref, item);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
          if (queueAsync.hasValue && queueAsync.value!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(tokens.space24),
              child: CustomButton(
                text: 'RETRY ALL PENDING TASKS',
                fullWidth: true,
                loading: isSyncing,
                onPressed: () async {
                  await ref.read(syncServiceProvider.notifier).processQueue();
                  ref.invalidate(syncQueueProvider);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, bool isSyncing) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: isSyncing ? context.colorScheme.primaryContainer : context.colorScheme.surfaceVariant.withValues(alpha: 0.5),
      child: Row(
        children: [
          Icon(
            isSyncing ? Icons.sync_rounded : Icons.cloud_done_rounded,
            color: isSyncing ? context.colorScheme.primary : context.successColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSyncing ? 'Synchronizing Data...' : 'All local tasks processed',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  isSyncing ? 'Communicating with server' : 'Your data is up to date locally',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    final method = item['method'] as String;
    final path = item['path'] as String;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(item['timestamp'] as int);
    final id = item['id'] as int;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMethodColor(context, method).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: _getMethodColor(context, method),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(path, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(timestamp),
                  style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
            onPressed: () async {
              await ref.read(localDatabaseProvider).removeFromSyncQueue(id);
              ref.invalidate(syncQueueProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 64, color: context.successColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No pending tasks', style: context.textTheme.titleMedium),
          Text('Offline queue is empty', style: context.textTheme.labelSmall),
        ],
      ),
    );
  }

  Color _getMethodColor(BuildContext context, String method) {
    switch (method) {
      case 'POST': return context.successColor;
      case 'PUT': return context.colorScheme.primary;
      case 'DELETE': return context.colorScheme.error;
      default: return Colors.grey;
    }
  }
}
