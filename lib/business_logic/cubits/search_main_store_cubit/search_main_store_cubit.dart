import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'search_main_store_state.dart';

class SearchMainStoreCubit extends Cubit<SearchMainStoreState> {
  SearchMainStoreCubit() : super(SearchMainStoreInitial());
  
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsStreamSubscription;
  
  List<Map<String, dynamic>> _allProducts = [];
  Timer? _searchTimer;
  bool _isDataLoaded = false;
  
  // حفظ آخر query/filter للتطبيق التلقائي عند التحديث
  String? _lastSearchQuery;
  int? _lastTabType;
  String? _lastFilterType;
  String? _lastFilterValue;
  
  List<Map<String, dynamic>> get _offerProducts => 
      _allProducts.where((p) => p['isOnSale'] == true).toList();
  
  List<Map<String, dynamic>> get _availableProducts => 
      _allProducts.where((p) => p['availability'] == true).toList();
  
  List<Map<String, dynamic>> get _unavailableProducts => 
      _allProducts.where((p) => p['availability'] == false).toList();
  
  /// جلب المنتجات مع Stream
  Future<void> fetchAllStoreProducts(String storeId) async {
    try {
      emit(SearchMainStoreLoading());
      
      await _productsStreamSubscription?.cancel();
      
      final collection = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      _productsStreamSubscription = collection.snapshots().listen(
        (snapshot) {
          _allProducts = snapshot.docs.map((doc) {
            final data = doc.data();
            data['productId'] = doc.id;
            return data;
          }).toList();
          
          _isDataLoaded = true;
          
          print('🔄 Stream update: ${_allProducts.length} منتج');
          
          // ✅ إعادة تطبيق آخر filter/search تلقائياً
          _reapplyLastView();
        },
        onError: (error) {
          emit(SearchMainStoreError('فشل في تحميل المنتجات: $error'));
        },
      );
      
    } catch (e) {
      emit(SearchMainStoreError('فشل في تحميل المنتجات: $e'));
    }
  }
  
  /// إعادة تطبيق آخر view (search/filter) بعد تحديث Stream
  void _reapplyLastView() {
    if (!_isDataLoaded) return;
    
    // إذا كان هناك filter نشط
    if (_lastFilterType != null && _lastFilterValue != null && _lastTabType != null) {
      filterProductsByClassification(
        filterType: _lastFilterType!,
        filterValue: _lastFilterValue!,
        tabType: _lastTabType!,
        silently: true, // ✅ بدون emit loading
      );
    }
    // إذا كان هناك search نشط
    else if (_lastSearchQuery != null && _lastTabType != null) {
      _performLocalSearch(_lastSearchQuery!, _lastTabType!, silently: true);
    }
    // إذا كان هناك tab محدد فقط
    else if (_lastTabType != null) {
      getProductsByTabType(_lastTabType!, silently: true);
    }
  }
  
