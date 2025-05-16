import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';

Widget customDropdownFormField({
  required List<String> categories,
  required double width,
  required BuildContext context,
  required String labelText,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 50,
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
      child: DropdownButtonFormField<String>(
        hint: Text(
          labelText,
          style: TextStyle(
            color: Colors.grey.shade500.withOpacity(0.6),
            fontSize: 18,
          ),
        ),
        value: value,
        onChanged: (value) {
          context.read<ControllerCubit>().category = value;
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى اختيار التصنيف';
          }
          return null;
        },
      ),
    ),
  );
}
