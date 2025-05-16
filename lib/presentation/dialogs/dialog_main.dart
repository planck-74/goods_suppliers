import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Future<void> showMyDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to close the dialog
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const Text(
          'Alert',
          style: TextStyle(color: Colors.black),
        ),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'This is a simple alert dialog.',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Press OK to close.',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
