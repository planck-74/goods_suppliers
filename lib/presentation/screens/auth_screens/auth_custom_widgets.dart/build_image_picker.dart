import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget buildImagePicker({
  required double screenHeight,
  required BuildContext context,
  required File? pickedImage,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 12, 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 56.5,
            backgroundColor: primaryColor,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).hoverColor,
              radius: 55,
              child: pickedImage == null
                  ? Icon(
                      Icons.add_a_photo_sharp,
                      color: Colors.grey.shade400,
                      size: 40,
                    )
                  : ClipOval(
                      child: Image.file(
                        pickedImage,
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
      ],
    ),
  );
}
