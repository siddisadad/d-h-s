import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/logger.dart';

part 'notification_service.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  void Function(String title, String body, String? path)? onNotificationReceived;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Request Permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        Log.w('User declined notification permissions', name: 'Notification');
        return;
      }

      // 2. Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // 3. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Log.i('Foreground Message: ${message.notification?.title}', name: 'Notification');
        final title = message.notification?.title ?? 'ERP Alert';
        final body = message.notification?.body ?? '';
        final path = message.data['path'];

        onNotificationReceived?.call(title, body, path);
        _showLocalNotification(message);
      });

      // 4. Handle Background/Terminated Click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Log.i('Notification Clicked (Background): ${message.notification?.title}', name: 'Notification');
        _handleDeepLink(message.data);
      });

      // Get Token
      String? token = await _fcm.getToken();
      Log.d('FCM Token: $token', name: 'Notification');

      _isInitialized = true;
      Log.i('Notification Service Initialized', name: 'Notification');
    } catch (e) {
      Log.e('Failed to initialize Notification Service', error: e, name: 'Notification');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dci_erp_main_channel',
      'ERP Alerts',
      channelDescription: 'Main channel for ERP stock and sales alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['path'],
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      Log.i('Notification Clicked (Local): ${response.payload}', name: 'Notification');
      // In a real app, you would use a navigation service or state to redirect
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    final path = data['path'];
    if (path != null) {
      // Implement navigation logic here
    }
  }

  /// Trigger a purely local business alert (e.g., Low Stock)
  Future<void> showLocalAlert({
    required String title,
    required String body,
    String? path,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dci_erp_alerts',
      'Business Alerts',
      channelDescription: 'Alerts for low stock and high value sales',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    onNotificationReceived?.call(title, body, path);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: path,
    );
  }
}
