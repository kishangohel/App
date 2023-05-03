import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notifications_helper.dart';

class FCM {
  static Future<void> init() async {
    await _setupForegroundMessageHandler();
    FirebaseMessaging.onBackgroundMessage(_remoteMessageHandler);
  }

  static Future<void> registerToken() async {
    // Get the user ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String uid = user.uid;

    // Get the FCM token for this device
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? fcmToken = await messaging.getToken();
    if (fcmToken == null) {
      debugPrint('No FCM token available');
      return;
    }

    // Save the FCM token to Firestore for this user
    await FirebaseFirestore.instance.collection('UserProfile').doc(uid).set(
      {'fcmToken': fcmToken},
      SetOptions(merge: true),
    );
  }

  static Future<void> _setupForegroundMessageHandler() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await FCM.showNotification(message);
    });
  }

  static Future<void> showNotification(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;
    if (data.isNotEmpty) {
      await NotificationHelper.showNotification(
        data['title'],
        data['body'],
      );
    }
  }
}

@pragma('vm:entry-point')
Future<void> _remoteMessageHandler(RemoteMessage message) async =>
    await FCM.showNotification(message);
