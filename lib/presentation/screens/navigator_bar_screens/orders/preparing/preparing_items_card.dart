import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/order_model.dart';

class PreparingItemsCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final TextEditingController controller;
  final List<int> initControllers;
  final List<TextEditingController> controllers;
  final List<Map> selectedProducts;
  final int itemCount;
  final int index;
  final bool checkBoxValue;
  final Function(bool, int) onCheckBoxChanged;
  final OrderModel order;
  final List<bool> selectionList;

  const PreparingItemsCard({
    super.key,
    required this.product,
    required this.controller,
    required this.itemCount,
    required this.index,
    required this.initControllers,
    required this.checkBoxValue,
    required this.onCheckBoxChanged,
    required this.order,
    required this.selectionList,
    required this.selectedProducts,
    required this.controllers,
  });

  @override
  _PreparingItemsCardState createState() => _PreparingItemsCardState();
}

class _PreparingItemsCardState extends State<PreparingItemsCard> {
  Map<String, dynamic> product = {};

  @override
  void initState() {
    super.initState();
    product.addAll(widget.product);
    product.addAll(widget.product);
  }

  /// Calculates the total price for this product based on:
  /// - Normal price and offer price.
  /// - Clamping the quantity between minOrderQuantity and maxOrderQuantity.
  /// - Applying offer price up to maxOrderQuantityForOffer (if on sale).
  int calculateProductTotal() {
    int normalPrice = widget.product['price'] ?? 0;
    int offerPrice = widget.product['offerPrice'] ?? normalPrice;
    int quantity = int.tryParse(widget.controller.text) ?? 0;
    int minOrderQuantity = widget.product['minOrderQuantity'] ?? 1;
    int maxOrderQuantity = widget.product['maxOrderQuantity'] ?? 10000;
    int maxOfferQty = widget.product['maxOrderQuantityForOffer'] ?? quantity;

    // Clamp the quantity between the minimum and maximum allowed.
    if (quantity < minOrderQuantity) quantity = minOrderQuantity;
    if (quantity > maxOrderQuantity) quantity = maxOrderQuantity;

    bool isOnSale = widget.product['isOnSale'] ?? false;
    int productTotal = 0;

    if (isOnSale) {
      if (quantity <= maxOfferQty) {
        productTotal = offerPrice * quantity;
      } else {
        int extraQty = quantity - maxOfferQty;
        productTotal = offerPrice * maxOfferQty + normalPrice * extraQty;
      }
    } else {
      productTotal = normalPrice * quantity;
    }
    return productTotal;
  }

  Widget _buildProductImage() {
    if (widget.product.containsKey('imageUrl')) {
      return SizedBox(
        height: 120,
        width: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.product['imageUrl'],
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: darkBlueColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text('لا توجد صورة',
                    style: Theme.of(context).textTheme.headlineMedium),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        height: 100,
        width: 70,
        color: Colors.blueGrey[200],
        child: const Center(
          child: Text(
            'الصورة غير متوفرة',
            style: TextStyle(fontSize: 8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProductImage(),
                  const SizedBox(width: 12.0),
                  buildProductDetails(
                      context: context,
                      product: widget.product,
                      controller: widget.controller,
                      calculateProductTotal: calculateProductTotal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildProductDetails(
    {required context,
    required product,
    required controller,
    required calculateProductTotal}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${product?['name'] ?? ''} - ${product?['size'] != null ? '${product?['size']}' : ''}${product?['note'] != null && product?['note'] != '' ? '(${product?['note']})' : ''}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'السعر: ',
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
              Text('${product['price']} جـ'),
            ],
          ),
          if (product['offerPrice'] != null && product['offerPrice'] != '') ...[
            Row(
              children: [
                const Text(
                  'سعر العرض: ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                Text('${product['offerPrice']} جـ'),
              ],
            ),
          ],
          Row(
            children: [
              const Text(
                'العدد: ',
                style: TextStyle(color: Colors.blueGrey, fontSize: 14),
              ),
              Text('${controller.text}'),
            ],
          ),
          if (product['maxOrderQuantityForOffer'] != null &&
              product['maxOrderQuantityForOffer'] != '') ...[
            Row(
              children: [
                const Text(
                  'أقصي قمية للعرض: ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                Text('${product['maxOrderQuantityForOffer']}'),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'الإجمالي : ${calculateProductTotal()} جـ',
            style: const TextStyle(color: Colors.lightGreen, fontSize: 22),
          ),
        ],
      ),
    ),
  );
}
