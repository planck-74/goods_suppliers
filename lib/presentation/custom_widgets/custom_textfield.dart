import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget customTextFormField(
    {required double width,
    TextEditingController? controller,
    required String labelText,
    String? validationText,
    required context,
    double? height,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: height ?? 60,
      width: width * 0.95,
      decoration: BoxDecoration(
        color: whiteColor.withOpacity(0.9), // White background color
        borderRadius: BorderRadius.circular(3), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Shadow position (x, y)
          ),
        ],
      ),
      child: TextFormField(
        maxLength: 11,
        controller: controller,
        textInputAction: textInputAction ?? TextInputAction.done,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          counterText: "",
          focusedBorder: InputBorder.none,
          hintText: labelText,
          hintStyle: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return validationText;
              }
              return null;
            },
      ),
    ),
  );
}

Widget customTextField(
    {required double width,
    TextEditingController? controller,
    required String labelText,
    required context,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 40,
      width: width * 0.95,
      decoration: BoxDecoration(
        color: whiteColor, // White background color
        borderRadius: BorderRadius.circular(3), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: const Offset(0, 3), // Shadow position (x, y)
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: textInputAction ?? TextInputAction.done,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          focusedBorder: InputBorder.none,
          hintText: labelText, // Placeholder text inside the TextField
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
          border: InputBorder.none, // No border
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
  );
}
