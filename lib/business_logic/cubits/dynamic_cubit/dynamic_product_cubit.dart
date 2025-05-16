import 'package:goods/data/global/theme/theme_data.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/data/models/supplier_product_model.dart';
import 'package:goods/presentation/custom_widgets/snack_bar_errors.dart';

class DynamicProductCubit extends Cubit<DynamicProductState> {
  DynamicProductCubit() : super(DynamicProductInitial());

  Future<void> addDynamicProduct(
      BuildContext context, StoreProduct storeProduct, String storeId,
      {required String message}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      emit(DynamicProductLoading());
      await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .doc(storeProduct.productId)
          .set(storeProduct.toMap());
      showCustomPositionedSnackBar(
          context: context, title: 'تمت', message: message);
      emit(DynamicProductLoaded());
    } catch (e) {
      print(e);
      emit(DynamicProductError('Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> markProductAsUnavailable(
      BuildContext context, String storeId, String productId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      emit(DynamicProductLoading());

      // Update the fields: availability to false, isOnSale to false, maxOrderQuantityForOffer, offerPrice, and endDate to null
      await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .doc(productId)
          .update({
        'availability': false,
        'isOnSale': false,
        'maxOrderQuantityForOffer': null,
        'offerPrice': null,
        'endDate': null,
      });

      emit(DynamicProductLoaded());
      print(
          'Product marked as unavailable and offer fields reset successfully');
    } catch (e) {
      emit(DynamicProductError(
          'Failed to mark product as unavailable: ${e.toString()}'));
    }
  }

  Future<void> removeOffer(
      BuildContext context, String storeId, String productId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      emit(DynamicProductLoading());

      // Update the fields: availability to false, isOnSale to false, maxOrderQuantityForOffer, offerPrice, and endDate to null
      await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .doc(productId)
          .update({
        'isOnSale': false,
        'maxOrderQuantityForOffer': null,
        'offerPrice': null,
        'endDate': null,
      });

      emit(DynamicProductLoaded());
      print(
          'Product marked as unavailable and offer fields reset successfully');
    } catch (e) {
      emit(DynamicProductError(
          'Failed to mark product as unavailable: ${e.toString()}'));
    }
  }

  Future<void> updataOffer(
      {required BuildContext context,
      required String productId,
      required int maxOrderQuantityForOffer,
      required int offerPrice,
      required int price,
      required int maxOrderQuantity,
      required int minOrderQuantity}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // print('hello every one');

      emit(DynamicProductLoading());

      await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .doc(productId)
          .update({
        'maxOrderQuantityForOffer': maxOrderQuantityForOffer,
        'offerPrice': offerPrice,
        'price': price,
        'maxOrderQuantity': maxOrderQuantity,
        'minOrderQuantity': minOrderQuantity,
      });

      emit(DynamicProductLoaded());
    } catch (e) {
      emit(DynamicProductError(
          'Failed to mark product as unavailable: ${e.toString()}'));
    }
  }
}

Future<String> fetchStoreId(BuildContext context) async {
  final storeId = await FirebaseFirestore.instance
      .collection('suppliers')
      .doc(supplierId)
      .get()
      .then((value) => value.data()!['storeId']);
  return storeId as String;
}
