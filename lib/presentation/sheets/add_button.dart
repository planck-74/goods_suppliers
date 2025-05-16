import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';

class AddButton extends StatelessWidget {
  final Map<String, dynamic> product;

  const AddButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddProductCubit, AddProductState>(
      builder: (context, state) {
        final productId = product['productId'].toString();
        bool isSelected = false;

        if (state is AddProductLoaded) {
          isSelected = state.selectedProducts.containsKey(productId);
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: customElevatedButtonRectangle(
            color: isSelected ? Colors.red : Colors.green,
            screenHeight: 35,
            screenWidth: 100,
            context: context,
            child: isSelected
                ? const Text('حذف', style: TextStyle(color: whiteColor))
                : const Text('إضافة', style: TextStyle(color: whiteColor)),
            onPressed: () {
              HapticFeedback.lightImpact();
              final updatedProduct = {
                ...product,
                'availability': true,
                'endDate': null,
                'isOnSale': false,
                'maxOrderQuantity': 10,
                'maxOrderQuantityForOffer': null,
                'minOrderQuantity': 1,
                'offerPrice': null,
                'price': 0,
              };

              context.read<AddProductCubit>().selectProducts(updatedProduct);
              print(context.read<AddProductCubit>().selectedProducts);
            },
          ),
        );
      },
    );
  }
}
