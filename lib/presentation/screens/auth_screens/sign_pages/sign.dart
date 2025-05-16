import 'package:flutter/material.dart';
import 'package:goods/presentation/backgrounds/otp_background.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/build_phone_number_Sign_up.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});

  @override
  State<Sign> createState() => _Sign();
}

class _Sign extends State<Sign> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
          child: Stack(
        alignment: Alignment.center,
        children: [
          const BuildBackground(),
          buildPhoneNumberSignUp(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            context: context,
            formKey: formKey,
          ),
        ],
      )),
    );
  }
}
