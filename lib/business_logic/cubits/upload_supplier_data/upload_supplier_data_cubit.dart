import 'dart:io';
// Importing dart:math to use Random
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/firestore/firestore_cubits.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/business_logic/cubits/upload_supplier_data/upload_supplier_data_state.dart';
import 'package:goods/data/functions/fetch_store_id.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/services/storage_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UploadSupplierDataCubit extends Cubit<UploadSupplierDataState> {
  UploadSupplierDataCubit() : super(UploadSupplierDataInitial());
  XFile? image;
  final uuid = const Uuid();

  Future<void> pickImage() async {
    try {
      emit(ImageLoading());
      final ImagePicker picker = ImagePicker();
      image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        emit(ImageLoaded(File(image!.path)));
      } else {
        emit(ImageError('No image selected'));
      }
    } catch (e) {
      emit(ImageError('Failed to pick image: $e'));
    }
  }

  Future<void> uploadSupplierData(BuildContext context) async {
    if (state is! ImageLoaded) {
      emit(UploadSupplierDataError('No image available for upload.'));
      return;
    }

    try {
      // Extract necessary data before the async operation
      final imageFile = (state as ImageLoaded).image;
      final firestoreCubit = context.read<FirestoreCubit>();
      final controllerCubit = context.read<ControllerCubit>();
      final currentUser = FirebaseAuth.instance.currentUser;

      emit(UploadSupplierDataloading());

      // Upload the image and get the download URL
      final downloadUrl = await StorageServices.uploadImage(
        context: context,
        imageFile: imageFile,
      );

      if (downloadUrl.isEmpty) {
        emit(UploadSupplierDataError(
            'Failed to upload image. Please try again.'));
        return;
      }

      // Save client data
      await firestoreCubit.saveSupplier(ClientModel(
        uid: currentUser!.uid,
        businessName: controllerCubit.businessNameController.text,
        category: '',
        imageUrl: downloadUrl,
        phoneNumber: controllerCubit.phoneNumber.text,
        secondPhoneNumber: controllerCubit.secondPhoneNumber.text,
        geoLocation: controllerCubit.geoLocation ?? const GeoPoint(0, 0),
        government: '',
        town: '', addressTyped: '',
      ));

      if (!context.mounted) return;
      fetchAndSaveStoreId();
      Navigator.pushNamed(context, '/NavigatorBar');
      emit(UploadSupplierDataloaded());
    } catch (e) {
      emit(UploadSupplierDataError('Failed to upload Client data: $e'));
    }
  }

  Future<void> updateClientData(BuildContext context) async {
    emit(UploadSupplierDataloading());
    final controllerCubit = context.read<ControllerCubit>();

    try {
      FirebaseFirestore.instance
          .collection('suppliers')
          .doc(supplierId)
          .update({
        'businessName': controllerCubit.businessNameController.text,
        'phoneNumber': controllerCubit.phoneNumber.text,
        'category': controllerCubit.categoryController.text,
        'government': controllerCubit.governmentController.text,
        'town': controllerCubit.townController.text,
        'secondPhoneNumber': controllerCubit.secondPhoneNumber.text,
      });

      emit(UploadSupplierDataloaded());
    } catch (e) {
      emit(UploadSupplierDataError('Failed to upload Client data: $e'));
    }
  }
}
