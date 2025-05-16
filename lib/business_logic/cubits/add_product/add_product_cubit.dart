import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_state.dart';
import 'package:goods/business_logic/cubits/search_products/search_products_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/snack_bar_errors.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit() : super(AddProductInitial());

  final Map<String, Map<String, dynamic>> selectedProducts = {};

  void selectProducts(Map<String, dynamic> product) {
    emit(AddProductLoading(selectedProducts));

    final productId = product['productId'].toString();

    if (selectedProducts.containsKey(productId)) {
      selectedProducts.remove(productId);
    } else {
      selectedProducts[productId] = product;
    }

    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  Map<String, dynamic>? getProduct(String productId) {
    return selectedProducts[productId];
  }

  bool isSelected(String productId) {
    return selectedProducts.containsKey(productId);
  }

  void clearProducts() {
    selectedProducts.clear();
    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  Future<void> addMultipleDynamicProducts(BuildContext context,
      {required String message}) async {
    print("🔵 addMultipleDynamicProducts() called");

    if (selectedProducts.isEmpty) {
      print("❌ No products selected!");
      showCustomPositionedSnackBar(
          context: context, title: 'خطأ', message: 'لم يتم اختيار أي منتجات!');
      return;
    }

    // التحقق من وجود منتجات سعرها 0
    bool hasPriceError = false;
    selectedProducts.forEach((productId, productData) {
      int price = int.tryParse(productData['price']?.toString() ?? '0') ?? 0;
      if (price == 0) {
        hasPriceError = true;
      }
    });

    if (hasPriceError) {
      showCustomPositionedSnackBarError(
          context: context,
          title: 'خطأ',
          message: 'بعض المنتجات سعرها 0، الرجاء إضافة السعر.');
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      emit(AddProductLoading(selectedProducts));

      WriteBatch batch = firestore.batch();

      print("🟢 Uploading ${selectedProducts.length} products...");

      selectedProducts.forEach((productId, productData) {
        print("📦 Adding product: $productId -> $productData");

        DocumentReference productRef = firestore
            .collection('stores')
            .doc(storeId) // تأكد من تمرير storeId بشكل صحيح
            .collection('products')
            .doc(productId);

        batch.set(productRef, productData);
      });

      await batch.commit();

      Navigator.pop(context);
      print("✅ All products uploaded successfully!");

      showCustomPositionedSnackBar(
          context: context, title: 'تمت', message: message);
      final searchCubit = context.read<SearchProductsCubit>();
      searchCubit.removeAddedProductsFromList(selectedProducts.keys.toList());

      clearProducts();
      emit(AddProductLoaded(selectedProducts));
      print("🗑️ Selected products cleared!");
    } catch (e) {
      print("❌ Error uploading products: $e");
    }
  }

  void updateProduct(Map<String, dynamic> product) {
    final productId = product['productId'].toString();
    selectedProducts[productId] =
        product; // تحديث أو إضافة المنتج بدون تبديل الحالة
    emit(AddProductLoaded(Map.from(selectedProducts)));
  }
}
