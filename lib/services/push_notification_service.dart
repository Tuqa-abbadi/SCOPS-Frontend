// ── Push Notification Service (FCM) ──────────────────────────────────────
// Dependencies to add to pubspec.yaml:
//   firebase_core: ^3.x.x
//   firebase_messaging: ^15.x.x
//   flutter_local_notifications: ^17.x.x
//
// Setup steps:
//   1. Run `flutterfire configure` to generate google-services.json / GoogleService-Info.plist
//   2. Add the files to android/app/ and ios/Runner/
//   3. Enable Background Modes → Remote notifications in Xcode
//   4. Call PushNotificationService.init() in main() before runApp()
//
// TODO Sprint 4: send FCM token to backend POST /device-tokens
// TODO Sprint 4: handle notification tap deep-links (subscriptionId routing)

import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler — must be a top-level function.
/// Uncomment when firebase_messaging is added.
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('📩 Background message: ${message.messageId}');
//   // TODO: store notification locally so user sees it on next open
// }

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  // final _fcm = FirebaseMessaging.instance;
  // final _localNotif = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Call once in main() after WidgetsFlutterBinding.ensureInitialized()
  Future<void> init() async {
    // ── 1. Firebase & background handler ──────────────────────────────────
    // await Firebase.initializeApp();
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── 2. Request permission ─────────────────────────────────────────────
    // final settings = await _fcm.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    // debugPrint('FCM permission: ${settings.authorizationStatus}');

    // ── 3. Get token & send to backend ────────────────────────────────────
    // _fcmToken = await _fcm.getToken();
    // debugPrint('FCM token: $_fcmToken');
    // TODO Sprint 4: await _sendTokenToBackend(_fcmToken!);

    // ── 4. Local notifications setup (for foreground display) ─────────────
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings();
    // await _localNotif.initialize(
    //   const InitializationSettings(android: androidSettings, iOS: iosSettings),
    //   onDidReceiveNotificationResponse: _onNotifTapped,
    // );

    // ── 5. Foreground message handler ─────────────────────────────────────
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ── 6. Opened-from-notification handler ───────────────────────────────
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // ── 7. Check if app was opened from a terminated state notification ───
    // final initial = await _fcm.getInitialMessage();
    // if (initial != null) _handleNotificationTap(initial);

    debugPrint('[PushNotificationService] Stub initialized. '
        'Uncomment Firebase code after adding dependencies.');
  }

  // void _handleForegroundMessage(RemoteMessage message) {
  //   debugPrint('📩 Foreground: ${message.notification?.title}');
  //   _showLocalNotification(message);
  // }

  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   final n = message.notification;
  //   if (n == null) return;
  //   await _localNotif.show(
  //     message.hashCode,
  //     n.title,
  //     n.body,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'scops_channel', 'SCOPS Alerts',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         color: Color(0xFF1DD8E8),
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     payload: message.data['subscriptionId'],
  //   );
  // }

  // void _handleNotificationTap(RemoteMessage message) {
  //   final subscriptionId = message.data['subscriptionId'];
  //   if (subscriptionId != null) {
  //     // TODO Sprint 4: use a global NavigatorKey to push PaymentHistoryScreen
  //     debugPrint('Navigate to subscription: $subscriptionId');
  //   }
  // }

  // void _onNotifTapped(NotificationResponse response) {
  //   final subscriptionId = response.payload;
  //   if (subscriptionId != null) {
  //     debugPrint('Local notif tapped → subscription: $subscriptionId');
  //   }
  // }

  // Future<void> _sendTokenToBackend(String token) async {
  //   TODO Sprint 4:
  //   await DioClient.instance.dio.post('/device-tokens', data: {
  //     'token': token,
  //     'platform': Platform.isIOS ? 'ios' : 'android',
  //   });
  // }

  /// Call on logout to unregister the device
  Future<void> unregister() async {
    // await _fcm.deleteToken();
    // TODO Sprint 4: DELETE /device-tokens/{token} on backend
    debugPrint('[PushNotificationService] Token unregistered (stub).');
  }
}

// ── pubspec.yaml additions ────────────────────────────────────────────────
// (Add these under dependencies:)
//
// firebase_core: ^3.6.0
// firebase_messaging: ^15.1.3
// flutter_local_notifications: ^17.2.3
//
// ── AndroidManifest.xml additions ────────────────────────────────────────
// Inside <application>:
//   <service android:name="com.google.firebase.messaging.FirebaseMessagingService"
//            android:exported="false">
//     <intent-filter>
//       <action android:name="com.google.firebase.MESSAGING_EVENT"/>
//     </intent-filter>
//   </service>
//
// ── main.dart integration ─────────────────────────────────────────────────
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await PushNotificationService.instance.init();  // ← add this line
//   ... rest of main
// }