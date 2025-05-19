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
  @override
  void initState() {
    super.initState();
    context.read<AddProductCubit>().initializeControllers(widget.product);
  }

  void updateProductField(String key, dynamic value) {
    final current = context
            .read<AddProductCubit>()
            .getProduct(widget.product['productId']) ??
        widget.product;
    final updated = {...current, key: value};
    context.read<AddProductCubit>().updateProduct(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductCubit, AddProductState>(
      builder: (context, state) {
        final cubit = context.read<AddProductCubit>();
        final product =
            cubit.getProduct(widget.product['productId']) ?? widget.product;
        final widgets = AddProductsWidgets(
          product: product,
          formKey: widget.formKey,
          selectedDate: cubit.selectedDate,
          priceController: cubit.priceController,
          maxQuantityController: cubit.maxQuantityController,
          minQuantityController: cubit.minQuantityController,
          offerPriceController: cubit.offerPriceController,
          maxQuantityControllerOffer: cubit.maxQuantityControllerOffer,
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
                    priceController: cubit.priceController,
                    maxQuantityController: cubit.maxQuantityController,
                    minQuantityController: cubit.minQuantityController,
                    product: product,
                  ),
                  widgets.buildCheckbox(),
                  if (cubit.isOnSale) ...[
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
