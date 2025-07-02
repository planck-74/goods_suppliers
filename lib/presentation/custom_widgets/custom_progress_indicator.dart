import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget customCircularProgressIndicator({
  required context,
  double? height,
  double? width,
  Color? color,
  double? value,
}) {
  return SizedBox(
    height: height ?? 12,
    width: width ?? 12,
    child: Center(
      child: CircularProgressIndicator(
        value: value,
        color: darkBlueColor,
      ),
    ),
  );
}
