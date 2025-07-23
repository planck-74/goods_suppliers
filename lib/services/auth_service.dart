import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/snack_bar_errors.dart';
import 'package:goods/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static void resendVerificationCode({
    required String phoneNumber,
    required BuildContext context,
    required int resendToken,
    required void Function(String verificationId, int? newResendToken)
        onCodeSent,
  }) {
    auth.verifyPhoneNumber(
      phoneNumber: '+20$phoneNumber',
      verificationCompleted: (credential) async {
        // Auto-retrieval or instant verification logic
      },
      verificationFailed: (e) {
        showSnackBar(context, 'Verification failed: ${e.message}', Colors.red);
      },
      codeSent: (verificationId, newResendToken) {
        // Update the verificationId and resendToken
        onCodeSent(verificationId, newResendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        // Handle auto-retrieval timeout
      },
      forceResendingToken: resendToken, // Pass the resendToken here
    );
  }

  static Future<void> logout(BuildContext context) async {
    try {
      final notificationService =
          NotificationService(navigatorKey: navigatorKey);
      await notificationService.removeCurrentToken();

      await auth.signOut().then((value) {
        showSnackBar(context, 'تم تسجيل الخروج.', darkBlueColor);
        saveLoginState(false);
        context.read<GetSupplierDataCubit>().clearSupplierData();
        Navigator.pushReplacementNamed(context, '/Sign');
      });
    } catch (e) {
      showSnackBar(context,
          'حدث خطأ أثناء تسجيل الخروج. برجاء المحاولة مرة أخرى.', Colors.red);
    }
  }

  static Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final querySnapshot = await firestore
          .collection('suppliers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Helper method to show SnackBar messages
  static void showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    snackBarErrors(context: context, text: message);
  }

  static Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool> getLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logoutSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }
}
