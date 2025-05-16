import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class StorageServices {
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<String> uploadImage({
    required BuildContext context,
    required File imageFile,
  }) async {
    // Generate a unique file name using timestamp or UUID to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        '${context.read<ControllerCubit>().nameController.text}_$timestamp.jpg';

    String uid = supplierId;

    Reference ref = storage.ref().child('clients/$uid/images/$fileName');

    try {
      await ref.putFile(imageFile);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return '';
    }
  }
}
