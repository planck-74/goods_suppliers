import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/price_quantity_section.dart';

class SheetOffer extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<dynamic> productData;
  final int index;

  const SheetOffer({
    super.key,
    required this.product,
    required this.productData,
    required this.index,
  });

  @override
  _SheetOfferState createState() => _SheetOfferState();
}

class _SheetOfferState extends State<SheetOffer> {
  bool isAvailable = true;
  bool checkBoxState = true;
  DateTime? selectedDate;

  late TextEditingController priceController;
  late TextEditingController minQuantityController;
  late TextEditingController maxQuantityController;
  late TextEditingController offerPriceController;
  late TextEditingController maxQuantityControllerOffer;

  @override
  void initState() {
    super.initState();
    // _fetchStoreId();
    _initializeTextControllers();
  }

  void _initializeTextControllers() {
    priceController = TextEditingController(
      text: widget.product['price']?.toString() ?? '0',
    );
    minQuantityController = TextEditingController(
      text: widget.product['minOrderQuantity']?.toString() ?? '1',
    );
    maxQuantityController = TextEditingController(
      text: widget.product['maxOrderQuantity']?.toString() ?? '50',
    );
    offerPriceController = TextEditingController(
      text: widget.product['offerPrice']?.toString() ?? '0',
    );
    maxQuantityControllerOffer = TextEditingController(
      text: widget.product['maxOrderQuantityForOffer']?.toString() ?? '10',
    );
  }

  Future<void> _selectDate(BuildContext context) async {
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
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    minQuantityController.dispose();
    maxQuantityController.dispose();
    offerPriceController.dispose();
    maxQuantityControllerOffer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            _buildProductInfoSection(),
            const Divider(),
            Column(
              children: [
                buildFieldRow(
                  context: context,
                  label: 'سعر العرض',
                  controller: offerPriceController,
                  minLimit: 1,
                  maxLimit: 10000,
                ),
                PriceQuantitySection(
                  priceController: priceController,
                  maxQuantityController: maxQuantityController,
                  minQuantityController: minQuantityController,
                ),
                const SizedBox(height: 10),
                buildFieldRow(
                  context: context,
                  label: 'أقصى كمية لطلب العرض',
                  controller: maxQuantityControllerOffer,
                  minLimit: 1,
                  maxLimit: 10000,
                ),
              ],
            ),
            const Divider(),
            _buildBottomActions(
              checkBoxState ? 'إضافة عرض' : 'تعديل',
              checkBoxState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (widget.product['size'] != null)
                Text(
                  widget.product['size'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(String text, bool checkBoxState) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<DynamicProductCubit, DynamicProductState>(
              builder: (context, state) {
                return customElevatedButtonRectangle(
                  screenWidth: 160,
                  context: context,
                  color: Colors.green,
                  onPressed: () {
                    if (priceController.text != '0' &&
                        widget.product['productId'] != null) {
                      context.read<DynamicProductCubit>().updateOffer(
                            context: context,
                            availability: isAvailable,
                            productId: widget.product['productId'],
                            maxOrderQuantityForOffer:
                                int.tryParse(maxQuantityControllerOffer.text) ??
                                    0,
                            offerPrice:
                                int.tryParse(offerPriceController.text) ?? 0,
                            price: int.tryParse(priceController.text) ?? 0,
                            maxOrderQuantity:
                                int.tryParse(maxQuantityController.text) ?? 0,
                            minOrderQuantity:
                                int.tryParse(minQuantityController.text) ?? 0,
                            name: widget.product['name'],
                            isOnSale: checkBoxState,
                            classification: widget.product['classification'],
                            imageUrl: widget.product['imageUrl'],
                            note: widget.product['note'],
                            manufacturer: widget.product['manufacturer'],
                            size: widget.product['size'],
                            package: widget.product['package'],
                            salesCount: widget.product['salesCount'],
                          );

                      context
                          .read<UnAvailableCubit>()
                          .eliminateProduct(index: widget.index);

                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: state is DynamicProductLoading
                      ? Center(
                          child: customCircularProgressIndicator(
                            context: context,
                            color: whiteColor,
                          ),
                        )
                      : Text(
                          text,
                          style: const TextStyle(
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغــاء',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
