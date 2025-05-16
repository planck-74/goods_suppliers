import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

part 'search_products_state.dart';

class SearchProductsCubit extends Cubit<SearchProductsState> {
  SearchProductsCubit() : super(SearchProductsInitial(products: const []));

  final TextEditingController searchProduct = TextEditingController();

  List<Map<String, dynamic>> _filteredProducts = [];

  Future<List<QueryDocumentSnapshot>> fetchAvailableProductsNotInStore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    emit(SearchProductsLoading());
    try {
      print('📥 Fetching all products from main collection...');
      final allProductsSnapshot = await firestore.collection('products').get();
      print(
          '✅ Total products found in main collection: ${allProductsSnapshot.docs.length}');

      print('📥 Fetching products from store: $storeId ...');
      final storeProductsSnapshot = await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .get();
      print('✅ Total products in store: ${storeProductsSnapshot.docs.length}');

      final storeProductIds = storeProductsSnapshot.docs
          .map((doc) => doc.data()['productId'] as String)
          .toSet();

      print('🧮 Store product IDs:');
      for (var id in storeProductIds) {
        print('  - $id');
      }

      final filteredProducts = allProductsSnapshot.docs.where((doc) {
        final data = doc.data();
        final productId = data['productId'];
        final isInStore = storeProductIds.contains(productId);
        return !isInStore;
      }).toList();

      // حفظ النتائج محليًا على شكل List<Map<String, dynamic>>
      _filteredProducts = filteredProducts.map((doc) => doc.data()).toList();

      emit(SearchProductsInitial(products: _filteredProducts));
      return filteredProducts;
    } catch (e) {
      print('❌ Error fetching products not in store: $e');
      emit(SearchProductsInitial(products: const []));
      return [];
    }
  }

  /// دالة البحث داخل المنتجات المفلترة محليًا
  Future<void> searchProducts(String searchQuery) async {
    if (searchQuery.isNotEmpty) {
      emit(SearchProductsLoading());
      final lowerQuery = searchQuery.toLowerCase();

      final results = _filteredProducts.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        return name.contains(lowerQuery);
      }).toList();

      emit(SearchProductsLoaded(results));
    } else {
      // لو المستخدم مسح النص، عرض كل المنتجات المفلترة
      emit(SearchProductsInitial(products: _filteredProducts));
    }
  }

  void removeAddedProductsFromList(List<String> addedProductIds) {
    print("🧽 removeAddedProductsFromList called");

    final idsToRemove = addedProductIds.map((e) => e.toString()).toSet();

    print("🟨 Product IDs to remove: $idsToRemove");

    print("🗂️ Filtered products before: ${_filteredProducts.length}");

    _filteredProducts.removeWhere((product) {
      final pid = product['productId'].toString();
      if (idsToRemove.contains(pid)) {
        print("❌ Removing from _filteredProducts: $pid");
        return true;
      }
      return false;
    });

    print("📁 Filtered products after: ${_filteredProducts.length}");

    if (state is SearchProductsLoaded) {
      print("🔵 State is SearchProductsLoaded");

      final currentResults = (state as SearchProductsLoaded).products;

      final updatedResults = currentResults.where((product) {
        final pid = product['productId'].toString();
        return !idsToRemove.contains(pid);
      }).toList();

      print("✅ Visible results after removal: ${updatedResults.length}");
      emit(SearchProductsLoaded(updatedResults));
    } else if (state is SearchProductsInitial) {
      print("🟢 State is SearchProductsInitial");
      emit(SearchProductsInitial(products: _filteredProducts));
    } else {
      print("⚠️ State is ${state.runtimeType}, no update done");
    }
  }
}
