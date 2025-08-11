import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/available/available_state.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_state.dart';

class UnAvailableCubit extends Cubit<UnAvailableState> {
  UnAvailableCubit() : super(UnavailableInitial());

   
  List<Map<String, dynamic>> _allUnAvailableProducts = [];
  
  // Keep track of current filter state
  String? _currentFilterType;
  String? _currentFilterValue;
  
  
  List<Map<String, dynamic>>? productData;
  List<Map<String, dynamic>> filteredProducts = [];
  List<QueryDocumentSnapshot> UnAvailableProducts = [];
   
  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> pagedProducts = [];

   Future<void> fetchAllUnAvailableProducts(String storeId) async {
    try {
      emit(UnavailableLoading());
      print('Fetching all available products for store: $storeId');
      
      if (storeId.isEmpty) {
        emit(UnavailableError('معرف المتجر فارغ'));
        return;
      }

      // Query all available products in one go
      // This is more efficient than pagination for filtering operations
      final productsRef = FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .collection('products');

      final querySnapshot = await productsRef
          .where('availability', isEqualTo: false)
          .get();

      // Convert documents to maps and store locally
      _allUnAvailableProducts = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure productId is available for filtering and updates
        data['productId'] = doc.id;
        return data;
      }).toList();

      print('Successfully loaded ${_allUnAvailableProducts.length} available products');
      
