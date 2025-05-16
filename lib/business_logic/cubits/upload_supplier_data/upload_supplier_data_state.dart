import 'dart:io';

abstract class UploadSupplierDataState {}

class UploadSupplierDataInitial extends UploadSupplierDataState {}

class ImageLoading extends UploadSupplierDataState {}

class ImageLoaded extends UploadSupplierDataState {
  final File image;

  ImageLoaded(this.image);
}

class ImageError extends UploadSupplierDataState {
  final String message;

  ImageError(this.message);
}

class UploadSupplierDataloading extends UploadSupplierDataState {}

class UploadSupplierDataloaded extends UploadSupplierDataState {}

class UploadSupplierDataError extends UploadSupplierDataState {
  final String message;

  UploadSupplierDataError(this.message);
}
