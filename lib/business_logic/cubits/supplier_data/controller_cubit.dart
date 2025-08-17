import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'controller_state.dart';

class ControllerCubit extends Cubit<ControllerState> {
  ControllerCubit() : super(ControllerInitial());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController governmentController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController secondPhoneNumber = TextEditingController();
  GeoPoint? geoLocation;
  // ... other fields if needed

  /// Initialize controllers from a client map.
  /// This method checks if the controllers are still empty to avoid overwriting user edits.
  void initControllers(Map<String, dynamic> client) {
    if (businessNameController.text.isEmpty) {
      businessNameController.text = client['businessName'] ?? '';
    }
    if (governmentController.text.isEmpty) {
      governmentController.text = client['government'] ?? '';
    }
    if (townController.text.isEmpty) {
      townController.text = client['town'] ?? '';
    }
    if (categoryController.text.isEmpty) {
      categoryController.text = client['category'] ?? '';
    }
    if (phoneNumber.text.isEmpty) {
      phoneNumber.text = client['phoneNumber'] ?? '';
    }
    if (secondPhoneNumber.text.isEmpty) {
      secondPhoneNumber.text = client['secondPhoneNumber'] ?? '';
    }
    geoLocation = client['geoLocation'];
  }

  String? category;
  String? government;
  String? town;

  List<String> storeIds = [];

  // Search data
  final TextEditingController searchProduct = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  void clearSearchDetails() {
    searchResults.clear();
    emit(ControllerInitial());
  }
}
