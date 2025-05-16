import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:goods/presentation/custom_widgets/animited_text.dart';

Widget animitedTextAuthScreensTwoTexts(
    {required BuildContext context,
    required String text1,
    required String text2}) {
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: animatedText(context: context, texts: [
        TyperAnimatedText(text1, speed: const Duration(milliseconds: 100)),
        TyperAnimatedText(text2, speed: const Duration(milliseconds: 100))
      ]));
}

Widget animitedTextAuthScreensOneTexts({
  required BuildContext context,
  required String text1,
}) {
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: animatedText(context: context, texts: [
        TyperAnimatedText(text1, speed: const Duration(milliseconds: 100)),
      ]));
}
