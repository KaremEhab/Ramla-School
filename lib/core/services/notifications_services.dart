import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // Instances
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Init Firebase + Local Notifications
  Future<void> init({
    required FirebaseOptions firebaseOptions,
    Function(String?)? onTap,
  }) async {
    // Init Firebase
    await Firebase.initializeApp(options: firebaseOptions);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local notifications setup
    await _initLocalNotifications(onTap: onTap);

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // User taps notification while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(jsonEncode(message.data), onTap);
    });

    // User taps notification when app was terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(jsonEncode(initialMessage.data), onTap);
    }
  }

  /// Local notifications init
  Future<void> _initLocalNotifications({Function(String?)? onTap}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload, onTap);
      },
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Show local notification in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const String groupKey = 'com.gahezha.notifications.group';

    // Individual notification details
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      groupKey: groupKey, // ✅ important for grouping
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // Show the individual notification
    await _localNotifications.show(
      message.hashCode, // use unique id for each notification
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );

    // Create/update summary notification (Android only)
    final List<String> lines = []; // you can keep last N notifications here

    // For simplicity, show title + body in summary
    lines.add('${message.notification?.title}: ${message.notification?.body}');

    final inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '${lines.length} new notifications',
      summaryText: 'Gahezha Notifications',
    );

    final androidSummary = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      styleInformation: inboxStyleInformation,
      groupKey: groupKey,
      setAsGroupSummary: true, // ✅ marks this as the summary
    );

    await _localNotifications.show(
      0, // fixed id for summary notification
      null,
      null,
      NotificationDetails(android: androidSummary),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(String? payload, Function(String?)? onTap) {
    if (payload == null) return;
    log("🔔 Notification tapped: $payload");
    onTap?.call(payload);
  }

  /// Get FCM token
  Future<String?> getToken() async => await _fcm.getToken();

  /// Request notification permissions
  Future<void> requestPermission() async {
    await _fcm.requestPermission();
  }
}

// 🔔 Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("📩 Background message: ${message.messageId}");
}