      // Apply current filter if one exists, otherwise show all products
      if (_currentFilterType != null && _currentFilterValue != null) {
        _applyCurrentFilter();
      } else {
        // Emit all products when no filter is applied
        emit(UnavailableLoaded(List.from(_allUnAvailableProducts)));
      }
      
    } catch (e) {
      print('Error fetching all available products: $e');
      emit(UnavailableError('فشل في تحميل المنتجات المتاحة: $e'));
    }
  }


  void filterProducts(String filterType, String value) async {
    print('Applying filter: $filterType = $value');
    
    // Store current filter for reapplication after refresh
    _currentFilterType = filterType;
    _currentFilterValue = value;
    
    // Show loading state briefly for visual feedback
    emit(UnavailableLoading());
    
    // Small delay to show loading state (optional - can be removed for instant filtering)
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    _applyCurrentFilter();
  }

  /// Internal method to apply the current filter to all products
  void _applyCurrentFilter() {
    if (_currentFilterType == null || _currentFilterValue == null) {
      // No filter applied, show all products
      emit(UnavailableLoaded(List.from(_allUnAvailableProducts)));
      return;
    }

    // Filter products based on the current filter criteria
    final filtered = _allUnAvailableProducts.where((product) {
      final productValue = product[_currentFilterType];
      return productValue != null && productValue.toString() == _currentFilterValue;
    }).toList();

    print('Filtered ${_allUnAvailableProducts.length} products to ${filtered.length} products');
    emit(UnavailableLoaded(filtered));
  }

  /// Clear all filters and show all available products
  /// This method is called by the reset button in the UI
  void clearFiltersAndShowAll() {
    print('Clearing all filters and showing all available products');
    
    // Clear current filter state
    _currentFilterType = null;
    _currentFilterValue = null;
    
    // Show all available products
    emit(UnavailableLoaded(List.from(_allUnAvailableProducts)));
  }

  /// Update a specific product locally (for real-time updates without refetching)
  /// This is useful when a product is edited and you want to update the UI immediately
  void updateProductLocally(String productId, Map<String, dynamic> updatedData) {
    final index = _allUnAvailableProducts.indexWhere((p) => p['productId'] == productId);
    if (index != -1) {
      // Update the product in local storage
      _allUnAvailableProducts[index] = {..._allUnAvailableProducts[index], ...updatedData};
      print('Updated product $productId locally');
      
      // Reapply current filter to reflect changes
      _applyCurrentFilter();
    }
  }

  /// Add a new product locally (when a new product is added)
  void addProductLocally(Map<String, dynamic> product) {
    // Only add if the product is available
    if (product['availability'] == false) {
      _allUnAvailableProducts.add(product);
      print('Added new available product locally: ${product['productId']}');
      
      // Reapply current filter to include new product if it matches
      _applyCurrentFilter();
    }
  }

  /// Remove a product locally (when a product becomes unavailable or is deleted)
  void removeProductLocally(String productId) {
    _allUnAvailableProducts.removeWhere((p) => p['productId'] == productId);
    print('Removed product $productId from available products');
    
    // Reapply current filter to reflect changes
    _applyCurrentFilter();
  }

  /// Search available products by name locally
  /// This provides instant search results without network requests
  void searchUnAvailableProducts(String storeId, String query) {
    print('Searching available products with query: "$query"');
    
    if (query.trim().isEmpty) {
      // If search query is empty, apply current filter or show all
      _applyCurrentFilter();
      return;
    }

    emit(UnavailableLoading());

    try {
      final normalizedQuery = _normalizeSearchQuery(query.toLowerCase().trim());
      
      // Filter products based on search query
      final searchResults = _allUnAvailableProducts.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        final normalizedName = _normalizeSearchQuery(name);
        
        // Check if the product name contains the search query
        return normalizedName.contains(normalizedQuery);
      }).toList();

      print('Search found ${searchResults.length} products');
      emit(UnavailableLoaded(searchResults));
      
    } catch (e) {
      print('Search error: $e');
      emit(UnavailableError('حدث خطأ أثناء البحث: $e'));
    }
  }

  /// Helper method to normalize Arabic text for better search results
  String _normalizeSearchQuery(String text) {
    return text
        // Normalize different forms of Alef
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

  /// Get current filter information
  Map<String, String?> getCurrentFilter() {
    return {
      'type': _currentFilterType,
      'value': _currentFilterValue,
    };
  }

  /// Get total count of available products
  int get availableProductsCount => _allUnAvailableProducts.length;

  /// Check if data is loaded
  bool get isDataLoaded => _allUnAvailableProducts.isNotEmpty;

  /// Clear all local data (useful for logout or switching stores)
  void clearAllData() {
    _allUnAvailableProducts.clear();
    _currentFilterType = null;
    _currentFilterValue = null;
    emit(UnavailableInitial());
  }

  // ===============================
  // LEGACY METHODS (Deprecated but kept for backward compatibility)
  // These methods use the old pagination approach and should be avoided
  // ===============================

  @Deprecated('Use fetchAllUnAvailableProducts for better performance and UX')
  Future<void> fetchInitialUnAvailableProducts(String storeId) async {
    // For backward compatibility, call the new method
    await fetchAllUnAvailableProducts(storeId);
  }

  @Deprecated('No longer needed with all-products approach')
  Future<void> fetchNextUnAvailableProductsPage(String storeId) async {
    // This method is no longer needed since we load all products at once
    print('fetchNextUnAvailableProductsPage is deprecated - using all-products approach');
  }

  @Deprecated('No longer needed with all-products approach')
  Future<void> _fetchUnAvailableProductsPage(String storeId) async {
    // This method is no longer needed since we load all products at once
    print('_fetchUnAvailableProductsPage is deprecated - using all-products approach');
  }

  @Deprecated('Use fetchAllUnAvailableProducts/filtering for better performance')
  Future<List<QueryDocumentSnapshot<Object?>>?> available(String storeId) async {
    // For backward compatibility, call the new method and return null
    await fetchAllUnAvailableProducts(storeId);
    return null;
  }

  /// Fetch a single product by ID (still useful for detailed views)
  Future<DocumentSnapshot?> fetchStaticProduct(String productId) async {
    try {
      final ref = FirebaseFirestore.instance.collection('products');
      final snapshot = await ref.where('productId', isEqualTo: productId).get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching static product: $e');
      return null;
    }
  }

  /// Remove a product from the current displayed list (legacy method)
  void eliminateProduct({required int index}) {
    // This method is less useful with the new approach since we work with product IDs
    // But kept for backward compatibility
    if (productData != null && index >= 0 && index < productData!.length) {
      productData!.removeAt(index);
      emit(UnavailableLoaded(productData!));
    } else {
      print('Cannot eliminate product: productData is null or index is out of bounds.');
    }
  }
}