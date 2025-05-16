import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/search_products/search_products_cubit.dart';
import 'package:goods/presentation/custom_widgets/custom_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';

class ProductSearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final double screenWidth;

  const ProductSearchTextField({
    super.key,
    required this.controller,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return customTextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      width: screenWidth,
      labelText: 'البحث',
      context: context,
      onChanged: (value) {
        context.read<ControllerCubit>().clearSearchDetails();

        context.read<SearchProductsCubit>().searchProducts(value);
      },
    );
  }
}
