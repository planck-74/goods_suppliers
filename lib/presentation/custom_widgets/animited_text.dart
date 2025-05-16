import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

Widget animatedText({
  required BuildContext context,
  required List<AnimatedText> texts,
}) {
  return DefaultTextStyle(
    style: Theme.of(context).textTheme.headlineLarge!,
    child: AnimatedTextKit(
      isRepeatingAnimation: false,
      animatedTexts: texts,
    ),
  );
}
