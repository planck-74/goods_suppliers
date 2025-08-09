import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

part 'search_main_store_state.dart';

class SearchMainStoreCubit extends Cubit<SearchMainStoreState> {
  SearchMainStoreCubit() : super(SearchMainStoreInitial());
  
  // Cache للمنتجات لتحسين الأداء
  final Map<String, List<Map<String, dynamic>>> _productsCache = {};
  Timer? _searchTimer;
  
  Future<void> searchProductsByName(String query, int tabType,
      {required String storeId}) async {
    print('Searching for products with query: $query and tabType: $tabType in store: $storeId');
    
    // إلغاء البحث السابق لتجنب الـ race conditions
    _searchTimer?.cancel();
    
    // إضافة debounce للبحث السريع
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query, tabType, storeId);
    });
  }
  
  Future<void> _performSearch(String query, int tabType, String storeId) async {
    emit(SearchMainStoreLoading());
    
    try {
      final cacheKey = '${storeId}_$tabType';
      List<Map<String, dynamic>> products;
      
      // تحقق من الكاش أولاً
      if (_productsCache.containsKey(cacheKey)) {
        products = _productsCache[cacheKey]!;
        print('Using cached data, count: ${products.length}');
      } else {
        // جلب جميع المنتجات حسب النوع وحفظها في الكاش
        products = await _fetchAllProductsByType(storeId, tabType);
        _productsCache[cacheKey] = products;
        print('Fetched fresh data, count: ${products.length}');
      }
      
      // تطبيق البحث الذكي
      if (query.isNotEmpty) {
        products = _performSmartSearch(products, query);
        print('Filtered by search query, count: ${products.length}');
      }
      
      emit(SearchMainStoreLoaded(products));
      print('Final products sent to UI: ${products.length} products');
    } catch (e) {
      print('Search error: $e');
      emit(SearchMainStoreError(e.toString()));
    }
  }
  
  Future<List<Map<String, dynamic>>> _fetchAllProductsByType(String storeId, int tabType) async {
    Query collection = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products');

    // تطبيق الفلاتر حسب نوع التاب
    switch (tabType) {
      case 0: // Offers
        collection = collection.where('isOnSale', isEqualTo: true);
        break;
      case 1: // Available
        collection = collection.where('availability', isEqualTo: true);
        break;
      case 2: // Unavailable
        collection = collection.where('availability', isEqualTo: false);
        break;
    }

    final result = await collection.get();
    return result.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['productId'] = doc.id; // إضافة الـ ID للمنتج
      return data;
    }).toList();
  }
  
  List<Map<String, dynamic>> _performSmartSearch(List<Map<String, dynamic>> products, String query) {
    final normalizedQuery = _normalizeArabicText(query.toLowerCase().trim());
    
    return products.where((product) {
      final name = (product['name'] ?? '').toString();
      final normalizedName = _normalizeArabicText(name.toLowerCase());
      
      // البحث الأساسي - يحتوي على النص
      if (normalizedName.contains(normalizedQuery)) {
        return true;
      }
      
      // البحث في الكلمات المنفصلة
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty);
      final nameWords = normalizedName.split(' ');
      
      // التحقق من وجود كل كلمة في النص
      return queryWords.every((queryWord) =>
          nameWords.any((nameWord) => nameWord.contains(queryWord))
      );
    }).toList()
    ..sort((a, b) => _calculateRelevanceScore(b, normalizedQuery)
        .compareTo(_calculateRelevanceScore(a, normalizedQuery)));
  }
  
  // تطبيع النصوص العربية لبحث أفضل
  String _normalizeArabicText(String text) {
    return text
        // توحيد الألف
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ء', 'ا')
        // توحيد التاء المربوطة والهاء
        .replaceAll('ة', 'ه')
        // إزالة التشكيل
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        // توحيد المسافات
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  // حساب نقاط الصلة للترتيب
  int _calculateRelevanceScore(Map<String, dynamic> product, String query) {
    final name = _normalizeArabicText((product['name'] ?? '').toString().toLowerCase());
    int score = 0;
    
    // نقاط إضافية إذا بدأ الاسم بنفس النص
    if (name.startsWith(query)) score += 100;
    
    // نقاط إضافية للتطابق التام
    if (name == query) score += 200;
    
    // نقاط لعدد مرات ظهور النص
    score += query.allMatches(name).length * 10;
    
    return score;
  }
  
  // مسح الكاش عند تغيير البيانات
  void clearCache() {
    _productsCache.clear();
  }
  
  // مسح كاش محدد
  void clearCacheForStore(String storeId) {
    _productsCache.removeWhere((key, value) => key.startsWith(storeId));
  }
  
  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}