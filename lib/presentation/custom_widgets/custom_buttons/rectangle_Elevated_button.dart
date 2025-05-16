import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';

Widget rectangleElevatedButton({
  required screenWidth,
  formKey,
  required onPressed,
}) {
  return SizedBox(
    height: 50,
    width: screenWidth * 0.95,
    child: BlocBuilder<SignCubit, SignState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
            backgroundColor:
                WidgetStatePropertyAll(primaryColor.withOpacity(0.8)),
          ),
          child: state is SignLoading
              ? customCircularProgressIndicator(
                  context: context, color: whiteColor)
              : const Text(
                  'تاكيد',
                  style:
                      TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                ),
        );
      },
    ),
  );
}

Widget biggerRectangleElevatedButton(
    {required double height,
    text,
    required double screenWidth,
    double? elevation,
    sideColor,
    fontSize,
    formKey,
    onPressed,
    child,
    color}) {
  return SizedBox(
    height: height,
    width: screenWidth,
    child: BlocBuilder<SignCubit, SignState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            elevation: WidgetStatePropertyAll(elevation),
            shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
                side: BorderSide(color: sideColor ?? primaryColor),
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(color ?? primaryColor),
          ),
          child: child ??
              Text(
                text ?? '',
                style: TextStyle(
                    color: Theme.of(context).hoverColor,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize ?? 24),
              ),
        );
      },
    ),
  );
}
