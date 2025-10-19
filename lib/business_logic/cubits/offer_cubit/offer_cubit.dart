import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class OfferCubit extends Cubit<OfferState> {
  OfferCubit() : super(OfferInitial()) {
    loadAdminData();
  }

  // StreamSubscriptions لإدارة الاشتراكات
  StreamSubscription<QuerySnapshot>? _productsStreamSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _adminDataSubscription;

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

  /// دالة لتحميل البيانات الإدارية باستخدام Stream للتحديث اللحظي
  Future<void> loadAdminData() async {
    emit(OfferLoading());
    
    try {
      // إلغاء الاشتراك السابق إن وجد
      await _adminDataSubscription?.cancel();
      
      // الاشتراك في stream البيانات الإدارية
      _adminDataSubscription = FirebaseFirestore.instance
          .collection('admin_data')
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _processAdminData(snapshot.docs);
          } else {
            emit(OfferError('❌ لم يتم العثور على بيانات إدارية.'));
          }
        },
        onError: (error) {
          emit(OfferError('❌ خطأ أثناء تحميل البيانات: $error'));
        },
      );
    } catch (e) {
      emit(OfferError('❌ خطأ أثناء تحميل البيانات: $e'));
    }
  }

  /// معالجة البيانات الإدارية
  void _processAdminData(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
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
        if (data['items'] != null && data['items'] is List) {
          productData = List<Map<String, dynamic>>.from(
              data['items'].map((item) => Map<String, dynamic>.from(item)));
        } else {
          productData = [];
        }
      }
    }

    print(manufacturer);
    emit(OfferLoaded(productData ?? []));
  }

  /// جلب منتجات العروض باستخدام Stream (بدون pagination للتبسيط)
  /// ملاحظة: Stream مع pagination معقد، لذا نستخدم stream بدون pagination
  /// أو يمكن استخدام pagination مع pull-to-refresh
  Future<void> fetchInitialOnSaleProducts() async {
    onSaleProducts = [];
    pagedProducts = [];
    lastDocument = null;
    hasMore = true;
    emit(OfferLoading());
    
    await _setupOnSaleProductsStream();
  }

  /// إعداد Stream للمنتجات المعروضة (isOnSale = true)
  Future<void> _setupOnSaleProductsStream() async {
    if (storeId.isEmpty) {
      emit(OfferError('Store ID is empty'));
      return;
    }

    try {
      // إلغاء الاشتراك السابق
      await _productsStreamSubscription?.cancel();

      // الاشتراك في stream المنتجات
      _productsStreamSubscription = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products')
          .where('isOnSale', isEqualTo: true)
          .limit(100) // حد أقصى معقول للمنتجات المعروضة
          .snapshots()
          .listen(
        (querySnapshot) {
          print('🔄 OfferCubit: Stream update - ${querySnapshot.docs.length} منتج');
          
          if (querySnapshot.docs.isNotEmpty) {
            onSaleProducts = querySnapshot.docs;
            pagedProducts = querySnapshot.docs
                .map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['productId'] = doc.id; // ✅ إضافة productId
                  return data;
                })
                .toList();
            // ✅ emit جديد في كل مرة (بفضل timestamp في OfferLoaded)
            emit(OfferLoaded(List.from(pagedProducts)));
          } else {
            pagedProducts = [];
            emit(OfferLoaded([]));
          }
        },
        onError: (error) {
          emit(OfferError('خطأ في تحميل المنتجات: $error'));
        },
      );
    } catch (e) {
      emit(OfferError('خطأ في إعداد Stream: $e'));
    }
  }

  /// نسخة محسنة مع pagination (اختياري - أكثر تعقيداً)
  /// يمكن استخدامها إذا كان عدد المنتجات كبير جداً
  Future<void> fetchNextOnSaleProductsPage() async {
    if (!hasMore || isLoadingMore) return;
    
    // مع Streams، pagination يتطلب نهج مختلف
    // يمكن الاحتفاظ بـ pagination للتحميل الأولي فقط
    // والاعتماد على stream للتحديثات
    
    // للبساطة: نترك هذا فارغ أو نستخدم نفس منطق stream
    print('Pagination with streams - using stream updates instead');
  }

  void eliminateProduct({required int index}) {
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(OfferLoaded(productData!));
    }
  }

  /// إلغاء جميع الاشتراكات عند إغلاق الـ Cubit
  @override
  Future<void> close() async {
    await _productsStreamSubscription?.cancel();
    await _adminDataSubscription?.cancel();
    return super.close();
  }
}