import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

PreferredSize customAppBar(BuildContext context, Widget child) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56.0), // Standard AppBar height
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor, // Gradient start color
            Color.fromARGB(255, 75, 6, 1), // Gradient end color
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        backgroundColor:
            Colors.transparent, // Set to transparent to show the gradient

        title: child,
        iconTheme: const IconThemeData(
          color: whiteColor, // Set the color of the back arrow here
        ),
      ),
    ),
  );
}
