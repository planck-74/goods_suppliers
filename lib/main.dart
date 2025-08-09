import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goods/business_logic/providers.dart';
import 'package:goods/business_logic/routes.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/splash_screen.dart';
import 'package:goods/services/auth_service.dart';
import 'package:goods/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final notificationService = NotificationService(navigatorKey: navigatorKey);
  await notificationService.init();

  await initStoreId();

  runApp(GoodsSuppliers());
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
