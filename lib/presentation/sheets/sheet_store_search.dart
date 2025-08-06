import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/search_main_store_cubit/search_main_store_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/cards/card_available.dart';
import 'package:goods/presentation/cards/card_offer.dart';
import 'package:goods/presentation/cards/card_unavailable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  // Bulk edit functionality
  bool _isBulkEditMode = false;
  Set<String> _selectedProductIds = {};
  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.selectedTabIndexNotifier.value;
    widget.selectedTabIndexNotifier.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchMainStoreCubit>().searchProductsByName(
            _searchQuery,
            _currentTabIndex,
            storeId: storeId,
          );
    });
  }

  void _onTabChanged() {
    setState(() {
      _currentTabIndex = widget.selectedTabIndexNotifier.value;
      // Clear selections when switching tabs
      _selectedProductIds.clear();
      _isBulkEditMode = false;
    });
    context.read<SearchMainStoreCubit>().searchProductsByName(
          _searchQuery,
          _currentTabIndex,
          storeId: storeId,
        );
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
      _selectedProductIds.addAll(_allProducts.map((p) => p['productId'].toString()));
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
          // Refresh the search results
          context.read<SearchMainStoreCubit>().searchProductsByName(
                _searchQuery,
                _currentTabIndex,
                storeId: storeId,
              );
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.selectedTabIndexNotifier.removeListener(_onTabChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar and bulk edit toggle
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن منتج...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            context.read<SearchMainStoreCubit>().searchProductsByName(
                                  _searchQuery,
                                  _currentTabIndex,
                                  storeId: storeId,
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _toggleBulkEditMode,
                        icon: Icon(
                          _isBulkEditMode ? Icons.close : Icons.edit,
                          color: _isBulkEditMode ? Colors.red : darkBlueColor,
                        ),
                        tooltip: _isBulkEditMode ? 'إلغاء التعديل الجماعي' : 'تعديل جماعي',
                      ),
                    ],
                  ),
                  
                  // Bulk edit controls
                  if (_isBulkEditMode) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'تم اختيار ${_selectedProductIds.length} منتج',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkBlueColor,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _selectAllProducts,
                            child: const Text('اختيار الكل'),
                          ),
                          TextButton(
                            onPressed: _clearAllSelections,
                            child: const Text('مسح الاختيار'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Products list - THE FIX: Adding scrollController back
                  Expanded(
                    child: BlocBuilder<SearchMainStoreCubit, SearchMainStoreState>(
                      builder: (context, state) {
                        if (state is SearchMainStoreLoaded) {
                          _allProducts = state.products;
                          
                          return ListView.builder(
                            controller: scrollController, // 🎯 This was missing!
                            itemCount: state.products.length,
                            itemBuilder: (context, index) {
                              final product = state.products[index];
                              final productId = product['productId'].toString();
                              final isSelected = _selectedProductIds.contains(productId);
                              
                              return Stack(
                                children: [
                                  // Product card with opacity when in bulk edit mode
                                  Opacity(
                                    opacity: _isBulkEditMode && !isSelected ? 0.6 : 1.0,
                                    child: _buildProductCard(product, index),
                                  ),
                                  
                                  // Checkbox overlay for bulk edit mode
                                  if (_isBulkEditMode)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: GestureDetector(
                                        onTap: () => _toggleProductSelection(productId),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isSelected 
                                                ? Icons.check_circle 
                                                : Icons.radio_button_unchecked,
                                            color: isSelected 
                                                ? Colors.green 
                                                : Colors.grey,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        }
                        
                        if (state is SearchMainStoreLoading) {
                          return const Column(
                            children: [
                              SizedBox(height: 100),
                              CircularProgressIndicator(),
                            ],
                          );
                        } else if (state is SearchMainStoreError) {
                          return Center(child: Text(state.message));
                        }
                        return const Center(child: Text('لا توجد نتائج للبحث'));
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Floating Action Button
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFloatingActionButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    if (!_isBulkEditMode || _selectedProductIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: _showBulkEditDialog,
      backgroundColor: darkBlueColor,
      icon: const Icon(Icons.edit, color: whiteColor),
      label: Text(
        'تعديل (${_selectedProductIds.length})',
        style: const TextStyle(color: whiteColor),
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

// Bulk Edit Dialog
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
    if (!_updatePrice && !_updateOfferPrice && !_updateMinOrder && !_updateMaxOrder) {
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
          updates['price'] = double.tryParse(_priceController.text) ?? 0;
        }
        
        if (_updateOfferPrice && _offerPriceController.text.isNotEmpty) {
          updates['offerPrice'] = double.tryParse(_offerPriceController.text) ?? 0;
        }
        
        if (_updateMinOrder && _minOrderController.text.isNotEmpty) {
          updates['minOrderQuantity'] = int.tryParse(_minOrderController.text) ?? 1;
        }
        
        if (_updateMaxOrder && _maxOrderController.text.isNotEmpty) {
          updates['maxOrderQuantity'] = int.tryParse(_maxOrderController.text) ?? 100;
        }
        
        if (updates.isNotEmpty) {
          batch.update(docRef, updates);
        }
      }
      
      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تعديل ${widget.selectedProductIds.length} منتج بنجاح')),
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