import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:permission_handler/permission_handler.dart';

/// Must be a top-level function for background handling.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // هنا يمكنك التعامل مع الرسالة في الخلفية (logging مثلاً)
  debugPrint('Background message received: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationService({required this.navigatorKey});

  /// يُستدعى في main() بعد Firebase.initializeApp()
  Future<void> init() async {
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _listenToForegroundMessages();
    await _saveFcmToken();
    _listenToTokenRefresh();
    _handleNotificationClicks();
    await _handleInitialMessage(); // Added to handle app launch from notification
  }

  /// يطلب أذونات الإشعارات بشكل مفصّل، ويطبع حالة الإذن
  Future<void> _requestPermission() async {
    // طلب إذن الإشعارات للأندرويد
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    }

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      carPlay: false,
      announcement: false,
    );

    debugPrint(
        'Notification permission status: ${settings.authorizationStatus}');

    // تحقق من حالة الإذن وأظهر رسالة للمستخدم إذا لزم الأمر
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('User denied notification permissions');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    }
  }

  /// يستمع للإشعارات أثناء عمل التطبيق في الواجهة
  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      debugPrint('Foreground message received: ${message.messageId}');
      debugPrint('Title: ${notification?.title}');
      debugPrint('Body: ${notification?.body}');
      debugPrint('Data: ${message.data}');

      // اظهر Snackbar أو Alert داخل التطبيق
      if (notification != null && navigatorKey.currentContext != null) {
        _showInAppNotification(notification, message.data);
      }
    });
  }

  /// يعرض إشعار داخل التطبيق
  void _showInAppNotification(
      RemoteNotification notification, Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.title != null)
                Text(
                  notification.title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (notification.body != null) Text(notification.body!),
            ],
          ),
          duration: const Duration(seconds: 4),
          action: data.containsKey('orderId')
              ? SnackBarAction(
                  label: 'عرض',
                  onPressed: () => _navigateToOrder(data['orderId']),
                )
              : null,
        ),
      );
    }
  }

  /// يحفظ التوكن في Firestore مع معالجة أفضل للأخطاء
  Future<void> _saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      final user = _auth.currentUser;

      if (token != null && user != null) {
        await _firestore.collection('suppliers').doc(supplierId).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'tokenLastUpdated': FieldValue.serverTimestamp(),
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }, SetOptions(merge: true));

        debugPrint('FCM token saved: $token');
      } else {
        debugPrint('Cannot save FCM token: token=$token, user=${supplierId}');
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// يحذف التوكن عند تسجيل الخروج مع معالجة أفضل للأخطاء
  Future<void> removeCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      final user = _auth.currentUser;

      if (token != null && user != null) {
        await _firestore.collection('suppliers').doc(supplierId).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
        debugPrint('FCM token removed: $token');
      }
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  /// يحذف جميع التوكنات للمستخدم الحالي
  Future<void> removeAllTokens() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('suppliers').doc(supplierId).update({
          'fcmTokens': FieldValue.delete(),
        });
        debugPrint('All FCM tokens removed for user: ${supplierId}');
      }
    } catch (e) {
      debugPrint('Error removing all FCM tokens: $e');
    }
  }

  /// يستمع لتحديث التوكن ويحدّثه في Firestore
  void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          // أولا احذف التوكن القديم
          final oldToken = await _messaging.getToken();
          if (oldToken != null) {
            await _firestore.collection('suppliers').doc(supplierId).update({
              'fcmTokens': FieldValue.arrayRemove([oldToken]),
            });
          }

          // ثم أضف التوكن الجديد
          await _firestore.collection('suppliers').doc(supplierId).set({
            'fcmTokens': FieldValue.arrayUnion([newToken]),
            'tokenLastUpdated': FieldValue.serverTimestamp(),
            'platform': Platform.isAndroid ? 'android' : 'ios',
          }, SetOptions(merge: true));

          debugPrint('FCM token refreshed: $newToken');
        }
      } catch (e) {
        debugPrint('Error refreshing FCM token: $e');
      }
    });
  }

  /// يتعامل مع فتح التطبيق من خلال إشعار (عندما يكون التطبيق مغلق)
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App opened from notification: ${initialMessage.messageId}');
      _handleMessageNavigation(initialMessage);
    }
  }

  /// يستمع لضغط المستخدم على الإشعار ويوجهه للشاشة المناسبة
  void _handleNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked: ${message.messageId}');
      _handleMessageNavigation(message);
    });
  }

  /// يتعامل مع التنقل بناءً على بيانات الرسالة
  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    final orderId = data['orderId'];
    final screen = data['screen'];

    if (orderId != null) {
      _navigateToOrder(orderId);
    } else if (screen != null) {
      _navigateToScreen(screen, data);
    }
  }

  /// ينتقل إلى شاشة الطلب
  void _navigateToOrder(String orderId) {
    navigatorKey.currentState?.pushNamed('/orderDetails', arguments: orderId);
    debugPrint('Navigated to OrderDetails for $orderId');
  }

  /// ينتقل إلى شاشة محددة
  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    switch (screen) {
      case 'orders':
        navigatorKey.currentState?.pushNamed('/orders');
        break;
      case 'profile':
        navigatorKey.currentState?.pushNamed('/profile');
        break;
      case 'notifications':
        navigatorKey.currentState?.pushNamed('/notifications');
        break;
      default:
        debugPrint('Unknown screen: $screen');
    }
  }

  /// يحصل على حالة الإشعارات الحالية
  Future<AuthorizationStatus> getNotificationStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// يتحقق من صحة التوكن الحالي
  Future<bool> isTokenValid() async {
    try {
      final token = await _messaging.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking token validity: $e');
      return false;
    }
  }
}
