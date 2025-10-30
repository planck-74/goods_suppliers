import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/data/constants/constants.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/rectangle_Elevated_button.dart';
import 'package:goods/presentation/custom_widgets/custom_textfield.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/animited_text.dart';

Widget buildPhoneNumberSignUp({
  required double screenHeight,
  required double screenWidth,
  required BuildContext context,
  required GlobalKey<FormState> formKey,
}) {
  TextEditingController phoneNumber =
      context.read<ControllerCubit>().phoneNumber;
  return Form(
    key: formKey,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              animitedTextAuthScreensTwoTexts(
                  context: context,
                  text1: 'يسعدنا رؤيتك',
                  text2: 'الرجاء إدخال رقم هاتفك لتلقي رمز التحقق'),
              const SizedBox(height: 12),
            ],
          ),
        ),
        customTextFormField(
          context: context,
          width: screenWidth,
          labelText: 'رقم الهاتف',
          validationText: 'أدخل رقم الهاتف',
          controller: phoneNumber,
          keyboardType: const TextInputType.numberWithOptions(),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'أدخل رقم الهاتف';
            } else if (value.length != 11) {
              return 'رقم الهاتف يجب أن يكون 11 رقماً';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        rectangleElevatedButton(
          screenWidth: screenWidth,
          formKey: formKey,
          onPressed: () async {
            BlocProvider.of<SignCubit>(context)
                .signWithPhoneNumber(formKey: formKey, context: context);
            PhoneNumberManager.savePhoneNumber(phoneNumber.text);
            supplierId = await PhoneNumberManager.getPhoneNumber() ?? '';
          },
        ),
        SizedBox(height: screenHeight * 0.23),
      ],
    ),
  );
}
