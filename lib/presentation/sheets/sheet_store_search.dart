import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/search_main_store_cubit/search_main_store_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/cards/card_available.dart';
import 'package:goods/presentation/cards/card_offer.dart';
import 'package:goods/presentation/cards/card_unavailable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class StoreSearchSheet extends StatefulWidget {
  final ValueNotifier<int> selectedTabIndexNotifier;
  const StoreSearchSheet({super.key, required this.selectedTabIndexNotifier});

  @override
  State<StoreSearchSheet> createState() => StoreSearchSheetState();
}

class StoreSearchSheetState extends State<StoreSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late int _currentTabIndex;
  Timer? _debounceTimer;

  // Bulk edit functionality
  bool _isBulkEditMode = false;
  final Set<String> _selectedProductIds = {};
  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.selectedTabIndexNotifier.value;
    widget.selectedTabIndexNotifier.addListener(_onTabChanged);

    // Load initial products for the current tab
    _loadInitialProducts();
  }

  void _loadInitialProducts() {
    final cubit = context.read<SearchMainStoreCubit>();
    if (cubit.isDataLoaded) {
      // If data is already loaded, perform search (which will show all products if query is empty)
      _performSearch();
    } else {
      // If data is not loaded, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('البيانات غير محملة. يرجى إعادة تشغيل التطبيق.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {
        _currentTabIndex = widget.selectedTabIndexNotifier.value;
        _selectedProductIds.clear();
        _isBulkEditMode = false;
      });

      _performSearch();
    }
  }

  void _performSearch() {

    context.read<SearchMainStoreCubit>().searchProductsByName(
          _searchQuery,
          _currentTabIndex,
          storeId:
              storeId, // This parameter is optional now but kept for compatibility
        );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Search with the new query (empty query will show all products for the tab)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });

    // Perform search with empty query to show all products for current tab
    _performSearch();
  }

  void _toggleBulkEditMode() {
    setState(() {
      _isBulkEditMode = !_isBulkEditMode;
      if (!_isBulkEditMode) {
        _selectedProductIds.clear();
      }
    });
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _selectAllProducts() {
    setState(() {
      _selectedProductIds.clear();
      _selectedProductIds
          .addAll(_allProducts.map((p) => p['productId'].toString()));
    });
  }

  void _clearAllSelections() {
    setState(() {
      _selectedProductIds.clear();
    });
  }

  void _showBulkEditDialog() {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار منتج واحد على الأقل')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => BulkEditDialog(
        selectedProductIds: _selectedProductIds,
        currentTabIndex: _currentTabIndex,
        onEditComplete: () {
          setState(() {
            _selectedProductIds.clear();
            _isBulkEditMode = false;
          });

          // Refresh the local data and reload current view
          context
              .read<SearchMainStoreCubit>()
              .refreshProductsData(storeId)
              .then((_) {
            // Always perform search to refresh the current view
            _performSearch();
          });
        },
      ),
    );
  }

  // Show data loading status
  void _showDataStatus() {
    final cubit = context.read<SearchMainStoreCubit>();
    final counts = cubit.getProductCounts();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حالة البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إجمالي المنتجات: ${counts['total']}'),
            Text('المنتجات المتاحة: ${counts['available']}'),
            Text('العروض: ${counts['offers']}'),
            Text('المنتجات غير المتاحة: ${counts['unavailable']}'),
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          if (!cubit.isDataLoaded)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.fetchAllStoreProducts(storeId);
              },
              child: const Text('إعادة تحميل البيانات'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.selectedTabIndexNotifier.removeListener(_onTabChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'ابحث في جميع المنتجات...',
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16),
                                    prefixIcon: const Icon(Icons.search,
                                        color: darkBlueColor),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            onPressed: _clearSearch,
                                            icon: const Icon(Icons.clear,
                                                color: Colors.grey),
                                            tooltip: 'مسح البحث',
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: darkBlueColor, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  onChanged: _onSearchChanged,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _toggleBulkEditMode,
                              icon: Icon(
                                _isBulkEditMode ? Icons.close : Icons.edit,
                                color: _isBulkEditMode
                                    ? Colors.red
                                    : darkBlueColor,
                              ),
                              tooltip: _isBulkEditMode
                                  ? 'إلغاء التعديل الجماعي'
                                  : 'تعديل جماعي',
                            ),
                            IconButton(
                              onPressed: _showDataStatus,
                              icon: const Icon(Icons.info_outline,
                                  color: darkBlueColor),
                              tooltip: 'حالة البيانات',
                            ),
                          ],
                        ),

                        // Search info and bulk edit controls
                        if (_searchQuery.isNotEmpty || _isBulkEditMode) ...[
                          const SizedBox(height: 12),
                          if (_isBulkEditMode)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.orange.shade700, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تم اختيار ${_selectedProductIds.length} منتج',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _selectAllProducts,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.orange.shade700,
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    child: const Text('اختيار الكل'),
                                  ),
                                  TextButton(
                                    onPressed: _clearAllSelections,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade700,
                                    ),
                                    child: const Text('مسح الاختيار'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  // Products list
                  Expanded(
                    child:
                        BlocBuilder<SearchMainStoreCubit, SearchMainStoreState>(
                      builder: (context, state) {
                        // Show initial state when no search has been performed
                        if (state is SearchMainStoreInitial) {
                          final cubit = context.read<SearchMainStoreCubit>();
                          if (cubit.isDataLoaded) {
                            return _buildInitialState();
                          } else {
                            return _buildDataNotLoadedState();
                          }
                        }

                        if (state is SearchMainStoreLoaded) {
                          _allProducts = state.products;

                          if (state.products.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              final productId = product['productId'].toString();
                              final isSelected =
                                  _selectedProductIds.contains(productId);

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Stack(
                                  children: [
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      opacity: _isBulkEditMode && !isSelected
                                          ? 0.6
                                          : 1.0,
                                      child: _buildProductCard(product, index),
                                    ),
                                    if (_isBulkEditMode)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: GestureDetector(
                                          onTap: () => _toggleProductSelection(
                                              productId),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons
                                                      .radio_button_unchecked,
                                              color: isSelected
                                                  ? Colors.green
                                                  : Colors.grey,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        }

                        if (state is SearchMainStoreLoading) {
                          return _buildLoadingState();
                        } else if (state is SearchMainStoreError) {
                          return _buildErrorState(state.message);
                        }

                        return _buildInitialState();
                      },
                    ),
                  ),
                ],
              ),

              // Floating action button for bulk edit
              if (_isBulkEditMode && _selectedProductIds.isNotEmpty)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton.extended(
                    onPressed: _showBulkEditDialog,
                    backgroundColor: darkBlueColor,
                    icon: const Icon(Icons.edit, color: whiteColor),
                    label: Text(
                      'تعديل (${_selectedProductIds.length})',
                      style: const TextStyle(
                          color: whiteColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataNotLoadedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'البيانات غير محملة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'يرجى إعادة تشغيل التطبيق لتحميل البيانات',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SearchMainStoreCubit>()
                  .fetchAllStoreProducts(storeId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlueColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة تحميل البيانات'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'ابحث عن المنتجات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ بكتابة اسم المنتج في شريط البحث أعلاه',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: darkBlueColor),
          SizedBox(height: 16),
          Text(
            'جاري البحث...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'لم يتم العثور على منتجات'
                : 'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

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
            onPressed: () {
              // Always use performSearch for consistency
              _performSearch();
            },
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

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    if (_currentTabIndex == 0) {
      return OfferCard(
        product: product,
        storeId: storeId,
        productData: const [],
        index: index,
      );
    } else if (_currentTabIndex == 1) {
      return AvailableCard(
        product: product,
        storeId: storeId,
        productData: const [],
        index: index,
      );
    } else if (_currentTabIndex == 2) {
      return unAvailableCard(
        product: product,
        index: index,
        productData: const [],
        context: context,
      );
    }
    return const SizedBox.shrink();
  }
}

class BulkEditDialog extends StatefulWidget {
  final Set<String> selectedProductIds;
  final int currentTabIndex;
  final VoidCallback onEditComplete;

  const BulkEditDialog({
    super.key,
    required this.selectedProductIds,
    required this.currentTabIndex,
    required this.onEditComplete,
  });

  @override
  State<BulkEditDialog> createState() => _BulkEditDialogState();
}

class _BulkEditDialogState extends State<BulkEditDialog> {
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxOrderController = TextEditingController();

  bool _updatePrice = false;
  bool _updateOfferPrice = false;
  bool _updateMinOrder = false;
  bool _updateMaxOrder = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _offerPriceController.dispose();
    _minOrderController.dispose();
    _maxOrderController.dispose();
    super.dispose();
  }

  Future<void> _applyBulkEdit() async {
    if (!_updatePrice &&
        !_updateOfferPrice &&
        !_updateMinOrder &&
        !_updateMaxOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار حقل واحد على الأقل للتعديل')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (String productId in widget.selectedProductIds) {
        final docRef = FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .collection('products')
            .doc(productId);

        Map<String, dynamic> updates = {};

        if (_updatePrice && _priceController.text.isNotEmpty) {
          updates['price'] = int.tryParse(_priceController.text) ?? 0;
        }

        if (_updateOfferPrice && _offerPriceController.text.isNotEmpty) {
          updates['offerPrice'] = int.tryParse(_offerPriceController.text) ?? 0;
        }

        if (_updateMinOrder && _minOrderController.text.isNotEmpty) {
          updates['minOrderQuantity'] =
              int.tryParse(_minOrderController.text) ?? 1;
        }

        if (_updateMaxOrder && _maxOrderController.text.isNotEmpty) {
          updates['maxOrderQuantity'] =
              int.tryParse(_maxOrderController.text) ?? 100;
        }

        if (updates.isNotEmpty) {
          batch.update(docRef, updates);

          // Update local data in cubit for immediate UI update
          context
              .read<SearchMainStoreCubit>()
              .updateProductLocally(productId, updates);
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'تم تعديل ${widget.selectedProductIds.length} منتج بنجاح')),
      );

      Navigator.of(context).pop();
      widget.onEditComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التعديل: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      title: Text(
        'تعديل جماعي (${widget.selectedProductIds.length} منتج)',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price
            CheckboxListTile(
              title: const Text('السعر'),
              value: _updatePrice,
              onChanged: (value) {
                setState(() {
                  _updatePrice = value ?? false;
                });
              },
            ),
            if (_updatePrice)
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعر الجديد',
                  suffixText: 'جـ',
                ),
              ),

            const SizedBox(height: 16),

            // Offer Price (only for offers tab)
            if (widget.currentTabIndex == 0) ...[
              CheckboxListTile(
                title: const Text('سعر العرض'),
                value: _updateOfferPrice,
                onChanged: (value) {
                  setState(() {
                    _updateOfferPrice = value ?? false;
                  });
                },
              ),
              if (_updateOfferPrice)
                TextField(
                  controller: _offerPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'سعر العرض الجديد',
                    suffixText: 'جـ',
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Min Order Quantity
            CheckboxListTile(
              title: const Text('أقل كمية للطلب'),
              value: _updateMinOrder,
              onChanged: (value) {
                setState(() {
                  _updateMinOrder = value ?? false;
                });
              },
            ),
            if (_updateMinOrder)
              TextField(
                controller: _minOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'أقل كمية للطلب',
                ),
              ),

            const SizedBox(height: 16),

            // Max Order Quantity
            CheckboxListTile(
              title: const Text('أقصى كمية للطلب'),
              value: _updateMaxOrder,
              onChanged: (value) {
                setState(() {
                  _updateMaxOrder = value ?? false;
                });
              },
            ),
            if (_updateMaxOrder)
              TextField(
                controller: _maxOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'أقصى كمية للطلب',
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _applyBulkEdit,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlueColor,
            foregroundColor: whiteColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                  ),
                )
              : const Text('تطبيق التعديل'),
        ),
      ],
    );
  }
}
