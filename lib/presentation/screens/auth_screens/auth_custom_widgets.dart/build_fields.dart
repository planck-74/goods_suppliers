import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/sign/sign_cubit.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/data/functions/fetch_store_id.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/supplier_model.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_textfield.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/build_image_picker.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/location_picker.dart';
import 'package:goods/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class BuildFields extends StatefulWidget {
  const BuildFields({super.key});

  @override
  State<BuildFields> createState() => _BuildFieldsState();
}

class _BuildFieldsState extends State<BuildFields> {
  XFile? pickedFile;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        pickedFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var uuid = const Uuid();
    final screenWidth = MediaQuery.of(context).size.width;
    final controllerCubit = context.read<ControllerCubit>();
    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Row(
              children: [
                buildImagePicker(
                  screenHeight: MediaQuery.of(context).size.height,
                  context: context,
                  onTap: pickImage,
                  pickedImage:
                      pickedFile != null ? File(pickedFile!.path) : null,
                ),
                Expanded(
                  child: customTextFormField(
                    height: 50,
                    context: context,
                    width: screenWidth * 0.5,
                    controller: controllerCubit.businessNameController,
                    validationText: 'أدخل اسم المنشأة',
                    labelText: 'اسم المنشأة',
                  ),
                ),
              ],
            ),
            customTextFormField(
              height: 50,
              context: context,
              width: screenWidth,
              controller: controllerCubit.secondPhoneNumber,
              validationText: 'أدخل رقم الهاتف الثاني',
              labelText: 'رقم الهاتف الثاني (اختياري)',
              keyboardType: const TextInputType.numberWithOptions(),
            ),
            const SizedBox(
              height: 6,
            ),
            Container(
              height: 50,
              width: screenWidth * 0.95,
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
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                value: null, // أو يمكنك تعيين قيمة افتراضية
                hint: const Text(
                  'نوع النشاط',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'جملة',
                      child: Text(
                        'جملة',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                ],
                onChanged: (value) {
                  context.read<ControllerCubit>().category = value;
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              height: 50,
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.9), // White background color
                borderRadius: BorderRadius.circular(3), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 2, // Spread radius
                    blurRadius: 5, // Blur radius
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                value: null, // أو يمكنك تعيين قيمة افتراضية
                hint: const Text(
                  'محافظة',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'القاهرة',
                      child: Text(
                        'القاهرة',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                ],
                onChanged: (value) {
                  context.read<ControllerCubit>().government = value;
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              height: 50,
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.9), // White background color
                borderRadius: BorderRadius.circular(3), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 2, // Spread radius
                    blurRadius: 5, // Blur radius
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                value: null,
                hint: const Text(
                  'مدينة',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'مدينة نصر',
                      child: Text(
                        'مدينة نصر',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                ],
                onChanged: (value) {
                  context.read<ControllerCubit>().town = value;
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            _buildLocationPicker(screenWidth),
            const SizedBox(height: 12),
            customOutlinedButton(
              context: context,
              backgroundColor: darkBlueColor,
              width: screenWidth * 0.95,
              height: 50,
              child: BlocBuilder<SignCubit, SignState>(
                builder: (context, state) {
                  if (state is SignLoading) {
                    return const CircularProgressIndicator();
                  }
                  return const Text(
                    'حفظ البيانات',
                    style: TextStyle(color: whiteColor),
                  );
                },
              ),
              onPressed: () async {
                final cubit = context.read<ControllerCubit>();
                final businessName = cubit.businessNameController.text.trim();
                debugPrint('businessName: $businessName');
                final category = cubit.category?.trim() ?? '';
                debugPrint('category: $category');
                final phoneNumber = cubit.phoneNumber.text.trim() ?? '';
                debugPrint('phoneNumber: $phoneNumber');
                final secondPhoneNumber = cubit.secondPhoneNumber.text.trim();
                debugPrint('secondPhoneNumber: $secondPhoneNumber');
                final government = cubit.government?.trim() ?? '';
                debugPrint('government: $government');
                final town = cubit.town?.trim() ?? '';
                debugPrint('town: $town');
                final geoPoint = cubit.geoPoint ?? const GeoPoint(0, 0);
                debugPrint('geoPoint: $geoPoint');

                if (businessName.isEmpty ||
                    category.isEmpty ||
                    phoneNumber.isEmpty ||
                    government.isEmpty ||
                    town.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء جميع الحقول المطلوبة!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (pickedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى اختيار صورة للمحل!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جارٍ حفظ البيانات...'),
                      backgroundColor: Colors.blue,
                    ),
                  );

                  await context
                      .read<SignCubit>()
                      .uploadImage(
                        context: context,
                        imageFile: File(pickedFile!.path),
                      )
                      .then((imageUrl) async {
                    await context.read<SignCubit>().saveSupplier(SupplierModel(
                          ////////////////////////////////////
                          ///////////////////////////////////
                          uid: supplierId,
                          businessName: businessName,
                          category: category,
                          imageUrl: imageUrl,
                          phoneNumber: phoneNumber,
                          secondPhoneNumber: secondPhoneNumber,
                          geoPoint: geoPoint,
                          storeId: uuid.v1(),
                          government: government,
                          town: town,
                        ));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ البيانات بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    fetchAndSaveStoreId();
                    AuthService.saveLoginState(true);
                    Navigator.pushNamed(context, '/NavigatorBar');
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker(double width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 250,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const LocationPickerScreen(),
      ),
    );
  }
}