  Future<void> searchProductsByName(String query, int tabType, {String? storeId}) async {
    _searchTimer?.cancel();
    
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performLocalSearch(query, tabType);
    });
  }
  
  void _performLocalSearch(String query, int tabType, {bool silently = false}) {
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }
    
    // حفظ آخر query
    _lastSearchQuery = query.trim().isEmpty ? null : query;
    _lastTabType = tabType;
    _lastFilterType = null;
    _lastFilterValue = null;
    
    try {
      if (!silently) emit(SearchMainStoreLoading());
      
      List<Map<String, dynamic>> products;
      switch (tabType) {
        case 0:
          products = _offerProducts;
          break;
        case 1:
          products = _availableProducts;
          break;
        case 2:
          products = _unavailableProducts;
          break;
        default:
          products = _allProducts;
      }
      
      if (query.trim().isNotEmpty) {
        products = _performSmartSearch(products, query);
      }
      
      emit(SearchMainStoreLoaded(products)); // ✅ timestamp جديد في كل مرة
      
    } catch (e) {
      emit(SearchMainStoreError('حدث خطأ في البحث: $e'));
    }
  }
  
  void getProductsByTabType(int tabType, {bool silently = false}) {
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }
    
    // حفظ آخر tab
    _lastTabType = tabType;
    _lastSearchQuery = null;
    _lastFilterType = null;
    _lastFilterValue = null;
    
    try {
      List<Map<String, dynamic>> products;
      switch (tabType) {
        case 0:
          products = _offerProducts;
          break;
        case 1:
          products = _availableProducts;
          break;
        case 2:
          products = _unavailableProducts;
          break;
        default:
          products = _allProducts;
      }
      
      emit(SearchMainStoreLoaded(products));
    } catch (e) {
      emit(SearchMainStoreError('حدث خطأ في تحميل المنتجات: $e'));
    }
  }
  
  List<Map<String, dynamic>> _performSmartSearch(
      List<Map<String, dynamic>> products, String query) {
    final normalizedQuery = _normalizeArabicText(query.toLowerCase().trim());
    
    if (normalizedQuery.isEmpty) return products;
    
    List<Map<String, dynamic>> searchResults = products.where((product) {
      final name = (product['name'] ?? '').toString();
      final normalizedName = _normalizeArabicText(name.toLowerCase());
      
      if (normalizedName.contains(normalizedQuery)) return true;
      
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty);
      final nameWords = normalizedName.split(' ');
      
      return queryWords.every((queryWord) =>
          nameWords.any((nameWord) => nameWord.contains(queryWord))
      );
    }).toList();
    
    searchResults.sort((a, b) => _calculateRelevanceScore(b, normalizedQuery)
        .compareTo(_calculateRelevanceScore(a, normalizedQuery)));
    
    return searchResults;
  }
  
  String _normalizeArabicText(String text) {
    return text
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ء', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  int _calculateRelevanceScore(Map<String, dynamic> product, String query) {
    final name = _normalizeArabicText((product['name'] ?? '').toString().toLowerCase());
    int score = 0;
    
    if (name.startsWith(query)) score += 100;
    if (name == query) score += 200;
    
    final matches = query.allMatches(name);
    score += matches.length * 10;
    
    final words = name.split(' ');
    for (String word in words) {
      if (word.startsWith(query)) score += 50;
      if (word == query) score += 75;
    }
    
    return score;
  }
  
  Future<void> refreshProductsData(String storeId) async {
    print('🔄 Stream active - data updates automatically');
    
    if (_productsStreamSubscription == null || _productsStreamSubscription!.isPaused) {
      await fetchAllStoreProducts(storeId);
    }
  }
  
  void updateProductLocally(String productId, Map<String, dynamic> updatedData) {
    final index = _allProducts.indexWhere((p) => p['productId'] == productId);
    if (index != -1) {
      _allProducts[index] = {..._allProducts[index], ...updatedData};
      _reapplyLastView(); // ✅ إعادة عرض البيانات المحدثة
    }
  }
  
  void addProductLocally(Map<String, dynamic> product) {
    _allProducts.add(product);
    _reapplyLastView();
  }
  
  void removeProductLocally(String productId) {
    _allProducts.removeWhere((p) => p['productId'] == productId);
    _reapplyLastView();
  }
  
  Map<String, int> getProductCounts() {
    if (!_isDataLoaded) {
      return {'offers': 0, 'available': 0, 'unavailable': 0, 'total': 0};
    }
    
    return {
      'offers': _offerProducts.length,
      'available': _availableProducts.length,
      'unavailable': _unavailableProducts.length,
      'total': _allProducts.length,
    };
  }
  
  bool get isDataLoaded => _isDataLoaded;
  int get totalProductsCount => _allProducts.length;
  
  void clearAllData() {
    _allProducts.clear();
    _isDataLoaded = false;
    _lastSearchQuery = null;
    _lastTabType = null;
    _lastFilterType = null;
    _lastFilterValue = null;
    emit(SearchMainStoreInitial());
  }
  
  @override
  Future<void> close() async {
    _searchTimer?.cancel();
    await _productsStreamSubscription?.cancel();
    return super.close();
  }

  void filterProductsByClassification({
    required String filterType,
    required String filterValue,
    required int tabType,
    bool silently = false,
  }) {
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }

    // حفظ آخر filter
    _lastFilterType = filterType;
    _lastFilterValue = filterValue;
    _lastTabType = tabType;
    _lastSearchQuery = null;

    try {
      if (!silently) emit(SearchMainStoreLoading());
      
      List<Map<String, dynamic>> tabProducts;
      switch (tabType) {
        case 0:
          tabProducts = _offerProducts;
          break;
        case 1:
          tabProducts = _availableProducts;
          break;
        case 2:
          tabProducts = _unavailableProducts;
          break;
        default:
          tabProducts = _allProducts;
      }
      
      List<Map<String, dynamic>> filteredProducts = tabProducts.where((product) {
        final productValue = product[filterType];
        if (productValue == null) return false;
        
        final productValueString = productValue.toString().toLowerCase().trim();
        final filterValueString = filterValue.toLowerCase().trim();
        
        return productValueString == filterValueString || 
               productValueString.contains(filterValueString);
      }).toList();
      
      emit(SearchMainStoreLoaded(filteredProducts));
      
    } catch (e) {
      emit(SearchMainStoreError('حدث خطأ في تطبيق الفلتر: $e'));
    }
  }

  List<String> getUniqueClassificationValues(String classificationType, int tabType) {
    if (!_isDataLoaded) return [];

    try {
      List<Map<String, dynamic>> tabProducts;
      switch (tabType) {
        case 0:
          tabProducts = _offerProducts;
          break;
        case 1:
          tabProducts = _availableProducts;
          break;
        case 2:
          tabProducts = _unavailableProducts;
          break;
        default:
          tabProducts = _allProducts;
      }

      Set<String> uniqueValues = {};
      
      for (var product in tabProducts) {
        final value = product[classificationType];
        if (value != null && value.toString().trim().isNotEmpty) {
          uniqueValues.add(value.toString().trim());
        }
      }

      return uniqueValues.toList()..sort();
      
    } catch (e) {
      return [];
    }
  }

  Map<String, int> getClassificationStats(String classificationType, int tabType) {
    if (!_isDataLoaded) return {};

    try {
      List<Map<String, dynamic>> tabProducts;
      switch (tabType) {
        case 0:
          tabProducts = _offerProducts;
          break;
        case 1:
          tabProducts = _availableProducts;
          break;
        case 2:
          tabProducts = _unavailableProducts;
          break;
        default:
          tabProducts = _allProducts;
      }

      Map<String, int> stats = {};
      
      for (var product in tabProducts) {
        final value = product[classificationType];
        if (value != null && value.toString().trim().isNotEmpty) {
          final valueString = value.toString().trim();
          stats[valueString] = (stats[valueString] ?? 0) + 1;
        }
      }

      return stats;
      
    } catch (e) {
      return {};
    }
  }

  void applyMultipleFilters({
    required Map<String, String> filters,
    required int tabType,
  }) {
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }

    try {
      emit(SearchMainStoreLoading());
      
      List<Map<String, dynamic>> tabProducts;
      switch (tabType) {
        case 0:
          tabProducts = _offerProducts;
          break;
        case 1:
          tabProducts = _availableProducts;
          break;
        case 2:
          tabProducts = _unavailableProducts;
          break;
        default:
          tabProducts = _allProducts;
      }
      
      List<Map<String, dynamic>> filteredProducts = tabProducts.where((product) {
        return filters.entries.every((filterEntry) {
          final filterType = filterEntry.key;
          final filterValue = filterEntry.value;
          final productValue = product[filterType];
          
          if (productValue == null) return false;
          
          final productValueString = productValue.toString().toLowerCase().trim();
          final filterValueString = filterValue.toLowerCase().trim();
          
          return productValueString == filterValueString || 
                 productValueString.contains(filterValueString);
        });
      }).toList();
      
      emit(SearchMainStoreLoaded(filteredProducts));
      
    } catch (e) {
      emit(SearchMainStoreError('حدث خطأ في تطبيق الفلاتر: $e'));
    }
  }

  void searchInFilteredResults(String query, List<Map<String, dynamic>> currentResults) {
    if (query.trim().isEmpty) {
      emit(SearchMainStoreLoaded(currentResults));
      return;
    }

    try {
      emit(SearchMainStoreLoading());
      
      final normalizedQuery = _normalizeArabicText(query.toLowerCase().trim());
      
      List<Map<String, dynamic>> searchResults = currentResults.where((product) {
        final name = (product['name'] ?? '').toString();
        final normalizedName = _normalizeArabicText(name.toLowerCase());
        
        return normalizedName.contains(normalizedQuery);
      }).toList();

      searchResults.sort((a, b) => _calculateRelevanceScore(b, normalizedQuery)
          .compareTo(_calculateRelevanceScore(a, normalizedQuery)));
      
      emit(SearchMainStoreLoaded(searchResults));
      
    } catch (e) {
      emit(SearchMainStoreError('حدث خطأ في البحث: $e'));
    }
  }

  void clearAllFiltersForTab(int tabType) {
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }

    getProductsByTabType(tabType);
  }

  List<String> getAvailableFilterTypes(int tabType) {
    if (!_isDataLoaded) return [];

    try {
      List<Map<String, dynamic>> tabProducts;
      switch (tabType) {
        case 0:
          tabProducts = _offerProducts;
          break;
        case 1:
          tabProducts = _availableProducts;
          break;
        case 2:
          tabProducts = _unavailableProducts;
          break;
        default:
          tabProducts = _allProducts;
      }

      if (tabProducts.isEmpty) return [];

      Set<String> filterTypes = {};
      int sampleSize = tabProducts.length > 10 ? 10 : tabProducts.length;
      
      for (int i = 0; i < sampleSize; i++) {
        filterTypes.addAll(tabProducts[i].keys);
      }

      List<String> excludedFields = [
        'productId', 'createdAt', 'updatedAt', 'availability', 'isOnSale',
        'price', 'offerPrice', 'minOrderQuantity', 'maxOrderQuantity',
        'description', 'images'
      ];
      
      filterTypes.removeWhere((field) => excludedFields.contains(field));
      
      return filterTypes.toList()..sort();
      
    } catch (e) {
      return [];
    }
  }
}