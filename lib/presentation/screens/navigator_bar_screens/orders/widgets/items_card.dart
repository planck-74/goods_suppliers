import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/order_model.dart';

class ItemsCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final TextEditingController controller;
  final int itemCount;
  final int index;
  final OrderModel order;

  const ItemsCard({
    super.key,
    required this.product,
    required this.controller,
    required this.itemCount,
    required this.index,
    required this.order,
  });

  @override
  _ItemsCardState createState() => _ItemsCardState();
}

class _ItemsCardState extends State<ItemsCard> {
  Map<String, dynamic> product = {};

  @override
  void initState() {
    super.initState();
    product['product'].addAll(widget.product['product']);
    product['product'].addAll(widget.product['product']);
  }

  int calculateProductTotal() {
    int normalPrice = widget.product['product']['price'] ?? 0;
    int offerPrice = widget.product['product']['offerPrice'] ?? normalPrice;
    int quantity = int.tryParse(widget.controller.text) ?? 0;
    int minOrderQuantity = widget.product['product']['minOrderQuantity'] ?? 1;
    int maxOrderQuantity =
        widget.product['product']['maxOrderQuantity'] ?? 10000;
    int maxOfferQty =
        widget.product['product']['maxOrderQuantityForOffer'] ?? quantity;

    // Clamp the quantity between the minimum and maximum allowed.
    if (quantity < minOrderQuantity) quantity = minOrderQuantity;
    if (quantity > maxOrderQuantity) quantity = maxOrderQuantity;

    bool isOnSale = widget.product['product']['isOnSale'] ?? false;
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
    if (widget.product['product'].containsKey('imageUrl')) {
      return SizedBox(
        height: 100,
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.product['product']['imageUrl'],
            fit: BoxFit.fitWidth,
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
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            'الصورة غير متوفرة',
            style: TextStyle(fontSize: 8),
          ),
        ),
      );
    }
  }

  Widget _buildProductDetails() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product['product']['name'] ?? '',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.product['product']['size'] != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.product['product']['size'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'الإجمالي : ${calculateProductTotal()} جـ',
              style: const TextStyle(color: Colors.lightGreen, fontSize: 18),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(),
              const SizedBox(width: 12.0),
              _buildProductDetails(),
            ],
          ),
        ),
      ),
    );
  }
}
