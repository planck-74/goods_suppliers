import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/search_main_store_cubit/search_main_store_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_listview_builder_unavailable.dart';
import 'package:goods/presentation/sheets/sheet_classification_available.dart';
import 'package:goods/presentation/skeletons/available_card_skeleton.dart';

class UnAvailable extends StatefulWidget {
  const UnAvailable({super.key});

  @override
  State<UnAvailable> createState() => _AvailableState();
}

class _AvailableState extends State<UnAvailable> {
  // Track current filter state for this tab
  String? _currentFilterType;
  String? _currentFilterValue;
  
  @override
  void initState() {
    super.initState();
    // Load unAvailable products using the search cubit's existing data
    // Tab index 1 represents the UnAvailable products tab
    _loadAvailableProducts();
  }

  /// Load unAvailable products from the search cubit
  /// This method leverages the already-fetched data instead of making new requests
  void _loadAvailableProducts() {
    final searchCubit = context.read<SearchMainStoreCubit>();
    
    // Check if data is already loaded in the search cubit
    if (searchCubit.isDataLoaded) {
      // Data is unAvailable, get unAvailable products (tab index 1)
      searchCubit.getProductsByTabType(2);
    } else {
      // Data not loaded yet, fetch all products first
      // This should typically be done in your splash screen or main store screen
      searchCubit.fetchAllStoreProducts(storeId);
    }
  }

  /// Apply classification filter using search cubit's local data
  /// This provides instant filtering without network requests
  void _applyClassificationFilter(String filterType, String value) {
    
    // Store current filter state for reset functionality
    _currentFilterType = filterType;
    _currentFilterValue = value;
    
    // Use the search cubit's filtering capability
    // We'll need to extend SearchMainStoreCubit to support classification filtering
    context.read<SearchMainStoreCubit>().filterProductsByClassification(
      filterType: filterType,
      filterValue: value,
      tabType: 2, // UnAvailable products tab
    );
  }

  /// Clear all filters and show all unAvailable products
  /// This resets the view to show all unAvailable products without any filters
  void _clearAllFilters() {
    
    // Clear filter state
    _currentFilterType = null;
    _currentFilterValue = null;
    
    // Get all unAvailable products without any filters
    context.read<SearchMainStoreCubit>().getProductsByTabType(2);
  }

  /// Handle classification selection and auto-close sheet
  /// This method is called when user selects a classification option
  void _onClassificationSelected(String filterType, String value) {
    // Apply the selected filter
    _applyClassificationFilter(filterType, value);
    
    // Close the classification sheet automatically
    Navigator.of(context).pop();
  }

  /// Handle refresh action - reload data from Firebase
  Future<void> _refreshData() async {
    
    // Refresh all data in search cubit
    await context.read<SearchMainStoreCubit>().refreshProductsData(storeId);
    
    // Reapply current filter if one exists, otherwise show all unAvailable products
    if (_currentFilterType != null && _currentFilterValue != null) {
      _applyClassificationFilter(_currentFilterType!, _currentFilterValue!);
    } else {
      _loadAvailableProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header container with classification and reset buttons
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Classification button - opens bottom sheet
                      customOutlinedButton(
                        onPressed: () => _showClassificationSheet(),
                        width: 80,
                        height: 25,
                        context: context,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '  تصنيف',
                              style: TextStyle(color: darkBlueColor),
                            ),
                            const SizedBox(width: 5),
                            // Show indicator if filter is applied
                            Icon(
                              _currentFilterType != null 
                                ? Icons.filter_alt 
                                : Icons.filter_alt_outlined,
                              size: 12,
                              color: _currentFilterType != null 
                                ? Colors.orange 
                                : primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      
                      // Reset button - shows applied filter count
                      customOutlinedButton(
                        onPressed: _clearAllFilters,
                        width: _currentFilterType != null ? 60 : 45,
                        height: 25,
                        context: context,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restart_alt,
                              color: _currentFilterType != null 
                                ? Colors.orange 
                                : primaryColor,
                              size: 16,
                            ),
                            if (_currentFilterType != null) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Show current filter info if applied
          if (_currentFilterType != null && _currentFilterValue != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'مُرشح حسب: $_currentFilterType = $_currentFilterValue',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'إزالة',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 6),
          
          // Main content area - using SearchMainStoreCubit instead of AvailableCubit
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              onRefresh: _refreshData,
              child: BlocBuilder<SearchMainStoreCubit, SearchMainStoreState>(
                builder: (context, state) {
                  // Handle loading state
                  if (state is SearchMainStoreLoading) {
                    return const AvailableCardSkeletonList();
                  }
                  
                  // Handle loaded state
                  else if (state is SearchMainStoreLoaded) {
                    final availableProducts = state.products;
                    
                    // Show empty state if no products found
                    if (availableProducts.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    // Show products list
                    return UnAvailableProductsList(
                      data: availableProducts,
                      storeId: storeId,
                      isLoadingMore: false, // No pagination needed
                    );
                  }
                  
                  // Handle error state
                  else if (state is SearchMainStoreError) {
                    return _buildErrorState(state.message);
                  }
                  
                  // Handle initial state - show message or load data
                  else if (state is SearchMainStoreInitial) {
                    final searchCubit = context.read<SearchMainStoreCubit>();
                    if (!searchCubit.isDataLoaded) {
                      return _buildDataNotLoadedState();
                    }
                    
                    // Data is loaded but no action taken yet
                    return _buildInitialState();
                  }
                  
                  // Default fallback
                  return _buildInitialState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show classification bottom sheet with auto-close functionality
  void _showClassificationSheet() {
    showModalBottomSheet(
      backgroundColor: whiteColor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SheetClassificationAvailable(
onClassificationSelected: _onClassificationSelected,
        // Pass current filter state to show selected options
        currentFilterType: _currentFilterType,
        currentFilterValue: _currentFilterValue,
        // Pass the tab type (1 for UnAvailable products)
        tabType: 2,

        );
      },
    );
  }

  /// Build empty state when no products match current filter
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _currentFilterType != null 
              ? Icons.filter_alt_off 
              : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _currentFilterType != null 
              ? 'لا توجد منتجات تطابق الفلتر المحدد'
              : 'لا توجد منتجات متاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          if (_currentFilterType != null) ...[
            const SizedBox(height: 8),
            Text(
              'جرب إزالة الفلتر أو اختر تصنيف آخر',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearAllFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlueColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('إزالة الفلتر'),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error state with retry option
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAvailableProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// Build state when data is not loaded yet
  Widget _buildDataNotLoadedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'يرجى الانتظار حتى يتم تحميل جميع المنتجات',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: darkBlueColor),
        ],
      ),
    );
  }

  /// Build initial state before any action
  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'المنتجات المتاحة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'اضغط على زر التصنيف لعرض المنتجات',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadAvailableProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('عرض جميع المنتجات المتاحة'),
          ),
        ],
      ),
    );
  }
}