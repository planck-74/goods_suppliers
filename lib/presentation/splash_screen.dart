import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/auth_check.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetSupplierDataCubit>().getSupplierData();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset('assets/animations/splash_animation.json',
            repeat: true, fit: BoxFit.fitHeight),
      ),
      nextScreen: const AuthCheck(),
      duration: 5000,
    );
  }
}
