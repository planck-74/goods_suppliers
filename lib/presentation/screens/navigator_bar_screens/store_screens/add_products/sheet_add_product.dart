import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/build_product_image.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/add_products/product_details_form.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';

class MultiSheetAddProduct extends StatefulWidget {
  const MultiSheetAddProduct({super.key});

  @override
  _MultiSheetAddProductState createState() => _MultiSheetAddProductState();
}

class _MultiSheetAddProductState extends State<MultiSheetAddProduct> {
  final List<GlobalKey<ProductDetailFormState>> _formKeys = [];

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
            _formKeys.add(GlobalKey<ProductDetailFormState>());
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
