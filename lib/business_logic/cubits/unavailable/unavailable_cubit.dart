import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_state.dart';

class UnAvailableCubit extends Cubit<UnAvailableState> {
  UnAvailableCubit() : super(UnavailableInitial());
  List<Map<String, dynamic>> combinedProducts = [];

  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>> filteredProducts = [];
  List<QueryDocumentSnapshot> UnAvailableProducts = [];

  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> pagedProducts = [];

  void filterProducts(String filterType, String value) async {
    filteredProducts.clear();
    emit(UnavailableLoading());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (var product
        in UnAvailableProducts.map((doc) => doc.data() as Map<String, dynamic>)
            .toList()) {
      if (product[filterType] == value) {
        filteredProducts.add(product);
      }
    }
    emit(UnavailableLoaded(List.from(filteredProducts)));
  }

  Future<void> fetchInitialUnAvailableProducts(String storeId) async {
    UnAvailableProducts = [];
    pagedProducts = [];
    lastDocument = null;
    hasMore = true;
    emit(UnavailableLoading());
    await _fetchUnAvailableProductsPage(storeId);
  }

  Future<void> fetchNextUnAvailableProductsPage(String storeId) async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    emit(UnavailableLoadingMore(List.from(pagedProducts)));
    await _fetchUnAvailableProductsPage(storeId);
    isLoadingMore = false;
  }

  Future<void> _fetchUnAvailableProductsPage(String storeId) async {
    if (storeId.isEmpty) {
      emit(UnavailableError('Store ID is empty'));
      return;
    }
    CollectionReference productsRef = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products');
    Query query =
        productsRef.where('availability', isEqualTo: false).limit(pageSize);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      UnAvailableProducts.addAll(querySnapshot.docs);
      pagedProducts.addAll(
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      emit(UnavailableLoaded(List.from(pagedProducts)));
      if (querySnapshot.docs.length < pageSize) {
        hasMore = false;
      }
    } else {
      hasMore = false;
      emit(UnavailableLoaded(List.from(pagedProducts)));
    }
  }

  // Deprecated: use fetchInitialUnAvailableProducts/fetchNextUnAvailableProductsPage for lazy loading
  @Deprecated(
      'Use fetchInitialUnAvailableProducts/fetchNextUnAvailableProductsPage for lazy loading')
  Future<List<QueryDocumentSnapshot<Object?>>?> UnAvailable(
      String storeId) async {
    UnAvailableProducts = [];
    emit(UnavailableLoading());
    if (storeId.isNotEmpty) {
      CollectionReference productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      QuerySnapshot querySnapshot =
          await productsRef.where('availability', isEqualTo: false).get();
      UnAvailableProducts = querySnapshot.docs;
      emit(UnavailableLoaded(
          UnAvailableProducts.map((doc) => doc.data() as Map<String, dynamic>)
              .toList()));

      return UnAvailableProducts;
    }

    return null;
  }

  void eliminateProduct({required int index}) {
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(UnavailableLoaded(productData!));
    } else {
      print(
          'Cannot eliminate product: productData is null or index is out of bounds.');
    }
  }
}
