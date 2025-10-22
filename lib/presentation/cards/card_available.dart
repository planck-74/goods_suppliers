import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/presentation/sheets/sheet_available.dart';

class AvailableCard extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String storeId;

  const AvailableCard({
    super.key,
    required this.product,
    required this.storeId,
  });

  @override
  _AvailableCardState createState() => _AvailableCardState();
}

class _AvailableCardState extends State<AvailableCard> {
Widget _buildProductImage() {
  if (widget.product != null && widget.product!.containsKey('imageUrl')) {
    final imageUrl = widget.product!['imageUrl'];

    return SizedBox(
      height: 115,
      width: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Center(
            child: Text(
              'لا توجد صورة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
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

  Widget _buildProductDetails(Map<String, dynamic>? product) {
    if (product == null) {
      return const Text('No product details available');
    }

    final String title =
        '${product['name']}${product['size'] != null ? ' - ${product['size']}' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        if (product.containsKey('offerPrice') &&
            product['offerPrice'] != '' &&
            product['offerPrice'] != null) ...[
          Row(
            children: [
              Text(
                '${product['offerPrice']} جـ',
                style: const TextStyle(color: Colors.lightGreen, fontSize: 18),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                '${product['price']} جـ',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough),
              ),
            ],
          ),
          Text(
            'أقصى كمية لطلب العرض: ${product['maxOrderQuantityForOffer']}',
            style: const TextStyle(color: darkBlueColor, fontSize: 14),
          ),
        ] else ...[
          Text(
            '${product['price']} جـ',
            style: const TextStyle(color: Colors.lightGreen, fontSize: 18),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'أقل كمية للطلب: ${product['minOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          'أقصى كمية للطلب: ${product['maxOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  void _handleUnavailable(BuildContext context) {
    // Ensure we have a valid productId before proceeding
    final productId = widget.product?['productId'];
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: معرف المنتج غير موجود'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                          productId, // Use the productId directly
                        );

                    // Use the productId-based removal method
                    context
                        .read<AvailableCubit>()
                        .removeProductLocally(productId);

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
                      Expanded(
                        child: _buildProductDetails(widget.product),
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
                          elevation: WidgetStateProperty.all(10),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        onPressed: () => _showSheet(
                          context,
                          widget.product ?? {},
                        ),
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
            if (widget.product!.containsKey('isOnSale') &&
                widget.product?['isOnSale'] == true)
              Positioned(
                right: 0,
                top: 0,
                child: Opacity(
                  opacity: 0.8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00C853), // أخضر فاتح
                          Color(0xFF009624), // أخضر غامق
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16), // زود الانحناءة
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'عرض',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

// Updated to not require index and productData
void _showSheet(BuildContext context, Map<String, dynamic> product) {
  // Validate that product has required ID
  if (product['productId'] == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('خطأ: معرف المنتج غير موجود'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  showModalBottomSheet(
    backgroundColor: whiteColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SheetAvailable(
        product: product,
      );
    },
  );
}
