import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/image_picker/image_picker_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageInitial());
  XFile? image;

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

  Future<void> uploadSupplierData(BuildContext context) async {}
}
