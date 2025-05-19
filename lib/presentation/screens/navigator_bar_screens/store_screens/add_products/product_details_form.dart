import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/sheets/price_quantity_section.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/add_products/widgets/add_products_widgets.dart';

class ProductDetailForm extends StatefulWidget {
  final Map<String, dynamic> product;
  final GlobalKey<ProductDetailFormState> formKey;

  const ProductDetailForm({
    super.key,
    required this.product,
    required this.formKey,
  });

  @override
  ProductDetailFormState createState() => ProductDetailFormState();
}

class ProductDetailFormState extends State<ProductDetailForm> {
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
    final addProductsWidgets = AddProductsWidgets(
      product: context
              .read<AddProductCubit>()
              .getProduct(widget.product['productId']) ??
          widget.product,
      formKey: widget.formKey,
      isAvailable: isAvailable,
      checkBoxState: checkBoxState,
      selectedDate: selectedDate,
      priceController: priceController,
      maxQuantityController: maxQuantityController,
      minQuantityController: minQuantityController,
      offerPriceController: offerPriceController,
      maxQuantityControllerOffer: maxQuantityControllerOffer,
      storeId: storeId,
      updateProductField: updateProductField,
      setState: setState,
    );
    return BlocListener<AddProductCubit, AddProductState>(
      listener: (context, state) {
        final product = context
                .read<AddProductCubit>()
                .getProduct(widget.product['productId']) ??
            widget.product;

        void safeUpdate(TextEditingController controller, String? newValueRaw) {
          final newValue = newValueRaw?.trim() ?? '';
          final current = controller.text.trim();

          if (int.tryParse(current) == int.tryParse(newValue)) return;

          final oldSelection = controller.selection;
          controller.text = newValue;
          controller.selection = oldSelection;
        }

        safeUpdate(priceController, product['price']?.toString());
        safeUpdate(
            minQuantityController, product['minOrderQuantity']?.toString());
        safeUpdate(
            maxQuantityController, product['maxOrderQuantity']?.toString());
        safeUpdate(offerPriceController, product['offerPrice']?.toString());
        safeUpdate(maxQuantityControllerOffer,
            product['maxOrderQuantityForOffer']?.toString());

        setState(() {
          isAvailable = product['availability'] ?? true;
          checkBoxState = product['isOnSale'] ?? false;
          selectedDate = product['endDate'];
        });
      },
      child: BlocBuilder<AddProductCubit, AddProductState>(
        builder: (context, state) {
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
                    addProductsWidgets.buildProductInfoSection(product),
                    const Divider(),
                    PriceQuantitySectionAddButton(
                      priceController: priceController,
                      maxQuantityController: maxQuantityController,
                      minQuantityController: minQuantityController,
                      product: product,
                    ),
                    addProductsWidgets.buildCheckbox(),
                    if (checkBoxState) ...[
                      addProductsWidgets.buildExpirationDateButton(context),
                      const SizedBox(height: 12),
                      addProductsWidgets.buildOfferPriceSection(),
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
}
