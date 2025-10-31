import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:logger/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger().d('Handling background message: ${message.messageId}');
}

class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._internal();
  factory FirebaseManager() => _instance;
  FirebaseManager._internal();

  late FirebaseApp firebaseApp;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      firebaseApp = await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await _initializeLocalNotifications();
      await _requestPermissions();
      
      // Try to get FCM token with retry logic
      await _getFCMTokenWithRetry();
      
      _setupMessageHandlers();
      await _subscribeToTopics();
      
      _isInitialized = true;
      Logger().i('Firebase Manager initialized successfully');
    } catch (e) {
      Logger().e('Firebase Manager initialization failed: $e');
      // Don't throw - allow app to continue without FCM
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    if (Platform.isAndroid && Platform.operatingSystemVersion.contains('13')) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // NEW: Retry logic for FCM token
  Future<void> _getFCMTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        _fcmToken = await _firebaseMessaging.getToken();
        
        if (_fcmToken != null) {
          Logger().i("FCM Token retrieved successfully: $_fcmToken");
          
          // Listen to token refresh
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
            _fcmToken = newToken;
            Logger().i("FCM Token Refreshed: $_fcmToken");
            _sendTokenToServer(newToken);
          });

          await _sendTokenToServer(_fcmToken!);
          return; // Success - exit retry loop
        }
      } catch (e) {
        Logger().w("FCM token attempt ${i + 1}/$maxRetries failed: $e");
        
        if (i < maxRetries - 1) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: (i + 1) * 2));
        } else {
          Logger().e("Failed to get FCM token after $maxRetries attempts: $e");
          // Continue without FCM token - app will still work with local notifications
        }
      }
    }
  }

  // NEW: Method to manually retry token fetch
  Future<bool> retryGetFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        Logger().i("FCM Token retrieved on manual retry: $_fcmToken");
        await _sendTokenToServer(_fcmToken!);
        return true;
      }
      return false;
    } catch (e) {
      Logger().e("Manual FCM token retry failed: $e");
      return false;
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger().d('Received foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger().d('Notification tapped: ${message.messageId}');
      _handleNotificationTap(message);
    });

    _handleInitialMessage();
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Logger().d('App opened from notification: ${initialMessage.messageId}');
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Expert Connect',
      message.notification?.body ?? 'New notification',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    Logger().d('Local notification tapped: ${notificationResponse.payload}');
    _handleLocalNotificationTap(notificationResponse.payload);
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Implement your navigation logic here
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      Logger().d('Local notification payload: $payload');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      // Implement your API call here
      Logger().i('Token ready to send to server: $token');
    } catch (e) {
      Logger().e('Error sending token to server: $e');
    }
  }

  Future<void> _subscribeToTopics() async {
    if (_fcmToken == null) {
      Logger().w('Skipping topic subscription - no FCM token available');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic('general');
      await _firebaseMessaging.subscribeToTopic('expert_updates');
      Logger().i('Subscribed to topics');
    } catch (e) {
      Logger().e('Error subscribing to topics: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      Logger().i('Subscribed to topic: $topic');
    } catch (e) {
      Logger().e('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      Logger().i('Unsubscribed from topic: $topic');
    } catch (e) {
      Logger().e('Error unsubscribing from topic $topic: $e');
    }
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<bool> isNotificationPermissionGranted() async {
    NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // NEW: Check if FCM is working
  bool get isFCMAvailable => _fcmToken != null;
  bool get isInitialized => _isInitialized;
}

final firebaseManager = FirebaseManager();