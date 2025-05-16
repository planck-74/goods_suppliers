import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/presentation/backgrounds/otp_background.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/build_pin_put.dart';
import 'package:goods/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreen();
}

class _OtpScreen extends State<OtpScreen> {
  late String phoneNumber;
  late SignCubit signCubit;
  late ControllerCubit controllerCubit;
  int? resendToken;
  String? verificationId;

  @override
  void initState() {
    super.initState();

    signCubit = context.read<SignCubit>();
    controllerCubit = context.read<ControllerCubit>();
    phoneNumber = controllerCubit.phoneNumber.text;
    resendToken = signCubit.resendToked;
    verificationId = signCubit.verificatId;
  }

  void resendCode() {
    if (phoneNumber.isNotEmpty) {
      AuthService.resendVerificationCode(
        phoneNumber: phoneNumber,
        context: context,
        resendToken: resendToken ?? 0,
        onCodeSent: (newVerificationId, newResendToken) {
          if (mounted) {
            setState(() {
              verificationId = newVerificationId;
              resendToken = newResendToken;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const BuildBackground(),
          SingleChildScrollView(
            child: Column(
              children: [
                BuildPinPut(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  sentCode: signCubit.sentCode,
                  verifyOTP: () {
                    signCubit.verifyOTP(
                      context: context,
                      verificationId: verificationId!,
                    );
                  },
                  resendCode: resendCode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
