import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goods/business_logic/providers.dart';
import 'package:goods/business_logic/routes.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/firebase_options.dart';
import 'package:goods/presentation/splash_screen.dart';
import 'package:goods/services/auth_service.dart';
import 'package:goods/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

   FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final bool isSupportedForFCM = kIsWeb || Platform.isAndroid || Platform.isIOS;

  if (isSupportedForFCM) {
    final notificationService = NotificationService(navigatorKey: navigatorKey);
    try {
      await notificationService.init();
    } on MissingPluginException catch (e) {
      debugPrint('FCM plugin not implemented on this platform: $e');
    } catch (e, st) {
      debugPrint('Failed to init NotificationService: $e\n$st');
    }
  } else {
    debugPrint('Skipping FirebaseMessaging init on desktop (no platform implementation).');
  }
  runApp( GoodsSuppliers());
}

class GoodsSuppliers extends StatelessWidget {
  final authService = AuthService();

  GoodsSuppliers({super.key});
  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: routes,
        supportedLocales: const [
          Locale('ar', 'EG'),
        ],
        locale: const Locale('ar', 'EG'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'بضائع التجار',
        theme: getThemeData(),
        home: const SplashScreen(),
      ),
    );
  }
}