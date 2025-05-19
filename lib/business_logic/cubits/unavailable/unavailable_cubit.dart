import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_state.dart';

class UnAvailableCubit extends Cubit<UnAvailableState> {
  UnAvailableCubit() : super(UnavailableInitial());
  List<Map<String, dynamic>> combinedProducts = [];

  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>> filteredProducts = [];
  List<QueryDocumentSnapshot> UnAvailableProducts = [];

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

  // unavailable products
  Future<List<QueryDocumentSnapshot<Object?>>?> UnAvailable(
      String storeId) async {
    UnAvailableProducts = [];

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
