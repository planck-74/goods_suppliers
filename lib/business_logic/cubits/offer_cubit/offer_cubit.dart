import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  OfferCubit() : super(OfferInitial()) {
    loadAdminData(); // تحميل البيانات عند إنشاء الكيوبت تلقائيًا
  }

  List<Map<String, dynamic>>? productData;
  Map<String, dynamic> classification = {};
  Map<String, dynamic> manufacturer = {};
  Map<String, dynamic> package_type = {};
  Map<String, dynamic> package_unit = {};
  Map<String, dynamic> size_unit = {};
  List<Map<String, dynamic>> combinedProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  void filterProducts(String filterType, String value) async {
    filteredProducts.clear();
    emit(OfferLoading());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (var product in combinedProducts) {
      if (product['staticData'][filterType] == value) {
        filteredProducts.add(product);
      }
    }
    emit(OfferLoaded(List.from(filteredProducts)));
  }

  /// دالة لجلب جميع المستندات من مجموعة admin_data
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?>
      fetchAdminData() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('admin_data').get();
    print(snapshot);
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs;
    } else {
      return null;
    }
  }

  /// دالة لتحميل البيانات وتوزيعها على المتغيرات بناءً على الـ document ID
  Future<void> loadAdminData() async {
    emit(OfferLoading()); // تأكيد إن البيانات بتتحمل
    try {
      List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs =
          await fetchAdminData();

      if (docs != null && docs.isNotEmpty) {
        // المرور على كل مستند وتوزيع البيانات بناءً على الـ document ID
        for (var doc in docs) {
          final String docId = doc.id;
          final Map<String, dynamic> data = doc.data();

          if (docId == 'classification') {
            classification = data;
          } else if (docId == 'manufacturer') {
            manufacturer = data;
          } else if (docId == 'package_type') {
            package_type = data;
          } else if (docId == 'package_unit') {
            package_unit = data;
          } else if (docId == 'size_unit') {
            size_unit = data;
          } else if (docId == 'productData') {
            // نفترض هنا إن البيانات الخاصة بالمنتجات محفوظة في مفتاح 'items' داخل المستند
            if (data['items'] != null && data['items'] is List) {
              productData = List<Map<String, dynamic>>.from(
                  data['items'].map((item) => Map<String, dynamic>.from(item)));
            } else {
              productData = [];
            }
          }
        }

        print('✅ البيانات تم تحميلها بنجاح!');
        print(manufacturer);
        emit(OfferLoaded(productData ?? [])); // تحديث الحالة بعد تحميل البيانات
      } else {
        emit(OfferError('❌ لم يتم العثور على بيانات إدارية.'));
      }
    } catch (e) {
      emit(OfferError('❌ خطأ أثناء تحميل البيانات: $e'));
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>?> fetchOnSaleProducts(
      String storeId) async {
    List<QueryDocumentSnapshot> onSaleProducts = [];

    if (storeId.isNotEmpty) {
      CollectionReference productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      // Modify the query to filter by 'isOnSale'
      QuerySnapshot querySnapshot =
          await productsRef.where('isOnSale', isEqualTo: true).get();

      onSaleProducts = querySnapshot.docs;

      return onSaleProducts;
    }

    return null;
  }

  Future<DocumentSnapshot?> fetchStaticProduct(String productId) async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection('products');

    final QuerySnapshot snapshot =
        await ref.where('productId', isEqualTo: productId).get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      return null;
    }
  }

  Future<void> fetchCombinedOnSaleProducts(String storeId) async {
    emit(OfferLoading());

    try {
      final userProducts = await fetchOnSaleProducts(storeId);

      // 🔹 Reset `combinedProducts` before adding new products
      combinedProducts.clear();

      if (userProducts != null) {
        for (var userProduct in userProducts) {
          var dynamicData = userProduct.data() as Map<String, dynamic>;
          String productId = dynamicData['productId'];

          try {
            var staticProduct = await fetchStaticProduct(productId);

            if (staticProduct != null && staticProduct.exists) {
              var staticData = staticProduct.data() as Map<String, dynamic>;

              combinedProducts.add({
                'dynamicData': dynamicData,
                'staticData': staticData,
              });
            }
          } catch (e) {
            emit(OfferError(
                'Failed to fetch static product for ID $productId: $e'));
          }
        }

        // 🔹 Ensure we send the correct data: either filtered or all products
        emit(OfferLoaded(combinedProducts));
      } else {
        emit(OfferError('No on-sale products found.'));
      }
    } catch (e) {
      emit(OfferError('Error fetching on-sale products: $e'));
    }
  }

  void eliminateProduct({required int index}) {
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(OfferLoaded(productData!));
    } else {}
  }
}
