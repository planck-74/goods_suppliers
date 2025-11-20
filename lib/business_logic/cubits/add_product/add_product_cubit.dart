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

  // Map to store controllers per product
  final Map<String, ProductControllers> _productControllers = {};

  // Individual product controller management
  ProductControllers getOrCreateControllers(
      String productId, Map<String, dynamic> product) {
    if (!_productControllers.containsKey(productId)) {
      _productControllers[productId] = ProductControllers(
        priceController:
            TextEditingController(text: product['price']?.toString() ?? '0'),
        minQuantityController: TextEditingController(
            text: product['minOrderQuantity']?.toString() ?? '1'),
        maxQuantityController: TextEditingController(
            text: product['maxOrderQuantity']?.toString() ?? '10'),
        offerPriceController: TextEditingController(
            text: product['offerPrice']?.toString() ?? '0'),
        maxQuantityControllerOffer: TextEditingController(
            text: product['maxOrderQuantityForOffer']?.toString() ?? '10'),
      );

      // Setup listeners for this specific product
      _setupListeners(productId);
    }
    return _productControllers[productId]!;
  }

  void _setupListeners(String productId) {
    final controllers = _productControllers[productId]!;

    controllers.priceController.addListener(() {
      _updateProductField(productId, 'price', controllers.priceController.text);
    });

    controllers.minQuantityController.addListener(() {
      _updateProductField(productId, 'minOrderQuantity',
          controllers.minQuantityController.text);
    });

    controllers.maxQuantityController.addListener(() {
      _updateProductField(productId, 'maxOrderQuantity',
          controllers.maxQuantityController.text);
    });

    controllers.offerPriceController.addListener(() {
      _updateProductField(
          productId, 'offerPrice', controllers.offerPriceController.text);
    });

    controllers.maxQuantityControllerOffer.addListener(() {
      _updateProductField(productId, 'maxOrderQuantityForOffer',
          controllers.maxQuantityControllerOffer.text);
    });
  }

  void _updateProductField(String productId, String key, dynamic value) {
    if (selectedProducts.containsKey(productId)) {
      final current = selectedProducts[productId] ?? {};
      final updated = {...current, key: _tryParseNumber(value)};
      selectedProducts[productId] = updated;
      emit(AddProductLoaded(Map.from(selectedProducts)));
    }
  }

  dynamic _tryParseNumber(String value) {
    final parsed = int.tryParse(value);
    return parsed ?? value;
  }

  void selectProducts(Map<String, dynamic> product) {
    final productId = product['productId'].toString();

    if (selectedProducts.containsKey(productId)) {
      // Remove product and dispose its controllers
      selectedProducts.remove(productId);
      _disposeProductControllers(productId);
    } else {
      // Add product and create new controllers
      selectedProducts[productId] = Map.from(product);
      getOrCreateControllers(productId, product);
    }

    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  void _disposeProductControllers(String productId) {
    if (_productControllers.containsKey(productId)) {
      _productControllers[productId]!.dispose();
      _productControllers.remove(productId);
    }
  }

  Map<String, dynamic>? getProduct(String productId) =>
      selectedProducts[productId];

  bool isSelected(String productId) => selectedProducts.containsKey(productId);

  void clearProducts() {
    // Dispose all controllers before clearing
    _productControllers.forEach((key, controllers) {
      controllers.dispose();
    });
    _productControllers.clear();
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
      emit(AddProductLoading(Map.from(selectedProducts)));

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

      // Clear all products and controllers after successful upload
      clearProducts();
    } catch (e) {
      emit(AddProductError(e.toString()));
    }
  }

  void updateProduct(Map<String, dynamic> product) {
    final productId = product['productId'].toString();
    selectedProducts[productId] = product;
    emit(AddProductLoaded(Map.from(selectedProducts)));
  }

  @override
  Future<void> close() {
    // Dispose all controllers when cubit is closed
    _productControllers.forEach((key, controllers) {
      controllers.dispose();
    });
    _productControllers.clear();
    return super.close();
  }
}

// Helper class to manage controllers for each product
class ProductControllers {
  final TextEditingController priceController;
  final TextEditingController minQuantityController;
  final TextEditingController maxQuantityController;
  final TextEditingController offerPriceController;
  final TextEditingController maxQuantityControllerOffer;

  ProductControllers({
    required this.priceController,
    required this.minQuantityController,
    required this.maxQuantityController,
    required this.offerPriceController,
    required this.maxQuantityControllerOffer,
  });

  void dispose() {
    priceController.dispose();
    minQuantityController.dispose();
    maxQuantityController.dispose();
    offerPriceController.dispose();
    maxQuantityControllerOffer.dispose();
  }
}
