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
  late ProductControllers controllers;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    final productId = widget.product['productId'].toString();
    
    // Get or create controllers for this specific product
    controllers = context.read<AddProductCubit>().getOrCreateControllers(
      productId, 
      widget.product
    );
    
    // Initialize date from product
    selectedDate = widget.product['endDate'];
  }

  void updateProductField(String key, dynamic value) {
    final productId = widget.product['productId'].toString();
    final cubit = context.read<AddProductCubit>();
    final currentProduct = cubit.getProduct(productId);
    
    if (currentProduct != null) {
      final updated = {...currentProduct, key: value};
      cubit.updateProduct(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductCubit, AddProductState>(
      builder: (context, state) {
        final cubit = context.read<AddProductCubit>();
        final productId = widget.product['productId'].toString();
        final product = cubit.getProduct(productId) ?? widget.product;
        
        final widgets = AddProductsWidgets(
          product: product,
          formKey: widget.formKey,
          selectedDate: selectedDate,
          priceController: controllers.priceController,
          maxQuantityController: controllers.maxQuantityController,
          minQuantityController: controllers.minQuantityController,
          offerPriceController: controllers.offerPriceController,
          maxQuantityControllerOffer: controllers.maxQuantityControllerOffer,
          storeId: storeId,
          updateProductField: updateProductField,
          setState: setState,
        );

        return Form(
          key: widget.formKey,
          child: Card(
            color: whiteColor,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  widgets.buildProductInfoSection(product),
                  const Divider(),
                  PriceQuantitySectionAddButton(
                    priceController: controllers.priceController,
                    maxQuantityController: controllers.maxQuantityController,
                    minQuantityController: controllers.minQuantityController,
                    product: product,
                  ),
                  widgets.buildCheckbox(),
                  if (product['isOnSale'] == true) ...[
                    widgets.buildExpirationDateButton(context),
                    const SizedBox(height: 12),
                    widgets.buildOfferPriceSection(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}