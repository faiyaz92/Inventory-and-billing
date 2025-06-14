import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AccountRepository _accountRepository;
  final IFirestorePathProvider _firestoreProvider;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FCMService(this._accountRepository, this._firestoreProvider);

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['bookingId']?.toString() ?? '');
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data['bookingId']?.toString() ?? '');
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _updateFCMToken(newToken);
    });

    await registerFCMToken();
  }

  Future<String?> registerFCMToken() async {
    final userInfo = await _accountRepository.getUserInfo();
    final userId = userInfo?.userId;
    final companyId = userInfo?.companyId;
    if (userId != null && companyId != null) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestoreProvider
            .getTenantUsersRef(companyId)
            .doc(userId)
            .update({'fcmToken': token});
        await _firestoreProvider
            .getCommonUsersPath()
            .doc(userId)
            .update({'fcmToken': token});
        return token;
      }
    }
    return null;
  }

  Future<void> _updateFCMToken(String token) async {
    final userInfo = await _accountRepository.getUserInfo();
    final userId = userInfo?.userId;
    final companyId = userInfo?.companyId;
    if (userId != null && companyId != null) {
      await _firestoreProvider
          .getTenantUsersRef(companyId)
          .doc(userId)
          .update({'fcmToken': token});
      await _firestoreProvider
          .getCommonUsersPath()
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'taxi_booking_channel',
      'Taxi Booking Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'New Booking',
      message.notification?.body ?? 'A passenger has booked a ride!',
      platformDetails,
      payload: message.data['bookingId']?.toString(),
    );
  }

  void _handleNotificationTap(String bookingId) {
    if (bookingId.isNotEmpty) {
      // sl<Coordinator>().navigateToBookingDetails(bookingId);
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}