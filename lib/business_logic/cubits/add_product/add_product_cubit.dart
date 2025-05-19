import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/snack_bar_errors.dart';
import 'package:goods/business_logic/cubits/search_products/search_products_cubit.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit() : super(AddProductInitial());

  final Map<String, Map<String, dynamic>> selectedProducts = {};

  final TextEditingController priceController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();
  final TextEditingController maxQuantityController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  final TextEditingController maxQuantityControllerOffer =
      TextEditingController();

  bool isOnSale = false;
  bool isAvailable = true;
  DateTime? selectedDate;
  void initializeControllers(Map<String, dynamic> product) {
    final productId = product['productId'].toString();

    // أمنع التهيئة المتكررة
    if (priceController.text.isNotEmpty) return;

    // تحميل القيم الأولية
    priceController.text = product['price']?.toString() ?? '0';
    minQuantityController.text = product['minOrderQuantity']?.toString() ?? '1';
    maxQuantityController.text =
        product['maxOrderQuantity']?.toString() ?? '10';
    offerPriceController.text = product['offerPrice']?.toString() ?? '0';
    maxQuantityControllerOffer.text =
        product['maxOrderQuantityForOffer']?.toString() ?? '10';

    isAvailable = product['availability'] ?? true;
    isOnSale = product['isOnSale'] ?? false;
    selectedDate = product['endDate'];

    // إضافة المنتج مبدئيًا لو مش موجود
    selectedProducts[productId] = Map.from(product);

    // ربط الكونترولرز بالتحديثات
    priceController.addListener(() {
      _updateProductField(productId, 'price', priceController.text);
    });

    minQuantityController.addListener(() {
      _updateProductField(
          productId, 'minOrderQuantity', minQuantityController.text);
    });

    maxQuantityController.addListener(() {
      _updateProductField(
          productId, 'maxOrderQuantity', maxQuantityController.text);
    });

    offerPriceController.addListener(() {
      _updateProductField(productId, 'offerPrice', offerPriceController.text);
    });

    maxQuantityControllerOffer.addListener(() {
      _updateProductField(productId, 'maxOrderQuantityForOffer',
          maxQuantityControllerOffer.text);
    });

    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  void _updateProductField(String productId, String key, dynamic value) {
    final current = selectedProducts[productId] ?? {};
    final updated = {...current, key: _tryParseNumber(value)};
    selectedProducts[productId] = updated;
    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  dynamic _tryParseNumber(String value) {
    final parsed = int.tryParse(value);
    return parsed ?? value; // لو ما قدرش يحوله رقم، يخليه String زي ما هو
  }

  void disposeControllers() {
    priceController.dispose();
    minQuantityController.dispose();
    maxQuantityController.dispose();
    offerPriceController.dispose();
    maxQuantityControllerOffer.dispose();
  }

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

  Map<String, dynamic>? getProduct(String productId) =>
      selectedProducts[productId];
  bool isSelected(String productId) => selectedProducts.containsKey(productId);
  void clearProducts() {
    selectedProducts.clear();
    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  Future<void> addMultipleDynamicProducts(BuildContext context,
      {required String message}) async {
    if (selectedProducts.isEmpty) {
      showCustomPositionedSnackBar(
          context: context, title: 'خطأ', message: 'لم يتم اختيار أي منتجات!');
      return;
    }

    bool hasPriceError = false;
    selectedProducts.forEach((_, productData) {
      int price = int.tryParse(productData['price']?.toString() ?? '0') ?? 0;
      if (price == 0) hasPriceError = true;
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
      selectedProducts.forEach((productId, productData) {
        DocumentReference productRef = firestore
            .collection('stores')
            .doc(storeId)
            .collection('products')
            .doc(productId);
        batch.set(productRef, productData);
      });
      await batch.commit();
      Navigator.pop(context);
      showCustomPositionedSnackBar(
          context: context, title: 'تمت', message: message);
      context
          .read<SearchProductsCubit>()
          .removeAddedProductsFromList(selectedProducts.keys.toList());
      clearProducts();
    } catch (e) {}
  }

  void updateProduct(Map<String, dynamic> product) {
    final productId = product['productId'].toString();
    selectedProducts[productId] = product;
    emit(AddProductLoaded(Map.from(selectedProducts)));
  }
}
