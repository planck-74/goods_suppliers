import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_state.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/supplier_product_model.dart';
import 'package:goods/presentation/custom_widgets/counter.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/price_quantity_section.dart';

class SheetUnavailable extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<dynamic> productData;
  final int index;

  const SheetUnavailable({
    super.key,
    required this.product,
    required this.productData,
    required this.index,
  });

  @override
  _SheetUnavailableState createState() => _SheetUnavailableState();
}

class _SheetUnavailableState extends State<SheetUnavailable> {
  bool isAvailable = true;
  bool checkBoxState = false;
  DateTime? selectedDate;

  // Declare text controllers as late variables.
  late TextEditingController priceController;
  late TextEditingController minQuantityController;
  late TextEditingController maxQuantityController;
  late TextEditingController offerPriceController;
  late TextEditingController maxQuantityControllerOffer;

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
  }

  // Initialize the text controllers using values from widget.product.
  void _initializeTextControllers() {
    priceController = TextEditingController(
      text: widget.product['price']?.toString() ?? '0',
    );
    minQuantityController = TextEditingController(
      text: widget.product['minOrderQuantity']?.toString() ?? '1',
    );
    maxQuantityController = TextEditingController(
      text: widget.product['maxOrderQuantity']?.toString() ?? '10',
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
            PriceQuantitySection(
              priceController: priceController,
              maxQuantityController: maxQuantityController,
              minQuantityController: minQuantityController,
            ),
            buildCheckbox(),
            if (checkBoxState) ...[
              buildExpirationDateButton(context),
              const SizedBox(height: 12),
              buildOfferPriceSection(),
            ],
            const Divider(),
            _buildBottomActions(
              checkBoxState ? 'إضافة عرض' : 'موجود',
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

  Widget buildCheckbox() {
    return Row(
      children: [
        Checkbox(
          activeColor: Colors.red,
          value: checkBoxState,
          onChanged: (value) {
            setState(() {
              checkBoxState = value ?? false;
            });
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
      onPressed: () => _selectDate(context),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        color: const Color.fromARGB(255, 216, 216, 216),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'سعر العرض',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(width: 70),
                  ],
                ),
                Counter(
                  controller: offerPriceController,
                  minLimit: 1,
                  maxLimit: 50000,
                ),
              ],
            ),
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'أقصي كمية للعرض',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(width: 60),
                  ],
                ),
                Counter(
                  controller: maxQuantityControllerOffer,
                  minLimit: 1,
                  maxLimit: 50000,
                ),
              ],
            ),
          ],
        ),
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
                    if (priceController.text != '0') {
                      context.read<DynamicProductCubit>().addDynamicProduct(
                            context,
                            StoreProduct(
                              productId: widget.product['productId'],
                              availability: isAvailable,
                              price: int.tryParse(priceController.text) ?? 0,
                              maxOrderQuantity:
                                  int.tryParse(maxQuantityController.text) ??
                                      50,
                              minOrderQuantity:
                                  int.tryParse(minQuantityController.text) ?? 1,
                              offerPrice: checkBoxState
                                  ? int.tryParse(offerPriceController.text) ?? 0
                                  : null,
                              maxOrderQuantityForOffer: checkBoxState
                                  ? int.tryParse(
                                          maxQuantityControllerOffer.text) ??
                                      50
                                  : null,
                              endDate: checkBoxState ? selectedDate : null,
                              isOnSale: checkBoxState,
                            ),
                            storeId,
                            message: 'أصبح المنتج الان معروض للعميل',
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
