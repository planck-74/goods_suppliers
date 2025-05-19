import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/available/available_state.dart';

class AvailableCubit extends Cubit<AvailableState> {
  AvailableCubit() : super(AvailableInitial());

  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>> filteredProducts = [];
  List<QueryDocumentSnapshot> AvailableProducts = [];

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

  // available products
  Future<List<QueryDocumentSnapshot<Object?>>?> available(
      String storeId) async {
    AvailableProducts = [];

    if (storeId.isNotEmpty) {
      CollectionReference productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      QuerySnapshot querySnapshot =
          await productsRef.where('availability', isEqualTo: true).get();
      AvailableProducts = querySnapshot.docs;
      print('available products fetched: ${AvailableProducts.length} found');
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
}
