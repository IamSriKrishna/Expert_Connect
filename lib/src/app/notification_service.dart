import 'dart:ui';

import 'package:expert_connect/src/auth/repo/auth_repo.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Add FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  // Add a reference to the HomeBloc
  HomeBloc? _homeBloc;

  // Method to set the HomeBloc instance
  void setHomeBloc(HomeBloc homeBloc) {
    _homeBloc = homeBloc;
  }

  // Initialize the service
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _requestPermission();
    await _setupInteractedMessage();
    _setupForegroundMessageHandler();
  }

  // Initialize local notifications with custom icon
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings with custom icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification'); // Your custom icon name
    
    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      // Parse payload and navigate
      try {
        final data = Map<String, dynamic>.from(
          response.payload != null ? _parsePayload(payload) : {},
        );
        if (data.containsKey('screen')) {
          _navigateToScreen(data['screen'], data);
        }
      } catch (e) {
        Logger().e('Error parsing notification payload: $e');
      }
    }
  }

  // Parse payload string to map
  Map<String, dynamic> _parsePayload(String payload) {
    // Simple parsing - you might want to use json.decode for complex data
    final parts = payload.split('|');
    final data = <String, dynamic>{};
    for (var part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }
    return data;
  }

  // Request notification permission
  Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger().d('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Logger().d('User granted provisional permission');
    } else {
      Logger().d('User declined or has not accepted permission');
    }
  }

  // Handle notification tap when app is in background or closed
  Future<void> _setupInteractedMessage() async {
    // Handle notification tap when app is opened from terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // Setup foreground message handler with custom notification
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger().d('Foreground message received: ${message.messageId}');
      
      // Show custom notification when app is in foreground
      _showCustomNotification(message);
      
      // When a new notification is received, fetch the updated notifications
      if (_homeBloc != null) {
        _homeBloc!.add(FetchUserNotifications());
      }
    });
  }

  // Show custom notification with custom icon
  Future<void> _showCustomNotification(RemoteMessage message) async {
    // Create payload string
    final payload = message.data.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');

    // Android notification details with custom icon and styling
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expert_connect_channel', // Channel ID
      'Expert Connect Notifications', // Channel name
      channelDescription: 'Notifications for Expert Connect app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification', // Your custom icon
      color: Color(0xFF2196F3), 
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''), // For expandable notifications
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show the notification
    await _localNotifications.show(
      message.hashCode, // Unique ID
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      notificationDetails,
      payload: payload,
    );
  }

  // Show notification with custom style (e.g., big picture, inbox style)
  Future<void> showBigPictureNotification({
    required String title,
    required String body,
    required String bigPicture,
    Map<String, dynamic>? data,
  }) async {
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicture),
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expert_connect_channel',
      'Expert Connect Notifications',
      channelDescription: 'Notifications for Expert Connect app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      styleInformation: bigPictureStyleInformation,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: data?.entries.map((e) => '${e.key}:${e.value}').join('|'),
    );
  }

  // Handle message and navigate accordingly
  void _handleMessage(RemoteMessage message) {
    Logger().d('Handling message: ${message.messageId}');
    
    // Extract navigation data from message
    final data = message.data;
    
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      final arguments = <String, dynamic>{};
      
      // Add any additional data
      data.forEach((key, value) {
        if (key != 'screen') {
          arguments[key] = value;
        }
      });
      
      // Navigate to the specified screen
      _navigateToScreen(screen, arguments);
    }
    
    // Fetch updated notifications when a notification is tapped
    if (_homeBloc != null) {
      _homeBloc!.add(FetchUserNotifications());
    }
  }

  // Navigate to specific screen based on notification data
  void _navigateToScreen(String screen, Map<String, dynamic> arguments) {
    switch (screen) {
      case 'chat':
        Get.toNamed('/chat', arguments: arguments);
        break;
      case 'profile':
        Get.toNamed('/profile', arguments: arguments);
        break;
      case 'appointment':
        Get.toNamed('/appointment', arguments: arguments);
        break;
      case 'notification_list':
        Get.toNamed('/notifications', arguments: arguments);
        break;
      default:
        Get.toNamed('/home');
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    Logger().d('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    Logger().d('Unsubscribed from topic: $topic');
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // Send token to your server
  static Future<void> sendTokenToServer(String token, String userId) async {
    try {
      // Replace with your API call
      Logger().d('Token sent to server: $token');
    } catch (e) {
      Logger().d('Error sending token to server: $e');
    }
  }
}

// Usage example in your main.dart or wherever you initialize
class NotificationHelper {
  
  // Initialize notifications after user login
  static Future<void> initializeAfterLogin(String userId) async {
    final token = await NotificationService.getFCMToken();
    final AuthRepoImpl authRepoImpl = AuthRepoImpl();
    if (token != null) {
      await authRepoImpl.saveDeviceToken(token);
    }
    
    // Subscribe to user-specific topics
    await NotificationService.subscribeToTopic('user_$userId');
    await NotificationService.subscribeToTopic('general');
  }
  
  // Clean up on logout
  static Future<void> cleanupOnLogout(String userId) async {
    await NotificationService.unsubscribeFromTopic('user_$userId');
  }
}