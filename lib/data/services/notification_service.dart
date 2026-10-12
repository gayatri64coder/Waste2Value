import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/config/firebase_bootstrap.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[waste2value] Background message received: ${message.messageId}');
}

/// Service managing push notifications and pickup alerts via Firebase Cloud Messaging.
class NotificationService {
  NotificationService._();

  static String? _fcmToken;
  static String? get fcmToken => _fcmToken;

  /// Initializes messaging listeners and requests notification permissions.
  static Future<void> initialize() async {
    if (FirebaseBootstrap.isInitialized) {
      try {
        final messaging = FirebaseMessaging.instance;

        // Request permissions for iOS and Android 13+
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('[waste2value] User granted notification permission');
          _fcmToken = await messaging.getToken();
          debugPrint('[waste2value] FCM Device Token: $_fcmToken');
        }

        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[waste2value] Foreground message received: ${message.notification?.title}');
        });
        return;
      } catch (e) {
        debugPrint('[waste2value] NotificationService initialization notice: $e');
      }
    }

    debugPrint('[waste2value] NotificationService: Running in development mode without FCM.');
  }
}
