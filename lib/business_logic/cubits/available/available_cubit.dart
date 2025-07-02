import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/available/available_state.dart';

class AvailableCubit extends Cubit<AvailableState> {
  AvailableCubit() : super(AvailableInitial());

  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>> filteredProducts = [];
  List<QueryDocumentSnapshot> AvailableProducts = [];

  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> pagedProducts = [];

  void filterProducts(String filterType, String value) async {
    filteredProducts.clear();
    emit(AvailableLoading());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (var product
        in AvailableProducts.map((doc) => doc.data() as Map<String, dynamic>)
            .toList()) {
      if (product[filterType] == value) {
        filteredProducts.add(product);
      }
    }
    emit(AvailableLoaded(List.from(filteredProducts)));
  }

  Future<void> fetchInitialAvailableProducts(String storeId) async {
    AvailableProducts = [];
    pagedProducts = [];
    lastDocument = null;
    hasMore = true;
    emit(AvailableLoading());
    await _fetchAvailableProductsPage(storeId);
  }

  Future<void> fetchNextAvailableProductsPage(String storeId) async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    emit(AvailableLoadingMore(List.from(pagedProducts)));
    await _fetchAvailableProductsPage(storeId);
    isLoadingMore = false;
  }

  Future<void> _fetchAvailableProductsPage(String storeId) async {
    if (storeId.isEmpty) {
      emit(AvailableError('Store ID is empty'));
      return;
    }
    CollectionReference productsRef = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products');
    Query query =
        productsRef.where('availability', isEqualTo: true).limit(pageSize);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      AvailableProducts.addAll(querySnapshot.docs);
      pagedProducts.addAll(
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      emit(AvailableLoaded(List.from(pagedProducts)));
      if (querySnapshot.docs.length < pageSize) {
        hasMore = false;
      }
    } else {
      hasMore = false;
      emit(AvailableLoaded(List.from(pagedProducts)));
    }
  }

  // Deprecated: use fetchInitialAvailableProducts/fetchNextAvailableProductsPage for lazy loading
  @Deprecated(
      'Use fetchInitialAvailableProducts/fetchNextAvailableProductsPage for lazy loading')
  Future<List<QueryDocumentSnapshot<Object?>>?> available(
      String storeId) async {
    AvailableProducts = [];
    emit(AvailableLoading());
    if (storeId.isNotEmpty) {
      CollectionReference productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      QuerySnapshot querySnapshot =
          await productsRef.where('availability', isEqualTo: true).get();
      AvailableProducts = querySnapshot.docs;
      print('available products fetched: \\${AvailableProducts.length} found');
      emit(AvailableLoaded(
          AvailableProducts.map((doc) => doc.data() as Map<String, dynamic>)
              .toList()));

      return AvailableProducts;
    }

    return null;
  }

  Future<DocumentSnapshot?> fetchStaticProduct(String productId) async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection('products');

    final QuerySnapshot snapshot =
        await ref.where('productId', isEqualTo: productId).get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first; // Return the first document found
    } else {
      return null; // Return null if no document is found
    }
  }

  void eliminateProduct({required int index}) {
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(AvailableLoaded(productData!)); // Emit the updated list
    } else {
      print(
          'Cannot eliminate product: productData is null or index is out of bounds.');
    }
  }

  Future<void> searchAvailableProducts(String storeId, String query) async {
    emit(AvailableLoading());
    try {
      final productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');
      final result = await productsRef
          .where('availability', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      final products = result.docs.map((doc) => doc.data()).toList();
      emit(AvailableLoaded(products));
    } catch (e) {
      emit(AvailableError('حدث خطأ أثناء البحث: $e'));
    }
  }
}
