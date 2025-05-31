import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/presentation/custom_widgets/snack_bar_errors.dart';

// States
abstract class ProductsSyncState {}

class ProductsSyncInitial extends ProductsSyncState {}

class ProductsSyncLoading extends ProductsSyncState {}

class ProductsSyncLoaded extends ProductsSyncState {}

class ProductsSyncError extends ProductsSyncState {
  final String message;
  ProductsSyncError(this.message);
}

class ProductsSyncCubit extends Cubit<ProductsSyncState> {
  ProductsSyncCubit() : super(ProductsSyncInitial());

  Future<void> syncStoreProducts(BuildContext context, String storeId) async {
    try {
      emit(ProductsSyncLoading());

      // Get reference to Firestore
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get all store products
      final storeProductsSnapshot = await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .get();

      // Create a batch for bulk updates
      WriteBatch batch = firestore.batch();

      // For each store product
      for (var storeDoc in storeProductsSnapshot.docs) {
        final storeProduct = storeDoc.data();
        final productId = storeProduct['productId'];

        // Get the corresponding main product
        final mainProductDoc =
            await firestore.collection('products').doc(productId).get();

        if (mainProductDoc.exists) {
          final mainProduct = mainProductDoc.data()!;

          // Update only shared fields while keeping store-specific fields
          final updatedData = {
            ...storeProduct, // Keep all existing store fields
            // Update shared fields from main product
            'name': mainProduct['name'],
            'classification': mainProduct['classification'],
            'imageUrl': mainProduct['imageUrl'],
            'manufacturer': mainProduct['manufacturer'],
            'size': mainProduct['size'],
            'package': mainProduct['package'],
            'note': mainProduct['note'],
            // Store-specific fields are preserved:
            // - price
            // - offerPrice
            // - maxOrderQuantity
            // - minOrderQuantity
            // - maxOrderQuantityForOffer
            // - isOnSale
            // - availability
            // - endDate
            // - salesCount
          };

          // Add to batch
          batch.update(storeDoc.reference, updatedData);
        }
      }

      // Commit all updates
      await batch.commit();

      emit(ProductsSyncLoaded());

      showCustomPositionedSnackBar(
        context: context,
        title: 'تم',
        message: 'تم تحديث بيانات المنتجات بنجاح',
      );
    } catch (e) {
      emit(ProductsSyncError(e.toString()));
      showCustomPositionedSnackBarError(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء تحديث البيانات: $e',
      );
    }
  }
}
