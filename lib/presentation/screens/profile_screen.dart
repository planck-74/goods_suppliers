import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/supplier_model.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/services/auth_service.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context,
        const Text(
          'الحساب',
          style: TextStyle(color: whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
              builder: (context, state) {
                if (state is GetSupplierDataSuccess) {
                  return DynamicImageContainer(
                    imageUrl: state.suppliers[0]['imageUrl'],
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 50, 50, 50).withOpacity(0.7),
                        const Color.fromARGB(255, 30, 30, 30).withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 200,
                );
              },
            ),
            BlocBuilder<GetSupplierDataCubit, GetSupplierDataState>(
              builder: (context, state) {
                if (state is GetSupplierDataSuccess) {
                  SupplierModel supplier =
                      SupplierModel.fromMap(state.suppliers[0]);
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              supplier.businessName,
                              style: const TextStyle(
                                  color: darkBlueColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: Image.asset(
                                        'assets/icons/triangle.png'),
                                  ),
                                ),
                                Text(
                                  supplier.category,
                                  style: const TextStyle(
                                      color: darkBlueColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: whiteColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            child: Column(
                              children: [
                                ExpansionTile(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  dense: true,
                                  title: const Text(
                                    "العنوان",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 20),
                                  ),
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Text(
                                            'محافظة:',
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                          Text(
                                            supplier.government,
                                            style: const TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Text(
                                            'مدينة:',
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(
                                            width: 24,
                                          ),
                                          Text(
                                            supplier.town,
                                            style: const TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  dense: true,
                                  title: const Text(
                                    "أرقام الهواتف",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 20),
                                  ),
                                  children: [
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'الرقم ألاساسي:',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              supplier.phoneNumber,
                                              style: const TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Row(
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: Text(
                                              'الرقم الاحتياطي:',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              supplier.secondPhoneNumber,
                                              style: const TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildButton(
                                  context,
                                  Colors.blueGrey,
                                  'تعديل بيانات الحساب',
                                  () => Navigator.pushNamed(
                                      context, '/EditProfile'),
                                ),
                                Container(height: 0.5, color: Colors.grey),
                                _buildButton(
                                  context,
                                  Colors.yellow,
                                  'الإشعارات',
                                  () => showNotificationsDialog(context),
                                ),
                                Container(height: 0.5, color: Colors.grey),
                                _buildButton(
                                  context,
                                  Colors.red,
                                  'تسجيل الخروج',
                                  () {
                                    AuthService.logout(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator(
                  color: darkBlueColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // A helper function to build a single button row.
  Widget _buildButton(
      BuildContext context, Color color, String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DynamicImageContainer extends StatefulWidget {
  final String imageUrl;
  const DynamicImageContainer({super.key, required this.imageUrl});

  @override
  _DynamicImageContainerState createState() => _DynamicImageContainerState();
}

class _DynamicImageContainerState extends State<DynamicImageContainer> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _fetchImageAspectRatio();
  }

  void _fetchImageAspectRatio() {
    final image = Image.network(widget.imageUrl);
    final ImageStream stream = image.image.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _aspectRatio = info.image.width / info.image.height;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_aspectRatio == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 50, 50, 50).withOpacity(0.7),
              const Color.fromARGB(255, 30, 30, 30).withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 200,
      );
    }

    return AspectRatio(
      aspectRatio: _aspectRatio!,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(widget.imageUrl),
          ),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 50, 50, 50).withOpacity(0.7),
              const Color.fromARGB(255, 30, 30, 30).withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

void showNotificationsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const AlertDialog(
        backgroundColor: whiteColor,
        content: Text('ياتي قريباً،إنتظر خدمة إشعارات مميزة'),
      );
    },
  );
}
