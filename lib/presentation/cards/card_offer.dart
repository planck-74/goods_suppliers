import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/presentation/sheets/sheet_offer.dart';

class OfferCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final String storeId;
  final int index;
  final List productData;

  const OfferCard({
    super.key,
    required this.product,
    required this.storeId,
    required this.productData,
    required this.index,
  });

  @override
  _OfferCardState createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  /// يعرض صورة المنتج مع التعامل مع حالات التحميل والأخطاء
  Widget _buildProductImage() {
    if (widget.product.containsKey('imageUrl')) {
      return SizedBox(
        height: 115,
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.product['imageUrl'],
            fit: BoxFit.contain,
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
        height: 115,
        width: 100,
        color: Colors.grey[200],
        child: const Center(child: Text('No Image')),
      );
    }
  }

  Widget _buildProductDetails(Map<String, dynamic>? product) {
    final String title = '${product?['name']}'
        '${product?['size'] != null ? ' - ${product?['size']}' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2, // Allow up to 2 lines for the title
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${widget.product['offerPrice']} جـ',
              style: const TextStyle(color: Colors.lightGreen, fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              '${widget.product['price']} ',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 20,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'أقصى كمية لطلب العرض: ${widget.product['maxOrderQuantityForOffer']}',
          style: const TextStyle(color: darkBlueColor, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          'أقصى كمية للطلب: ${widget.product['maxOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'أقل كمية للطلب: ${widget.product['minOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
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
          content: const Text(
            'متاكد من إزالة العرض',
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
                    await context.read<DynamicProductCubit>().removeOffer(
                          context,
                          widget.storeId,
                          widget.product['productId'],
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
        // Removing fixed height to let the card adapt to its content
        padding: const EdgeInsets.all(8.0),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(),
                const SizedBox(width: 6),
                Container(
                  height: 115,
                  width: 1.0,
                  color: darkBlueColor,
                ),
                const SizedBox(width: 6),
                // Wrapping details with Expanded ensures it adapts within available space.
                Expanded(
                  child: _buildProductDetails(widget.product),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8, 18, 8),
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
                    onPressed: () => _showEditSheet(context, widget.index,
                        widget.product, widget.productData),
                    child: const Text(
                      'تعديل العرض',
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
                      'إزالة من العروض',
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
      ),
    );
  }
}

void _showEditSheet(BuildContext context, int index,
    Map<String, dynamic> product, List productData) {
  showModalBottomSheet(
    backgroundColor: whiteColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SheetOffer(
        index: index,
        product: product,
        productData: productData,
      );
    },
  );
}
