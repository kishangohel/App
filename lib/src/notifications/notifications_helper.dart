import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/app_icon');

    const initializationSettingsDarwin = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await requestNotificationPermissions();
  }

  /// Show notification to user.
  ///
  static Future<void> showNotification(String title, String body) async {
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_priority_channel',
        'High Priority',
        channelDescription: 'High priority notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> requestNotificationPermissions() async {
    await Permission.notification.request();
  }
}
