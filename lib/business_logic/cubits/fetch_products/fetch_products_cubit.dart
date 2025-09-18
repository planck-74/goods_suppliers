import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/fetch_products/fetch_products_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/product_model.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  List<Product> products = [];
  final firestore = FirebaseFirestore.instance;

  Future<void> fetchProducts() async {
    try {
      // جيب المنتجات من الـ subcollection
      final querySnapshot = await firestore
          .collection('stores')
          .doc(storeId)
          .collection('products') // افتراض إن المنتجات في subcollection
          .get();

      // حول الـ docs لـ Product objects
      products = querySnapshot.docs
          .map((doc) => Product.fromMap({
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      emit(ProductsError('حدث خطأ في جلب البيانات'));
    }
  }
}
