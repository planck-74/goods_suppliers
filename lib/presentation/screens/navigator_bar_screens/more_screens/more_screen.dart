import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/container_add_photo.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/dialogs/dialog_main.dart';
import 'package:goods/services/auth_service.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: primaryColor,
                  height: screenHeight * 0.3,
                  width: screenWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Moved BlocBuilder above CircleAvatar
                        BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
                          builder: (context, state) {
                            if (state is GetSupplierDataSuccess) {
                              // Extract the supplier data from the state
                              final supplier = state.suppliers
                                  .first; // Assuming there's only one supplier for the current user

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Displaying the supplier's image
                                  CircleAvatar(
                                    radius: 50,
                                    // child: Icon(
                                    //   Icons.person,
                                    //   size: 50,
                                    // ),
                                    backgroundImage: NetworkImage(supplier[
                                            'imageUrl'] ??
                                        'default_image_url'), // Fallback image URL
                                    backgroundColor: const Color.fromARGB(
                                        255, 241, 241, 241),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    supplier['name'] ??
                                        'اسم المستخدم', // Fallback if the data is null
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    supplier['businessName'] ??
                                        'اسم الشركة', // Fallback if the data is null
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              );
                            } else if (state is GetSupplierDataLoading) {
                              // Show a loading indicator while the data is being fetched
                              return const CircularProgressIndicator();
                            } else if (state is GetSupplierDataError) {
                              // Handle the error state
                              return const Text(
                                'حدث خطأ أثناء جلب البيانات',
                                style: TextStyle(color: Colors.red),
                              );
                            } else {
                              // Default state (before data is fetched)
                              return Text(
                                'جاري تحميل البيانات...',
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                customButtonMoreScreen(
                    context: context,
                    text: 'تسجيل الخروج',
                    icon: Icons.logout,
                    color: primaryColor,
                    onTap: () async {
                      AuthService.logout(context).then((_) {
                        AuthService.logoutSharedPreferences();
                        Navigator.pushReplacementNamed(context, '/Sign');
                      });
                    }),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showMyDialog(context);
                    },
                    child: const Text(
                      'Show Alert',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(left: 5, top: 35, child: addPhoto()),
          ],
        ),
      ),
    );
  }
}
