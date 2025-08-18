import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationService {
  static const String historyTopic = 'history_9_kr';

  static Future<bool> ensurePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      final req = await Permission.notification.request();
      return req.isGranted;
    }

    if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        return true;
      }
      return false;
    }

    return false;
  }

  static Future<void> subscribeHistoryTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic(historyTopic);
  }

  static Future<void> unsubscribeHistoryTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(historyTopic);
  }
}


