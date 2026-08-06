import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_provider.g.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? path;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.path,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      path: path,
    );
  }
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  List<AppNotification> build() {
    return [];
  }

  void addNotification(String title, String body, {String? path}) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      path: path,
    );
    state = [notification, ...state];
  }

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}
