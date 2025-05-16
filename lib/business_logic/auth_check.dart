import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/screens/auth_screens/sign_pages/sign.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/navigator_bar_screen.dart';
import 'package:goods/services/auth_service.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  AuthCheckState createState() => AuthCheckState();
}

class AuthCheckState extends State<AuthCheck> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    bool loginState = await AuthService.getLoginState();

    setState(() {
      isLoggedIn = loginState;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        color: darkBlueColor,
      ));
    } else if (isLoggedIn) {
      return const NavigatorBar();
    } else {
      return const Sign();
    }
  }
}
