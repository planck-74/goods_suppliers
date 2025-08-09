import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// Import Firebase Messaging conditionally
import 'package:firebase_messaging/firebase_messaging.dart' if (dart.library.html) 'package:firebase_messaging/firebase_messaging.dart' if (dart.library.io) 'package:firebase_messaging/firebase_messaging.dart';

/// Must be a top-level function for background handling.
Future<void> _firebaseMessagingBackgroundHandler(dynamic message) async {
  if (!_isFirebaseMessagingSupported()) return;
  
  await Firebase.initializeApp();
  debugPrint('Background message received: ${message.messageId}');
}

/// Check if Firebase Messaging is supported on current platform
bool _isFirebaseMessagingSupported() {
  if (kIsWeb) return true;
  
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

class NotificationService {
  // Firebase Messaging instance - nullable for unsupported platforms
  dynamic _messaging;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  
  bool get _isPlatformSupported => _isFirebaseMessagingSupported();

  NotificationService({required this.navigatorKey}) {
    // Initialize Firebase Messaging only on supported platforms
    if (_isPlatformSupported) {
      try {
        _messaging = FirebaseMessaging.instance;
      } catch (e) {
        debugPrint('❌ Firebase Messaging not available: $e');
        _messaging = null;
      }
    }
  }

  /// يُستدعى في main() بعد Firebase.initializeApp()
  Future<void> init() async {
    if (!_isPlatformSupported) {
      debugPrint('🔔 Notifications not supported on ${kIsWeb ? "Web" : Platform.operatingSystem}');
      _showPlatformNotSupportedMessage();
      return;
    }

    if (_messaging == null) {
      debugPrint('❌ Firebase Messaging failed to initialize');
      return;
    }

    try {
      await _requestPermission();
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }
      _listenToForegroundMessages();
      await _saveFcmToken();
      _listenToTokenRefresh();
      _handleNotificationClicks();
      await _handleInitialMessage();
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  /// Shows a message for unsupported platforms
  void _showPlatformNotSupportedMessage() {
    // You can implement alternative notification methods here
    // For Windows: win32_notification package
    // For Linux: desktop_notifications package
    
    final context = navigatorKey.currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 Push notifications not available on this platform'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  /// يطلب أذونات الإشعارات بشكل مفصّل، ويطبع حالة الإذن
  Future<void> _requestPermission() async {
    if (_messaging == null) return;

    // طلب إذن الإشعارات للأندرويد
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
        carPlay: false,
        announcement: false,
      );

      debugPrint('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('❌ User denied notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permissions');
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permissions: $e');
    }
  }

  /// يستمع للإشعارات أثناء عمل التطبيق في الواجهة
  void _listenToForegroundMessages() {
    if (_messaging == null) return;

    try {
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;

        debugPrint('📨 Foreground message received: ${message.messageId}');
        debugPrint('Title: ${notification?.title}');
        debugPrint('Body: ${notification?.body}');
        debugPrint('Data: ${message.data}');

        if (notification != null && navigatorKey.currentContext != null) {
          _showInAppNotification(notification, message.data);
        }
      });
    } catch (e) {
      debugPrint('❌ Error setting up foreground message listener: $e');
    }
  }

  /// يعرض إشعار داخل التطبيق
  void _showInAppNotification(dynamic notification, Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (notification.body != null) 
              Text(
                notification.body!,
                style: const TextStyle(color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: data.containsKey('orderId')
            ? SnackBarAction(
                label: 'عرض',
                textColor: Colors.white,
                onPressed: () => _navigateToOrder(data['orderId']),
              )
            : null,
      ),
    );
  }

  /// يحفظ التوكن في Firestore مع معالجة أفضل للأخطاء
  Future<void> _saveFcmToken() async {
    if (_messaging == null) return;

    try {
      final token = await _messaging.getToken();
      final user = _auth.currentUser;

      if (token != null && user != null) {
        final platformName = _getPlatformName();
        
        await _firestore.collection('suppliers').doc(user.uid).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'tokenLastUpdated': FieldValue.serverTimestamp(),
          'platform': platformName,
          'isOnline': true,
        }, SetOptions(merge: true));

        debugPrint('✅ FCM token saved: ${token.substring(0, 20)}...');
      } else {
        debugPrint('❌ Cannot save FCM token: token=${token != null ? "exists" : "null"}, user=${user?.uid}');
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Gets platform name
  String _getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// يحذف التوكن عند تسجيل الخروج مع معالجة أفضل للأخطاء
  Future<void> removeCurrentToken() async {
    if (_messaging == null) return;

    try {
      final token = await _messaging.getToken();
      final user = _auth.currentUser;

      if (token != null && user != null) {
        await _firestore.collection('suppliers').doc(user.uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
          'isOnline': false,
        });
        debugPrint('✅ FCM token removed: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('❌ Error removing FCM token: $e');
    }
  }

  /// يحذف جميع التوكنات للمستخدم الحالي
  Future<void> removeAllTokens() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('suppliers').doc(user.uid).update({
          'fcmTokens': FieldValue.delete(),
          'isOnline': false,
        });
        debugPrint('✅ All FCM tokens removed for user: ${user.uid}');
      }
    } catch (e) {
      debugPrint('❌ Error removing all FCM tokens: $e');
    }
  }

  /// يستمع لتحديث التوكن ويحدّثه في Firestore
  void _listenToTokenRefresh() {
    if (_messaging == null) return;

    try {
      _messaging.onTokenRefresh.listen((newToken) async {
        try {
          final user = _auth.currentUser;
          if (user != null) {
            final platformName = _getPlatformName();
            
            await _firestore.collection('suppliers').doc(user.uid).set({
              'fcmTokens': FieldValue.arrayUnion([newToken]),
              'tokenLastUpdated': FieldValue.serverTimestamp(),
              'platform': platformName,
            }, SetOptions(merge: true));

            debugPrint('🔄 FCM token refreshed: ${newToken.substring(0, 20)}...');
          }
        } catch (e) {
          debugPrint('❌ Error refreshing FCM token: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ Error setting up token refresh listener: $e');
    }
  }

  /// يتعامل مع فتح التطبيق من خلال إشعار (عندما يكون التطبيق مغلق)
  Future<void> _handleInitialMessage() async {
    if (_messaging == null) return;

    try {
      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('🚀 App opened from notification: ${initialMessage.messageId}');
        _handleMessageNavigation(initialMessage);
      }
    } catch (e) {
      debugPrint('❌ Error handling initial message: $e');
    }
  }

  /// يستمع لضغط المستخدم على الإشعار ويوجهه للشاشة المناسبة
  void _handleNotificationClicks() {
    if (_messaging == null) return;

    try {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('👆 Notification clicked: ${message.messageId}');
        _handleMessageNavigation(message);
      });
    } catch (e) {
      debugPrint('❌ Error setting up notification click handler: $e');
    }
  }

  /// يتعامل مع التنقل بناءً على بيانات الرسالة
  void _handleMessageNavigation(dynamic message) {
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
    debugPrint('🧭 Navigated to OrderDetails for $orderId');
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
        debugPrint('❓ Unknown screen: $screen');
    }
    debugPrint('🧭 Navigated to screen: $screen');
  }

  /// يحصل على حالة الإشعارات الحالية
  Future<dynamic> getNotificationStatus() async {
    if (_messaging == null) return null;

    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('❌ Error getting notification status: $e');
      return null;
    }
  }

  /// يتحقق من صحة التوكن الحالي
  Future<bool> isTokenValid() async {
    if (_messaging == null) return false;

    try {
      final token = await _messaging.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking token validity: $e');
      return false;
    }
  }

  /// Shows platform support status
  void showPlatformInfo() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final platformName = _getPlatformName();
    final isSupported = _isPlatformSupported;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Notification Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: $platformName'),
            Text('Firebase Messaging: ${isSupported ? "✅ Supported" : "❌ Not Supported"}'),
            if (!isSupported) ...[
              const SizedBox(height: 10),
              const Text(
                'Push notifications are not available on this platform. '
                'Consider using alternative notification methods.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}