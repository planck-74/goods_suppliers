import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/search_main_store_cubit/search_main_store_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class SheetClassificationUnavailable extends StatefulWidget {
  // Callback function for when a classification is selected
  final Function(String filterType, String value)? onClassificationSelected;

  // Current filter state to show which option is selected
  final String? currentFilterType;
  final String? currentFilterValue;

  // Tab type for getting available classification options
  final int tabType;

  const SheetClassificationUnavailable({
    super.key,
    this.onClassificationSelected,
    this.currentFilterType,
    this.currentFilterValue,
    this.tabType = 1, // Default to Available products tab
  });

  @override
  _SheetClassificationUnavailableState createState() =>
      _SheetClassificationUnavailableState();
}

class _SheetClassificationUnavailableState
    extends State<SheetClassificationUnavailable> {
  String? selectedItem; // Currently selected item
  String? selectedFilterType; // Currently selected filter type

  // Dynamic classification data loaded from SearchMainStoreCubit
  Map<String, List<String>> classificationData = {};
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    // Set initial selection based on current filter
    if (widget.currentFilterType != null && widget.currentFilterValue != null) {
      selectedFilterType = widget.currentFilterType;
      selectedItem = widget.currentFilterValue;
    }
    _loadClassificationData();
  }

  /// Load classification data dynamically from SearchMainStoreCubit
  /// This gets actual values from the products instead of hardcoded lists
  void _loadClassificationData() async {
    final searchCubit = context.read<SearchMainStoreCubit>();

    if (!searchCubit.isDataLoaded) {
      setState(() {
        isLoadingData = false;
        classificationData = {};
      });
      return;
    }

    try {
      // Get available filter types for this tab
      final availableFilterTypes =
          searchCubit.getAvailableFilterTypes(widget.tabType);

      // Common classification types we want to show
      final commonFilterTypes = [
        'manufacturer',
        'classification',
        'category',
        'brand',
        'type',
        'subCategory',
      ];

      // Only include filter types that exist in the data and are commonly used
      final relevantFilterTypes = availableFilterTypes
          .where((type) => commonFilterTypes.contains(type))
          .toList();

      Map<String, List<String>> tempData = {};

      for (String filterType in relevantFilterTypes) {
        final uniqueValues = searchCubit.getUniqueClassificationValues(
            filterType, widget.tabType);
        if (uniqueValues.isNotEmpty) {
          tempData[filterType] = uniqueValues;
        }
      }

      setState(() {
        classificationData = tempData;
        isLoadingData = false;
      });
    } catch (e) {
      print('Error loading classification data: $e');
      setState(() {
        isLoadingData = false;
        classificationData = {};
      });
    }
  }

  /// Handle selection of a classification item
  void _onItemSelected(String filterType, String value) {
    setState(() {
      // If the same item is selected again, deselect it
      if (selectedItem == value && selectedFilterType == filterType) {
        selectedItem = null;
        selectedFilterType = null;
      } else {
        selectedItem = value;
        selectedFilterType = filterType;
      }
    });

    // Apply filter or clear filter based on selection
    if (selectedItem != null && selectedFilterType != null) {
      // Apply the filter
      if (widget.onClassificationSelected != null) {
        widget.onClassificationSelected!(selectedFilterType!, selectedItem!);
      } else {
        // Fallback: apply filter directly
        context.read<SearchMainStoreCubit>().filterProductsByClassification(
              filterType: selectedFilterType!,
              filterValue: selectedItem!,
              tabType: widget.tabType,
            );
        Navigator.of(context).pop();
      }
    } else {
      // Clear all filters
      if (widget.onClassificationSelected != null) {
        // Signal to parent to clear filters (you might want to handle this differently)
        Navigator.of(context).pop();
      } else {
        // Fallback: clear filters directly
        context
            .read<SearchMainStoreCubit>()
            .clearAllFiltersForTab(widget.tabType);
        Navigator.of(context).pop();
      }
    }
  }

  /// Get display name for filter types
  String _getFilterTypeDisplayName(String filterType) {
    switch (filterType) {
      case 'manufacturer':
        return 'الشركات المصنعة';
      case 'classification':
        return 'التصنيف';
      case 'category':
        return 'الفئة';
      case 'brand':
        return 'العلامة التجارية';
      case 'type':
        return 'النوع';
      case 'subCategory':
        return 'الفئة الفرعية';
      default:
        return filterType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تصنيف المنتجات المتاحة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(thickness: 2),

            // Content area
            Flexible(
              child: isLoadingData
                  ? _buildLoadingState()
                  : classificationData.isEmpty
                      ? _buildEmptyState()
                      : _buildClassificationContent(),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: darkBlueColor),
          SizedBox(height: 16),
          Text(
            'جاري تحميل خيارات التصنيف...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no classifications available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خيارات تصنيف متاحة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من وجود منتجات في هذا القسم',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build main classification content
  Widget _buildClassificationContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: classificationData.entries.map((entry) {
          return _buildClassificationSection(
            entry.key, // filter type
            entry.value, // list of values
          );
        }).toList(),
      ),
    );
  }

  /// Build a section for each classification type
  Widget _buildClassificationSection(String filterType, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(_getFilterTypeDisplayName(filterType)),
        const SizedBox(height: 8),

        // Show statistics for this classification
        _buildClassificationStats(filterType),

        const SizedBox(height: 12),

        // Show classification options
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: values.map((value) {
            return _buildSelectableItem(filterType, value);
          }).toList(),
        ),

        const SizedBox(height: 20),
        const Divider(),
      ],
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.orange.shade600],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Build statistics for a classification type
  Widget _buildClassificationStats(String filterType) {
    final searchCubit = context.read<SearchMainStoreCubit>();
    final stats =
        searchCubit.getClassificationStats(filterType, widget.tabType);

    if (stats.isEmpty) return const SizedBox.shrink();

    return const SizedBox();
  }

  /// Build selectable classification item
  Widget _buildSelectableItem(String filterType, String value) {
    bool isSelected = selectedItem == value && selectedFilterType == filterType;

    // Get count for this specific value
    final searchCubit = context.read<SearchMainStoreCubit>();
    final stats =
        searchCubit.getClassificationStats(filterType, widget.tabType);
    final count = stats[value] ?? 0;

    return GestureDetector(
      onTap: () => _onItemSelected(filterType, value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.yellow, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange.shade600 : darkBlueColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
                shadows: isSelected
                    ? [
                        const Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ]
                    : [],
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : darkBlueColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build action buttons at the bottom
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          // Clear all button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: selectedItem != null
                  ? () {
                      setState(() {
                        selectedItem = null;
                        selectedFilterType = null;
                      });

                      // Clear filters
                      context
                          .read<SearchMainStoreCubit>()
                          .clearAllFiltersForTab(widget.tabType);
                      Navigator.of(context).pop();
                    }
                  : null,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('إزالة جميع الفلاتر'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Apply filter button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: selectedItem != null
                  ? () {
                      
                      _onItemSelected(selectedFilterType!, selectedItem!);
                    }
                  : null,
              icon: const Icon(Icons.filter_alt, size: 18),
              label: const Text('تطبيق الفلتر'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedItem != null ? darkBlueColor : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
