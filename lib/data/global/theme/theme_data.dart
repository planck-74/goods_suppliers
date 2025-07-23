import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/functions/fetch_store_id.dart';

// Colors
const Color primaryColor = Color.fromARGB(255, 190, 30, 19);
const Color darkBlueColor = Color(0xFF012340);
const Color whiteColor = Colors.white;
const Color scaffoldBackgroundColor = Color.fromARGB(255, 232, 232, 232);
const Color lightBackgroundColor = whiteColor;
String supplierId = FirebaseAuth.instance.currentUser!.uid;
String storeId = 'cafb6e90-0ab1-11f0-b25a-8b76462b3bd5';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initStoreId() async {
  String? fetched = await getStoreId();
  if (fetched != null) {
    storeId = fetched;
  } else {
    storeId = ''; // fallback value
    print("❌ Failed to initialize storeId");
  }
}

ThemeData getThemeData() {
  return ThemeData(
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      refreshBackgroundColor: whiteColor,
      color: Colors.red,
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
    dialogTheme: const DialogThemeData(backgroundColor: whiteColor),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: darkBlueColor,
      selectionHandleColor: darkBlueColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: darkBlueColor, fontSize: 16),
      border: OutlineInputBorder(),
      focusedBorder: InputBorder.none,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle:
          TextStyle(color: darkBlueColor, fontSize: 18, fontFamily: 'Cairo'),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: darkBlueColor, fontSize: 12),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: darkBlueColor, width: 2.0),
        ),
      ),
    ),
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    secondaryHeaderColor: darkBlueColor,
    hoverColor: Colors.grey[200],
    appBarTheme: const AppBarTheme(
      color: primaryColor,
      iconTheme: IconThemeData(color: whiteColor),
    ),
    buttonTheme: const ButtonThemeData(buttonColor: whiteColor, height: 50),
    fontFamily: 'Cairo',
    textTheme: TextTheme(
      headlineLarge: _textStyle(color: darkBlueColor, fontSize: 32),
      headlineMedium: _textStyle(color: darkBlueColor, fontSize: 14),
      headlineSmall: _textStyle(color: darkBlueColor, fontSize: 12),
      bodyLarge: _textStyle(color: darkBlueColor, fontSize: 24),
      bodyMedium: _textStyle(color: darkBlueColor, fontSize: 18),
      bodySmall: _textStyle(color: darkBlueColor, fontSize: 12),
    ),
    tabBarTheme: const TabBarThemeData(indicatorColor: darkBlueColor),
  );
}

TextStyle _textStyle({
  required Color color,
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}
