import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/presentation/sheets/sheet_available.dart';

class AvailableCard extends StatefulWidget {
  final Map<String, dynamic>? staticData;
  final Map<String, dynamic> dynamicData;
  final String storeId;
  final int index;
  final List productData;

  const AvailableCard({
    super.key,
    required this.staticData,
    required this.dynamicData,
    required this.storeId,
    required this.productData,
    required this.index,
  });

  @override
  _AvailableCardState createState() => _AvailableCardState();
}

class _AvailableCardState extends State<AvailableCard> {
  Map<String, dynamic> product = {};

  @override
  void initState() {
    super.initState();
    product.addAll(widget.dynamicData); // إضافة البيانات الديناميكية
    if (widget.staticData != null) {
      product.addAll(widget.staticData!); // إضافة البيانات الثابتة إن وجدت
    }
  }

  /// يعرض صورة المنتج مع التعامل مع حالات التحميل والأخطاء
  Widget _buildProductImage() {
    if (widget.staticData != null &&
        widget.staticData!.containsKey('imageUrl')) {
      return SizedBox(
        height: 115,
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.staticData!['imageUrl'],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'لا توجد صورة',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        height: 150,
        width: 100,
        color: Colors.grey[200],
        child: const Center(child: Text('No Image')),
      );
    }
  }

  /// يعرض تفاصيل المنتج (الاسم مع الحجم والسعر وكميات الطلب)
  Widget _buildProductDetails(Map<String, dynamic>? staticData) {
    final String title =
        '${staticData?['name']}${staticData?['size'] != null ? ' - ${staticData?['size']}' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2, // Allows wrapping into a second line
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        if (widget.dynamicData.containsKey('offerPrice') &&
            widget.dynamicData['offerPrice'] != '' &&
            widget.dynamicData['offerPrice'] != null) ...[
          Row(
            children: [
              Text(
                '${widget.dynamicData['offerPrice']} جـ',
                style: const TextStyle(color: Colors.lightGreen, fontSize: 18),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                '${widget.dynamicData['price']} جـ',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough),
              ),
            ],
          ),
          Text(
            'أقصى كمية لطلب العرض: ${widget.dynamicData['maxOrderQuantityForOffer']}',
            style: const TextStyle(color: darkBlueColor, fontSize: 14),
          ),
        ] else ...[
          Text(
            '${widget.dynamicData['price']} جـ',
            style: const TextStyle(color: Colors.lightGreen, fontSize: 18),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'أقل كمية للطلب: ${widget.dynamicData['minOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          'أقصى كمية للطلب: ${widget.dynamicData['maxOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  void _handleUnavailable(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          title: Text(
            'غير موجود',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: const Text(
            'متاكد من نفاذ المنتج؟',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            BlocBuilder<DynamicProductCubit, DynamicProductState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: () async {
                    await context
                        .read<DynamicProductCubit>()
                        .markProductAsUnavailable(
                          context,
                          widget.storeId,
                          widget.dynamicData['productId'],
                        );
                    context
                        .read<AvailableCubit>()
                        .eliminateProduct(index: widget.index);
                    Navigator.of(context).pop(true);
                  },
                  child: state is DynamicProductLoading
                      ? customCircularProgressIndicator(
                          context: context, color: Colors.grey)
                      : const Text(
                          'تـاكيد',
                          style: TextStyle(color: Colors.black),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Container(
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
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProductImage(),
                      const SizedBox(width: 6),
                      Container(
                        height: 60,
                        width: 1.0,
                        color: darkBlueColor,
                      ),
                      const SizedBox(width: 6),
                      // Wrap product details with Expanded to allow text wrapping
                      Expanded(
                        child: _buildProductDetails(widget.staticData),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 18, 8),
                  child: Row(
                    children: [
                      OutlinedButton(
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(10),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: () => _showSheet(
                            context, widget.index, product, widget.productData),
                        child: const Text(
                          '  تعديل',
                          style: TextStyle(
                            color: darkBlueColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: () => _handleUnavailable(context),
                        child: const Text(
                          'إزالة المنتج',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product['isOnSale'] == true)
              Positioned(
                right: 0,
                top: 0,
                child: Opacity(
                  opacity: 0.8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'في العرض',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void _showSheet(BuildContext context, int index, Map<String, dynamic> product,
    List productData) {
  showModalBottomSheet(
    backgroundColor: whiteColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Sheetavailable(
        index: index,
        product: product,
        productData: productData,
      );
    },
  );
}
