import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget addPhoto() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 30,
      width: 150,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 203, 203, 203),
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(3))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'إضافة صورة للمنشأة',
            style: TextStyle(color: whiteColor, fontSize: 12),
          ),
          SizedBox(
            width: 2,
          ),
          Icon(
            Icons.camera_alt_outlined,
            color: whiteColor,
            size: 24,
          )
        ],
      ),
    ),
  );
}
