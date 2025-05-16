import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/counters.dart';

class RecentItemsCard extends StatefulWidget {
  final Map<String, dynamic>? staticData;
  final Map<String, dynamic> dynamicData;
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

  const RecentItemsCard({
    super.key,
    required this.staticData,
    required this.dynamicData,
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
  _RecentItemsCardState createState() => _RecentItemsCardState();
}

class _RecentItemsCardState extends State<RecentItemsCard> {
  Map<String, dynamic> product = {};

  @override
  void initState() {
    super.initState();
    product.addAll(widget.dynamicData);
    if (widget.staticData != null) {
      product.addAll(widget.staticData!);
    }
  }

  /// Calculates the total price for this product based on:
  /// - Normal price and offer price.
  /// - Clamping the quantity between minOrderQuantity and maxOrderQuantity.
  /// - Applying offer price up to maxOrderQuantityForOffer (if on sale).
  int calculateProductTotal() {
    int normalPrice = widget.dynamicData['price'] ?? 0;
    int offerPrice = widget.dynamicData['offerPrice'] ?? normalPrice;
    int quantity = int.tryParse(widget.controller.text) ?? 0;
    int minOrderQuantity = widget.dynamicData['minOrderQuantity'] ?? 1;
    int maxOrderQuantity = widget.dynamicData['maxOrderQuantity'] ?? 10000;
    int maxOfferQty =
        widget.dynamicData['maxOrderQuantityForOffer'] ?? quantity;

    // Clamp the quantity between the minimum and maximum allowed.
    if (quantity < minOrderQuantity) quantity = minOrderQuantity;
    if (quantity > maxOrderQuantity) quantity = maxOrderQuantity;

    bool isOnSale = widget.dynamicData['isOnSale'] ?? false;
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
    if (widget.staticData != null &&
        widget.staticData!.containsKey('imageUrl')) {
      return SizedBox(
        height: 100,
        width: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            widget.staticData!['imageUrl'],
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
    int minOrderQuantity = widget.dynamicData['minOrderQuantity'] ?? 1;
    int maxOrderQuantity = widget.dynamicData['maxOrderQuantity'] ?? 10000;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.staticData?['name'] ?? ''} - ${widget.staticData?['size'] != null ? '${widget.staticData?['size']}' : ''}${widget.staticData?['note'] != null && widget.staticData?['note'] != '' ? '(${widget.staticData?['note']})' : ''}',
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
                Text('${widget.dynamicData['price']} جـ'),
              ],
            ),
            if (widget.dynamicData['offerPrice'] != null &&
                widget.dynamicData['offerPrice'] != '') ...[
              Row(
                children: [
                  const Text(
                    'سعر العرض: ',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                  ),
                  Text('${widget.dynamicData['offerPrice']} جـ'),
                ],
              ),
            ],
            Row(
              children: [
                const Text(
                  'العدد: ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                Text(widget.controller.text),
              ],
            ),
            if (widget.dynamicData['maxOrderQuantityForOffer'] != null &&
                widget.dynamicData['maxOrderQuantityForOffer'] != '') ...[
              Row(
                children: [
                  const Text(
                    'أقصي قمية للعرض: ',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                  ),
                  Text('${widget.dynamicData['maxOrderQuantityForOffer']}'),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'الإجمالي : ${calculateProductTotal()} جـ',
              style: const TextStyle(color: Colors.lightGreen, fontSize: 22),
            ),
            const SizedBox(
              height: 12,
            ),
            CounterRow(
              controller: widget.controller,
              initControllers: widget.initControllers,
              onTapRemove: () {},
              onTap: () {},
              index: widget.index,
              order: widget.order,
              selectedProducts: widget.selectedProducts,
              selectionList: widget.selectionList,
              controllers: widget.controllers,
              minLimit: minOrderQuantity,
              maxLimit: maxOrderQuantity,
            )
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
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProductImage(),
                  const SizedBox(width: 12.0),
                  _buildProductDetails(),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: widget.checkBoxValue,
                onChanged: (bool? value) {
                  if (value != null) {
                    widget.onCheckBoxChanged(value, widget.index);
                    context.read<OrdersCubit>().initselectedProducts(
                          widget.order.products,
                          widget.selectionList,
                          widget.selectedProducts,
                          widget.controllers,
                        );
                  }
                },
                activeColor: Colors.green,
                side: const BorderSide(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
