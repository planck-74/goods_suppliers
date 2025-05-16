import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/animited_text.dart';
import 'package:pinput/pinput.dart';

class BuildPinPut extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final TextEditingController sentCode;
  final void Function() verifyOTP;
  final Function() resendCode;

  const BuildPinPut({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.sentCode,
    required this.verifyOTP,
    required this.resendCode,
  });

  @override
  State<BuildPinPut> createState() => _BuildPinPutState();
}

class _BuildPinPutState extends State<BuildPinPut> {
  bool isButtonEnabled = false;
  late Timer _timer;
  int remainingTime = 60;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startCountdown() {
    setState(() {
      isButtonEnabled = false;
      remainingTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        setState(() {
          isButtonEnabled = true;
        });
        _timer.cancel();
      }
    });
  }

  void handleResendCode() {
    startCountdown();
    widget.resendCode();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              animitedTextAuthScreensTwoTexts(
                  context: context,
                  text1: 'ستصلك رسالة تحقق',
                  text2: 'من فضلك قم بإدخال الرسالة التي استلمتها للتو.'),
            ],
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        SizedBox(
          width: widget.screenWidth * 0.9,
          child: Pinput(
            onCompleted: (String pin) {
              context.read<SignCubit>().showIndicatorInOtpScreen();
              widget.verifyOTP();
            },
            length: 6,
            controller: widget.sentCode,
            defaultPinTheme: PinTheme(
                height: 60,
                width: 50,
                textStyle: const TextStyle(color: darkBlueColor),
                decoration: BoxDecoration(
                    border: Border.all(color: darkBlueColor, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(12)))),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$remainingTime ثانية :', // Display the remaining time
              style: const TextStyle(fontSize: 16, color: darkBlueColor),
            ),
            TextButton(
              onPressed: isButtonEnabled ? handleResendCode : null,
              child: Text(
                'إعادة إرسال الرمز',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isButtonEnabled ? darkBlueColor : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        context.read<SignCubit>().isIndicatorInOtpScreenShowen == true
            ? const CircularProgressIndicator(
                color: darkBlueColor,
              )
            : const SizedBox(),
        SizedBox(
          height: widget.screenHeight * 0.2,
        ),
      ],
    );
  }
}
