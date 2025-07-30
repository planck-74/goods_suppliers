import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'search_main_store_state.dart';

class SearchMainStoreCubit extends Cubit<SearchMainStoreState> {
  SearchMainStoreCubit() : super(SearchMainStoreInitial());

  Future<void> searchProductsByName(String query, int tabType,
      {required String storeId}) async {
    print(
        'Searching for products with query: $query and tabType: $tabType in store: $storeId');
    emit(SearchMainStoreLoading());
    try {
      Query collection = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      if (tabType == 0) {
        collection = collection.where('isOnSale', isEqualTo: true);
      } else if (tabType == 1) {
        collection = collection.where('availability', isEqualTo: true);
      } else if (tabType == 2) {
        collection = collection.where('availability', isEqualTo: false);
      }

      // For prefix search (case-sensitive, works for English letters)
      if (query.isNotEmpty) {
        String endQuery = '$query\uf8ff';
        collection = collection
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: endQuery);
      }

      final result = await collection.get();
      print('Fetched documents count: \\${result.docs.length}');
      for (var doc in result.docs) {
        print('Doc: \\${doc.data()}');
      }
      var products =
          result.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      // Fallback to in-memory filtering for case-insensitive or Arabic support
      if (query.isNotEmpty) {
        products = products.where((product) {
          final name = (product['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
        print('Filtered by name, count: \\${products.length}');
      }

      emit(SearchMainStoreLoaded(products));
      print('Final products sent to UI: $products');
    } catch (e) {
      emit(SearchMainStoreError(e.toString()));
    }
  }
}
