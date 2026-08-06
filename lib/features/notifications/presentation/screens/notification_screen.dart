import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:deshmukh_steel_e_r_p/core/design_system/theme/app_theme.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/custom_card.dart';
import 'package:deshmukh_steel_e_r_p/core/widgets/empty_state_widget.dart';
import 'package:deshmukh_steel_e_r_p/core/providers/app_bar_provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationNotifierProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'NOTIFICATIONS',
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
              child: const Text('Mark all as read'),
            ),
        ],
      );
    });

    if (notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_none_rounded,
        title: 'No Notifications',
        message: 'You\'re all caught up! New alerts will appear here.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(tokens.space24),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final n = notifications[index];
        return _NotificationCard(notification: n);
      },
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomCard(
      onTap: () {
        ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
        if (notification.path != null) {
          context.go(notification.path!);
        }
      },
      color: notification.isRead ? null : context.colorScheme.primary.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconColor(notification.title, context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(notification.title),
              color: _getIconColor(notification.title, context),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 13,
                        color: notification.isRead ? context.tokens.textSecondary : context.colorScheme.primary,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(notification.timestamp),
                      style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: context.colorScheme.primary, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String title) {
    if (title.contains('STOCK')) return Icons.inventory_2_rounded;
    if (title.contains('SALE')) return Icons.payments_rounded;
    return Icons.notifications_active_rounded;
  }

  Color _getIconColor(String title, BuildContext context) {
    if (title.contains('STOCK')) return context.colorScheme.error;
    if (title.contains('SALE')) return context.tokens.success;
    return context.colorScheme.primary;
  }
}
