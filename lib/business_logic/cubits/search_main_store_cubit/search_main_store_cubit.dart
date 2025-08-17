import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

part 'search_main_store_state.dart';

class SearchMainStoreCubit extends Cubit<SearchMainStoreState> {
  SearchMainStoreCubit() : super(SearchMainStoreInitial());
  
  // Local storage for all products - fetched once at app start
  List<Map<String, dynamic>> _allProducts = [];
  Timer? _searchTimer;
  bool _isDataLoaded = false;
  
  // Getters for different product types
  List<Map<String, dynamic>> get _offerProducts => 
      _allProducts.where((p) => p['isOnSale'] == true).toList();
  
  List<Map<String, dynamic>> get _availableProducts => 
      _allProducts.where((p) => p['availability'] == true).toList();
  
  List<Map<String, dynamic>> get _unavailableProducts => 
      _allProducts.where((p) => p['availability'] == false).toList();
  
  // Fetch all products once (call this in splash screen)
  Future<void> fetchAllStoreProducts(String storeId) async {
    try {
      emit(SearchMainStoreLoading());
      
      final collection = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      final result = await collection.get();
      
      _allProducts = result.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id;
        return data;
      }).toList();
      
      _isDataLoaded = true;
      
      emit(SearchMainStoreInitial()); // Return to initial state after loading
    } catch (e) {
      emit(SearchMainStoreError('فشل في تحميل المنتجات: $e'));
    }
  }
  
  // Search products locally by name
  Future<void> searchProductsByName(String query, int tabType, {String? storeId}) async {
    // Cancel previous search to avoid race conditions
    _searchTimer?.cancel();
    
    // Add debounce for fast searching
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performLocalSearch(query, tabType);
    });
  }
  
  void _performLocalSearch(String query, int tabType) {
    
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }
    
    try {
      emit(SearchMainStoreLoading());
      
      // Get products based on tab type
      List<Map<String, dynamic>> products;
      switch (tabType) {
        case 0: // Offers
          products = _offerProducts;
          break;
        case 1: // Available
          products = _availableProducts;
          break;
        case 2: // Unavailable
          products = _unavailableProducts;
          break;
        default:
          products = _allProducts;
      }
      
      
      // Apply search filter if query is not empty
      // If query is empty, show all products for the current tab
      if (query.trim().isNotEmpty) {
        products = _performSmartSearch(products, query);
      } else {
      }
      
      emit(SearchMainStoreLoaded(products));
      
    } catch (e) {
      emit(SearchMainStoreError('حدث خطأ في البحث: $e'));
    }
  }
  
  // Get products by tab type without search (for initial loading)
  void getProductsByTabType(int tabType) {
    if (!_isDataLoaded) {
      emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
      return;
    }
    
    try {
      List<Map<String, dynamic>> products;
      switch (tabType) {
        case 0: // Offers
          products = _offerProducts;
          break;
        case 1: // Available
          products = _availableProducts;
          break;
        case 2: // Unavailable
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
  
  // Smart search implementation
  List<Map<String, dynamic>> _performSmartSearch(
      List<Map<String, dynamic>> products, String query) {
    final normalizedQuery = _normalizeArabicText(query.toLowerCase().trim());
    
    if (normalizedQuery.isEmpty) {
      return products;
    }
    
    List<Map<String, dynamic>> searchResults = products.where((product) {
      final name = (product['name'] ?? '').toString();
      final normalizedName = _normalizeArabicText(name.toLowerCase());
      
      // Basic search - contains text
      if (normalizedName.contains(normalizedQuery)) {
        return true;
      }
      
      // Search in separate words
      final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty);
      final nameWords = normalizedName.split(' ');
      
      // Check if all query words exist in the name
      return queryWords.every((queryWord) =>
          nameWords.any((nameWord) => nameWord.contains(queryWord))
      );
    }).toList();
    
    // Sort by relevance score
    searchResults.sort((a, b) => _calculateRelevanceScore(b, normalizedQuery)
        .compareTo(_calculateRelevanceScore(a, normalizedQuery)));
    
    return searchResults;
  }
  
  // Normalize Arabic text for better searching
  String _normalizeArabicText(String text) {
    return text
        // Normalize Alef variations
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ء', 'ا')
        // Normalize Taa Marboota and Haa
        .replaceAll('ة', 'ه')
        // Remove diacritics
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        // Normalize spaces
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  // Calculate relevance score for sorting
  int _calculateRelevanceScore(Map<String, dynamic> product, String query) {
    final name = _normalizeArabicText((product['name'] ?? '').toString().toLowerCase());
    int score = 0;
    
    // Extra points if name starts with the same text
    if (name.startsWith(query)) score += 100;
    
    // Extra points for exact match
    if (name == query) score += 200;
    
    // Points for number of occurrences
    final matches = query.allMatches(name);
    score += matches.length * 10;
    
    // Points for word boundary matches
    final words = name.split(' ');
    for (String word in words) {
      if (word.startsWith(query)) score += 50;
      if (word == query) score += 75;
    }
    
    return score;
  }
  
  // Refresh products data (call when products are updated)
  Future<void> refreshProductsData(String storeId) async {
    _isDataLoaded = false;
    _allProducts.clear();
    await fetchAllStoreProducts(storeId);
  }
  
  // Update a specific product locally (for real-time updates)
  void updateProductLocally(String productId, Map<String, dynamic> updatedData) {
    final index = _allProducts.indexWhere((p) => p['productId'] == productId);
    if (index != -1) {
      _allProducts[index] = {..._allProducts[index], ...updatedData};
    }
  }
  
  // Add new product locally
  void addProductLocally(Map<String, dynamic> product) {
    _allProducts.add(product);
  }
  
  // Remove product locally
  void removeProductLocally(String productId) {
    _allProducts.removeWhere((p) => p['productId'] == productId);
  }
  
  // Get total counts for different categories
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
  
  // Check if data is loaded
  bool get isDataLoaded => _isDataLoaded;
  
  // Get all products count
  int get totalProductsCount => _allProducts.length;
  
  // Clear all data
  void clearAllData() {
    _allProducts.clear();
    _isDataLoaded = false;
    emit(SearchMainStoreInitial());
  }
  
  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }

  /// Filter products by classification criteria (category, manufacturer, etc.)
/// This method extends the existing search functionality to support classification filtering
void filterProductsByClassification({
  required String filterType,
  required String filterValue,
  required int tabType,
}) {
  
  if (!_isDataLoaded) {
    emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
    return;
  }

  try {
    emit(SearchMainStoreLoading());
    
    // First get products for the specific tab type
    List<Map<String, dynamic>> tabProducts;
    switch (tabType) {
      case 0: // Offers
        tabProducts = _offerProducts;
        break;
      case 1: // Available
        tabProducts = _availableProducts;
        break;
      case 2: // Unavailable
        tabProducts = _unavailableProducts;
        break;
      default:
        tabProducts = _allProducts;
    }
    
    // Apply classification filter
    List<Map<String, dynamic>> filteredProducts = tabProducts.where((product) {
      final productValue = product[filterType];
      
      // Handle different data types for filtering
      if (productValue == null) return false;
      
      // Convert both values to strings for comparison to handle different data types
      final productValueString = productValue.toString().toLowerCase().trim();
      final filterValueString = filterValue.toLowerCase().trim();
      
      // Support both exact match and contains search
      return productValueString == filterValueString || 
             productValueString.contains(filterValueString);
    }).toList();
    
    emit(SearchMainStoreLoaded(filteredProducts));
    
  } catch (e) {
    emit(SearchMainStoreError('حدث خطأ في تطبيق الفلتر: $e'));
  }
}

/// Get unique values for a specific classification type
/// This method helps populate filter options in the classification sheet
List<String> getUniqueClassificationValues(String classificationType, int tabType) {
  if (!_isDataLoaded) {
    return [];
  }

  try {
    // Get products for the specific tab
    List<Map<String, dynamic>> tabProducts;
    switch (tabType) {
      case 0: // Offers
        tabProducts = _offerProducts;
        break;
      case 1: // Available
        tabProducts = _availableProducts;
        break;
      case 2: // Unavailable
        tabProducts = _unavailableProducts;
        break;
      default:
        tabProducts = _allProducts;
    }

    // Extract unique values for the classification type
    Set<String> uniqueValues = {};
    
    for (var product in tabProducts) {
      final value = product[classificationType];
      if (value != null && value.toString().trim().isNotEmpty) {
        uniqueValues.add(value.toString().trim());
      }
    }

    // Convert to list and sort alphabetically
    List<String> sortedValues = uniqueValues.toList()..sort();
    
    return sortedValues;
    
  } catch (e) {
    return [];
  }
}

/// Get classification statistics for a specific tab
/// This method provides counts for different classification values
Map<String, int> getClassificationStats(String classificationType, int tabType) {
  if (!_isDataLoaded) {
    return {};
  }

  try {
    // Get products for the specific tab
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

    // Count occurrences of each classification value
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

/// Apply multiple filters simultaneously
/// This advanced method allows combining multiple classification criteria
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
    
    // Get base products for tab
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
    
    // Apply all filters
    List<Map<String, dynamic>> filteredProducts = tabProducts.where((product) {
      // Check if product matches all filter criteria
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

/// Search within filtered results
/// This method allows users to search within already filtered classification results
void searchInFilteredResults(String query, List<Map<String, dynamic>> currentResults) {
  if (query.trim().isEmpty) {
    // If search is empty, show current results as-is
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

    // Sort by relevance
    searchResults.sort((a, b) => _calculateRelevanceScore(b, normalizedQuery)
        .compareTo(_calculateRelevanceScore(a, normalizedQuery)));
    
    emit(SearchMainStoreLoaded(searchResults));
    
  } catch (e) {
    emit(SearchMainStoreError('حدث خطأ في البحث: $e'));
  }
}

/// Clear all filters for a specific tab and show all products
/// This method resets the view to show all products without any classification filters
void clearAllFiltersForTab(int tabType) {
  
  if (!_isDataLoaded) {
    emit(SearchMainStoreError('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'));
    return;
  }

  // Simply call the existing method to get all products for the tab
  getProductsByTabType(tabType);
}

/// Get available filter types for a specific tab
/// This method returns the product fields that can be used for filtering
List<String> getAvailableFilterTypes(int tabType) {
  // Add these methods to your existing SearchMainStoreCubit class


  if (!_isDataLoaded) {
    return [];
  }

  try {
    // Get a sample of products to determine available filter fields
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

    // Get all unique field names from the first few products
    Set<String> filterTypes = {};
    int sampleSize = tabProducts.length > 10 ? 10 : tabProducts.length;
    
    for (int i = 0; i < sampleSize; i++) {
      filterTypes.addAll(tabProducts[i].keys);
    }

    // Remove fields that shouldn't be used for filtering
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