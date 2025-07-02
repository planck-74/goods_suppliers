import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';

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
  List<QueryDocumentSnapshot> onSaleProducts = [];
  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> pagedProducts = [];

  void filterProducts(String filterType, String value) async {
    filteredProducts.clear();
    emit(OfferLoading());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    for (var product in onSaleProducts
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList()) {
      if (product[filterType] == value) {
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

        print(manufacturer);
        emit(OfferLoaded(productData ?? [])); // تحديث الحالة بعد تحميل البيانات
      } else {
        emit(OfferError('❌ لم يتم العثور على بيانات إدارية.'));
      }
    } catch (e) {
      emit(OfferError('❌ خطأ أثناء تحميل البيانات: $e'));
    }
  }

  Future<void> fetchInitialOnSaleProducts() async {
    onSaleProducts = [];
    pagedProducts = [];
    lastDocument = null;
    hasMore = true;
    emit(OfferLoading());
    await _fetchOnSaleProductsPage();
  }

  Future<void> fetchNextOnSaleProductsPage() async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    await _fetchOnSaleProductsPage();
    isLoadingMore = false;
  }

  Future<void> _fetchOnSaleProductsPage() async {
    if (storeId.isEmpty) {
      emit(OfferError('Store ID is empty'));
      return;
    }
    CollectionReference productsRef = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products');
    Query query =
        productsRef.where('isOnSale', isEqualTo: true).limit(pageSize);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      onSaleProducts.addAll(querySnapshot.docs);
      pagedProducts.addAll(
          querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      emit(OfferLoaded(List.from(pagedProducts)));
      if (querySnapshot.docs.length < pageSize) {
        hasMore = false;
      }
    } else {
      hasMore = false;
      emit(OfferLoaded(List.from(pagedProducts)));
    }
  }

  void eliminateProduct({required int index}) {
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(OfferLoaded(productData!));
    } else {}
  }
}
