import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget MapContainer(BuildContext context, String text) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/LocationPickerScreen'),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: darkBlueColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: whiteColor),
          ),
        ),
      ),
    ),
  );
}
