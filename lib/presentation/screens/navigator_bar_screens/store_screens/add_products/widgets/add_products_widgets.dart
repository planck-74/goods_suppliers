import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/supplier_product_model.dart';
import 'package:goods/presentation/custom_widgets/counter.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/add_products/product_details_form.dart';
import 'package:goods/presentation/sheets/availability_switch.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';

class AddProductsWidgets {
  AddProductsWidgets({
    required this.product,
    required this.formKey,
    required this.selectedDate,
    required this.priceController,
    required this.maxQuantityController,
    required this.minQuantityController,
    required this.offerPriceController,
    required this.maxQuantityControllerOffer,
    required this.storeId,
    required this.updateProductField,
    required this.setState,
  });

  final Map<String, dynamic> product;
  final GlobalKey<ProductDetailFormState> formKey;

  DateTime? selectedDate;
  final TextEditingController priceController;
  final TextEditingController maxQuantityController;
  final TextEditingController minQuantityController;
  final TextEditingController offerPriceController;
  final TextEditingController maxQuantityControllerOffer;
  final String? storeId;
  final void Function(String key, dynamic value) updateProductField;
  final void Function(VoidCallback fn) setState;
  Widget buildProductInfoSection(Map<String, dynamic> product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['name'] ?? 'منتج غير معروف',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (product['size'] != null)
                Text(
                  product['size'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        AvailabilitySwitch(
          isAvailable: product['availability'] ?? true,
          onToggle: (value) {
            updateProductField('availability', value);
          },
        ),
      ],
    );
  }

  Widget buildCheckbox() {
    final isOnSale = product['isOnSale'] ?? false;

    return Row(
      children: [
        Checkbox(
          activeColor: Colors.red,
          value: isOnSale,
          onChanged: (value) {
            final newValue = value ?? false;
            updateProductField('isOnSale', newValue);

            // تحديث القيم المرتبطة بالعرض في حالة التفعيل
            if (newValue) {
              updateProductField(
                  'offerPrice', int.tryParse(offerPriceController.text) ?? 0);
              updateProductField('maxOrderQuantityForOffer',
                  int.tryParse(maxQuantityControllerOffer.text) ?? 10);
            } else {
              updateProductField('offerPrice', 0);
              updateProductField('maxOrderQuantityForOffer', 0);
              updateProductField('endDate', null);
            }
          },
        ),
        const Text(
          'إضافة الي قائمة العروض',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget buildExpirationDateButton(BuildContext context) {
    return customOutlinedButton(
      backgroundColor: whiteColor.withOpacity(0.5),
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            selectedDate = picked;
          });
          updateProductField('endDate', picked);
        }
      },
      width: MediaQuery.of(context).size.width * 0.95,
      height: 35,
      context: context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.date_range_outlined, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(
            selectedDate != null
                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                : 'حدد ميعاد انتهاء العرض',
            style: const TextStyle(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget buildOfferPriceSection() {
    return Container(
      padding: const EdgeInsets.all(6),
      color: const Color.fromARGB(255, 216, 216, 216),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text(
                'سعر العرض',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              AddProductCounter(
                controller: offerPriceController,
                minLimit: 1,
                maxLimit: 50000,
                product: product,
                theKey: 'offerPrice',
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'أقصي كمية للعرض',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              AddProductCounter(
                product: product,
                controller: maxQuantityControllerOffer,
                minLimit: 1,
                maxLimit: 50000,
                theKey: 'maxOrderQuantityForOffer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Product? getStoreProduct() {
    final price = int.tryParse(priceController.text) ?? 0;
    if (storeId == null || price <= 0) return null;

    final isOnSale = product['isOnSale'] ?? false;
    final availability = product['availability'] ?? false;

    return Product(
      productId: product['productId'],
      availability: availability,
      price: price,
      maxOrderQuantity: int.tryParse(maxQuantityController.text) ?? 50,
      minOrderQuantity: int.tryParse(minQuantityController.text) ?? 1,
      offerPrice:
          isOnSale ? int.tryParse(offerPriceController.text) ?? 0 : null,
      maxOrderQuantityForOffer:
          isOnSale ? int.tryParse(maxQuantityControllerOffer.text) ?? 50 : null,
      endDate: isOnSale ? selectedDate : null,
      isOnSale: isOnSale,
      name: product['name'],
      classification: product['classification'],
      imageUrl: product['imageUrl'],
      note: product['note'],
      manufacturer: product['manufacturer'],
      size: product['size'],
      package: product['package'],
      salesCount: product['salesCount'],
    );
  }
}
