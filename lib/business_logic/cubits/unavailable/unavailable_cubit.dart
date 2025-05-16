import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_state.dart';

class UnAvailableCubit extends Cubit<UnAvailableState> {
  UnAvailableCubit() : super(UnavailableInitial());
  List<Map<String, dynamic>> combinedProducts = [];

  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>> filteredProducts = [];

  void filterProducts(String filterType, String value) async {
    filteredProducts.clear();
    emit(UnavailableLoading());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (var product in combinedProducts) {
      if (product['staticData'][filterType] == value) {
        filteredProducts.add(product);
      }
    }
    emit(UnavailableLoaded(List.from(filteredProducts)));
  }

  // unavailable products
  Future<List<QueryDocumentSnapshot<Object?>>?> unavailable(
      String storeId) async {
    List<QueryDocumentSnapshot> unAvailableProducts = [];

    if (storeId.isNotEmpty) {
      CollectionReference productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      QuerySnapshot querySnapshot =
          await productsRef.where('availability', isEqualTo: false).get();
      unAvailableProducts = querySnapshot.docs;
      print(
          'Unavailable products fetched: ${unAvailableProducts.length} found');
      return unAvailableProducts;
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

  Future<void> fetchCombinedProducts(String storeId) async {
    combinedProducts.clear();

    emit(UnavailableLoading());

    final userProducts = await unavailable(storeId);
    productData = combinedProducts;

    if (userProducts != null) {
      for (var userProduct in userProducts) {
        var dynamicData = userProduct.data() as Map<String, dynamic>;
        String productId = dynamicData['productId'];

        try {
          var staticProduct = await fetchStaticProduct(productId);

          // Check if the static product is not null before accessing properties
          if (staticProduct != null && staticProduct.exists) {
            var staticData = staticProduct.data() as Map<String, dynamic>;

            combinedProducts.add({
              'dynamicData': dynamicData,
              'staticData': staticData,
            });
          } else {}
        } catch (e) {
          emit(UnavailableError(
              'Failed to fetch static product for ID $productId: $e'));
        }
      }
      emit(UnavailableLoaded(combinedProducts)); // Emit the combined products
    } else {
      // Emit an empty list if there are no products
    }
  }

  void eliminateProduct({required int index}) {
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(UnavailableLoaded(productData!)); // Emit the updated list
    } else {
      print(
          'Cannot eliminate product: productData is null or index is out of bounds.');
    }
  }
}
