import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/business_logic/cubits/upload_supplier_data/upload_supplier_data_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // States to control editability for each field
  bool isBusinessNameEditable = false;
  bool isGovernmentEditable = false;
  bool isTownEditable = false;
  bool isCategoryEditable = false;
  bool isPhoneEditable = false;
  bool isSecondaryPhoneEditable = false;

  @override
  Widget build(BuildContext context) {
    // Retrieve the cubit instance from context
    final ControllerCubit controllerCubit = context.read<ControllerCubit>();

    return Scaffold(
      appBar: customAppBar(
        context,
        const Text(
          'تعديل البيانات',
          style: TextStyle(color: whiteColor),
        ),
      ),
      body: BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
        builder: (context, state) {
          if (state is GetSupplierDataSuccess) {
            Map<String, dynamic> supplier = state.suppliers[0];

            // Initialize cubit controllers with client data if not already initialized
            controllerCubit.initControllers(supplier);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Business Name field
                  buildEditableField(
                    label: "الاسم التجاري",
                    controller: controllerCubit.businessNameController,
                    isEditable: isBusinessNameEditable,
                    onIconTap: () {
                      setState(() {
                        isBusinessNameEditable = !isBusinessNameEditable;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Government field
                  buildEditableField(
                    label: "محافظة",
                    controller: controllerCubit.governmentController,
                    isEditable: isGovernmentEditable,
                    onIconTap: () {
                      setState(() {
                        isGovernmentEditable = !isGovernmentEditable;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Town field
                  buildEditableField(
                    label: "مدينة",
                    controller: controllerCubit.townController,
                    isEditable: isTownEditable,
                    onIconTap: () {
                      setState(() {
                        isTownEditable = !isTownEditable;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Category field
                  buildEditableField(
                    label: "التصنيف",
                    controller: controllerCubit.categoryController,
                    isEditable: isCategoryEditable,
                    onIconTap: () {
                      setState(() {
                        isCategoryEditable = !isCategoryEditable;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  // Secondary Phone field
                  buildEditableField(
                    label: "رقم الهاتف الثاني",
                    controller: controllerCubit.secondPhoneNumber,
                    isEditable: isSecondaryPhoneEditable,
                    onIconTap: () {
                      setState(() {
                        isSecondaryPhoneEditable = !isSecondaryPhoneEditable;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm Button
                  customElevatedButtonRectangle(
                    onPressed: () => context
                        .read<UploadSupplierDataCubit>()
                        .updateClientData(context),
                    color: Theme.of(context).secondaryHeaderColor,
                    context: context,
                    child: const Text(
                      'تاكيد التعديلات',
                      style: TextStyle(color: Colors.white),
                    ),
                    screenWidth: MediaQuery.of(context).size.width,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: darkBlueColor,
            ),
          );
        },
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onIconTap,
  }) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: !isEditable,
              style: TextStyle(
                color: isEditable ? Colors.black : Colors.grey,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isEditable ? Icons.lock_open : Icons.lock,
              color: Colors.black45,
            ),
            onPressed: onIconTap,
          ),
        ],
      ),
    );
  }
}
