import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/supplier_product_model.dart';
import 'package:goods/presentation/custom_widgets/build_product_image.dart';
import 'package:goods/presentation/custom_widgets/counter.dart';
import 'package:goods/presentation/sheets/availability_switch.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/price_quantity_section.dart';

class ProductDetailForm extends StatefulWidget {
  final Map<String, dynamic> product;
  final GlobalKey<_ProductDetailFormState> formKey;

  const ProductDetailForm({
    super.key,
    required this.product,
    required this.formKey,
  });

  @override
  _ProductDetailFormState createState() => _ProductDetailFormState();
}

class _ProductDetailFormState extends State<ProductDetailForm> {
  // Controllers للحقول
  late TextEditingController priceController;
  late TextEditingController minQuantityController;
  late TextEditingController maxQuantityController;
  late TextEditingController offerPriceController;
  late TextEditingController maxQuantityControllerOffer;

  bool checkBoxState = false;
  bool isAvailable = true;
  DateTime? selectedDate;
  String? storeId;

  @override
  void initState() {
    super.initState();
    final product = context
            .read<AddProductCubit>()
            .getProduct(widget.product['productId']) ??
        widget.product;
    priceController =
        TextEditingController(text: product['price']?.toString() ?? '0');
    minQuantityController = TextEditingController(
        text: product['minOrderQuantity']?.toString() ?? '1');
    maxQuantityController = TextEditingController(
        text: product['maxOrderQuantity']?.toString() ?? '10');
    offerPriceController =
        TextEditingController(text: product['offerPrice']?.toString() ?? '0');
    maxQuantityControllerOffer = TextEditingController(
        text: product['maxOrderQuantityForOffer']?.toString() ?? '10');

    isAvailable = product['availability'] ?? true;
    checkBoxState = product['isOnSale'] ?? false;
    selectedDate = product['endDate'];
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

  /// دالة لتحديث حقل محدد في المنتج داخل الـ cubit
  void updateProductField(String key, dynamic value) {
    final currentProduct = context
            .read<AddProductCubit>()
            .getProduct(widget.product['productId']) ??
        widget.product;
    final updatedProduct = {
      ...currentProduct,
      key: value,
    };
    context.read<AddProductCubit>().updateProduct(updatedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddProductCubit, AddProductState>(
      listener: (context, state) {
        // استرجاع آخر نسخة من المنتج من الـ cubit
        final product = context
                .read<AddProductCubit>()
                .getProduct(widget.product['productId']) ??
            widget.product;
        // تحديث المتحكمات إذا كانت القيمة تختلف عن الحالية
        if (priceController.text != product['price']?.toString()) {
          priceController.text = product['price']?.toString() ?? '0';
        }
        if (minQuantityController.text !=
            product['minOrderQuantity']?.toString()) {
          minQuantityController.text =
              product['minOrderQuantity']?.toString() ?? '1';
        }
        if (maxQuantityController.text !=
            product['maxOrderQuantity']?.toString()) {
          maxQuantityController.text =
              product['maxOrderQuantity']?.toString() ?? '10';
        }
        if (offerPriceController.text != product['offerPrice']?.toString()) {
          offerPriceController.text = product['offerPrice']?.toString() ?? '0';
        }
        if (maxQuantityControllerOffer.text !=
            product['maxOrderQuantityForOffer']?.toString()) {
          maxQuantityControllerOffer.text =
              product['maxOrderQuantityForOffer']?.toString() ?? '10';
        }
        // تحديث المتغيرات المحلية (مثلاً حالة التوفر والعرض) إذا لزم الأمر
        setState(() {
          isAvailable = product['availability'] ?? true;
          checkBoxState = product['isOnSale'] ?? false;
          selectedDate = product['endDate'];
        });
      },
      child: BlocBuilder<AddProductCubit, AddProductState>(
        builder: (context, state) {
          // استرجاع آخر نسخة من المنتج من الـ cubit
          final product = context
                  .read<AddProductCubit>()
                  .getProduct(widget.product['productId']) ??
              widget.product;
          return Form(
            key: widget.formKey,
            child: Card(
              color: whiteColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProductInfoSection(product),
                    const Divider(),
                    PriceQuantitySectionAddButton(
                      priceController: priceController,
                      maxQuantityController: maxQuantityController,
                      minQuantityController: minQuantityController,
                      product: product,
                    ),
                    buildCheckbox(),
                    if (checkBoxState) ...[
                      buildExpirationDateButton(context),
                      const SizedBox(height: 12),
                      buildOfferPriceSection(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfoSection(Map<String, dynamic> product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
      children: [
        // عرض معلومات المنتج
        Expanded(
          // This will allow the text to take the remaining space and wrap
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
                maxLines: 2, // This allows the text to take up two lines
                overflow:
                    TextOverflow.ellipsis, // Ensures that text doesn't overflow
              ),
              const SizedBox(height: 4),
              if (product['size'] != null)
                Text(
                  product['size'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2, // This allows the text to take up two lines
                  overflow: TextOverflow
                      .ellipsis, // Ensures that text doesn't overflow
                ),
            ],
          ),
        ),
        // مفتاح تفعيل التوفر
        AvailabilitySwitch(
          isAvailable: isAvailable,
          onToggle: (value) {
            setState(() {
              isAvailable = value;
            });
            updateProductField('availability', value);
          },
        ),
      ],
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
            updateProductField('isOnSale', checkBoxState);
            updateProductField(
                'offerPrice', int.tryParse(offerPriceController.text) ?? 0);
            updateProductField('maxOrderQuantityForOffer',
                int.tryParse(maxQuantityControllerOffer.text) ?? 10);
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
                product: widget.product,
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

  /// دالة التحقق الخاصة بالنموذج
  bool validate() {
    return widget.formKey.currentState?.validate() ?? false;
  }

  /// دالة getStoreProduct لإرجاع نموذج المنتج إذا كان التحقق ناجح
  Product? getStoreProduct() {
    final price = int.tryParse(priceController.text) ?? 0;
    if (storeId == null || price <= 0) return null;
    return Product(
      productId: widget.product['productId'],
      availability: isAvailable,
      price: int.tryParse(priceController.text) ?? 0,
      maxOrderQuantity: int.tryParse(maxQuantityController.text) ?? 50,
      minOrderQuantity: int.tryParse(minQuantityController.text) ?? 1,
      offerPrice:
          checkBoxState ? int.tryParse(offerPriceController.text) ?? 0 : null,
      maxOrderQuantityForOffer: checkBoxState
          ? int.tryParse(maxQuantityControllerOffer.text) ?? 50
          : null,
      endDate: checkBoxState ? selectedDate : null,
      isOnSale: checkBoxState,
      name: widget.product['name'],
      classification: widget.product['classification'],
      imageUrl: widget.product['imageUrl'],
      note: widget.product['note'],
      manufacturer: widget.product['manufacturer'],
      size: widget.product['size'],
      package: widget.product['package'],
      salesCount: widget.product['salesCount'],
    );
  }
}

/// الـ MultiSheetAddProduct يقوم بعرض قائمة المنتجات المختارة من الـ AddProductCubit
class MultiSheetAddProduct extends StatefulWidget {
  const MultiSheetAddProduct({super.key});

  @override
  _MultiSheetAddProductState createState() => _MultiSheetAddProductState();
}

class _MultiSheetAddProductState extends State<MultiSheetAddProduct> {
  // قائمة من المفاتيح للنماذج باستخدام GlobalKey<_ProductDetailFormState>
  final List<GlobalKey<_ProductDetailFormState>> _formKeys = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductCubit, AddProductState>(
      builder: (context, addState) {
        final selectedProducts = addState is AddProductLoaded
            ? addState.selectedProducts.values.toList()
            : <Map<String, dynamic>>[];

        // التأكد من إنشاء مفتاح لكل نموذج
        if (_formKeys.length != selectedProducts.length) {
          _formKeys.clear();
          for (int i = 0; i < selectedProducts.length; i++) {
            _formKeys.add(GlobalKey<_ProductDetailFormState>());
          }
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: selectedProducts.length,
                          itemBuilder: (context, index) {
                            final product = selectedProducts[index];
                            return Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  key: ValueKey(product['productId']),
                                  title: Row(
                                    children: [
                                      buildProductImage(
                                          context, product, 50, 40),
                                      // Wrap the Column inside an Expanded widget
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['name'],
                                              style: const TextStyle(
                                                color: darkBlueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              product['size'] ?? 'غير محدد',
                                              style: const TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  initiallyExpanded: index == 0,
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  collapsedBackgroundColor: Colors.transparent,
                                  children: [
                                    ProductDetailForm(
                                      product: product,
                                      formKey: _formKeys[index],
                                    ),
                                  ],
                                ));
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customElevatedButtonRectangle(
                              screenWidth:
                                  MediaQuery.of(context).size.width * 0.6,
                              context: context,
                              color: Colors.green,
                              onPressed: () {
                                context
                                    .read<AddProductCubit>()
                                    .addMultipleDynamicProducts(context,
                                        message: 'تمت إضافة المنتجات');
                              },
                              child:
                                  BlocBuilder<AddProductCubit, AddProductState>(
                                builder: (context, state) {
                                  if (state is AddProductLoading) {
                                    return customCircularProgressIndicator(
                                        context: context,
                                        height: 20,
                                        width: 20,
                                        color: whiteColor);
                                  }
                                  return const Text(
                                    'رفع المنتجات',
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              height: 50,
                              child: Column(
                                children: [
                                  const Text(
                                    'عدد  المنتجات ',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_formKeys.length}',
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
