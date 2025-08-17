import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

part 'search_products_state.dart';

class SearchProductsCubit extends Cubit<SearchProductsState> {
  SearchProductsCubit() : super(SearchProductsInitial(products: const []));

  final TextEditingController searchProduct = TextEditingController();

  List<Map<String, dynamic>> _filteredProducts = [];

  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> pagedProducts = [];

  Future<void> fetchInitialAvailableProductsNotInStore() async {
    lastDocument = null;
    hasMore = true;
    pagedProducts = [];
    emit(SearchProductsLoading());
    await _fetchAvailableProductsNotInStorePage();
  }

  Future<void> fetchNextAvailableProductsNotInStorePage() async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    emit(SearchProductsLoadingMore(List.from(pagedProducts)));
    await _fetchAvailableProductsNotInStorePage();
    isLoadingMore = false;
  }

  Future<void> _fetchAvailableProductsNotInStorePage() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      Query allProductsQuery = firestore.collection('products').limit(pageSize);
      if (lastDocument != null) {
        allProductsQuery = allProductsQuery.startAfterDocument(lastDocument!);
      }
      final allProductsSnapshot = await allProductsQuery.get();
      if (allProductsSnapshot.docs.isEmpty) {
        hasMore = false;
        emit(SearchProductsLoaded(List.from(pagedProducts)));
        return;
      }
      final storeProductsSnapshot = await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .get();
      final storeProductIds = storeProductsSnapshot.docs
          .map((doc) => doc.data()['productId']?.toString())
          .whereType<String>()
          .toSet();
      final filteredProducts = allProductsSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final productId = data['productId']?.toString();
        final isInStore =
            productId != null && storeProductIds.contains(productId);
        return !isInStore;
      }).toList();
      lastDocument = allProductsSnapshot.docs.last;
      pagedProducts.addAll(
          filteredProducts.map((doc) => doc.data() as Map<String, dynamic>));
      emit(SearchProductsLoaded(List.from(pagedProducts)));
      if (filteredProducts.length < pageSize) {
        hasMore = false;
      }
    } catch (e) {
      emit(SearchProductsError('حدث خطأ أثناء تحميل المنتجات: $e'));
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchAvailableProductsNotInStore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    emit(SearchProductsLoading());
    try {
      final allProductsSnapshot = await firestore.collection('products').get();

      final storeProductsSnapshot = await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .get();

      final storeProductIds = storeProductsSnapshot.docs
          .map((doc) => doc.data()['productId']?.toString())
          .whereType<String>()
          .toSet();

      for (var id in storeProductIds) {
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
      emit(SearchProductsInitial(products: const []));
      return [];
    }
  }

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

    final idsToRemove = addedProductIds.map((e) => e.toString()).toSet();



    _filteredProducts.removeWhere((product) {
      final pid = product['productId'].toString();
      if (idsToRemove.contains(pid)) {
        return true;
      }
      return false;
    });


    if (state is SearchProductsLoaded) {

      final currentResults = (state as SearchProductsLoaded).products;

      final updatedResults = currentResults.where((product) {
        final pid = product['productId'].toString();
        return !idsToRemove.contains(pid);
      }).toList();

      emit(SearchProductsLoaded(updatedResults));
    } else if (state is SearchProductsInitial) {
      emit(SearchProductsInitial(products: _filteredProducts));
    } else {
    }
  }
}
