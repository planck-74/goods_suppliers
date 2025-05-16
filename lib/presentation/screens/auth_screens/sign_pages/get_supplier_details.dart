import 'package:flutter/material.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/build_fields.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:goods/presentation/backgrounds/otp_background.dart';

class GetSupplierDetailsScreen extends StatefulWidget {
  const GetSupplierDetailsScreen({super.key});

  @override
  State<GetSupplierDetailsScreen> createState() =>
      _GetSupplierDetailsScreenState();
}

class _GetSupplierDetailsScreenState extends State<GetSupplierDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    if (!await Permission.location.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          width: screenSize.width,
          child: const Stack(
            children: [
              BuildBackground(),
              BuildFields(),
            ],
          ),
        ),
      ),
    );
  }
}
