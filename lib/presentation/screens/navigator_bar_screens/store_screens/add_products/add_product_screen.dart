import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';
import 'package:goods/business_logic/cubits/search_products/search_products_cubit.dart';
import 'package:goods/business_logic/cubits/supplier_data/controller_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/custom_widgets/custom_listview_builder_unavailable.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/product_searchtext_field.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/add_products/sheet_add_product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late ControllerCubit controllerCubit;

  @override
  void initState() {
    super.initState();
    controllerCubit = context.read<ControllerCubit>();
    context.read<SearchProductsCubit>().fetchAvailableProductsNotInStore();
  }

  @override
  void dispose() {
    controllerCubit.clearSearchDetails();
    controllerCubit.searchProduct.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final controller = controllerCubit.searchProduct;

    return Scaffold(
      appBar: customAppBar(
        context,
        const Text(
          'قائمة المنتجات',
          style: TextStyle(color: whiteColor),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth * 0.98,
          child: Column(
            children: [
              ProductSearchTextField(
                  controller: controller, screenWidth: screenWidth),
              Expanded(
                child: BlocBuilder<SearchProductsCubit, SearchProductsState>(
                  builder: (context, state) {
                    if (state is SearchProductsLoading) {
                      return Center(
                        child: customCircularProgressIndicator(
                            context: context, height: 50, width: 50),
                      );
                    } else if (state is SearchProductsLoaded ||
                        state is SearchProductsLoadingMore) {
                      final searchResults = state is SearchProductsLoaded
                          ? state.products
                          : (state as SearchProductsLoadingMore).products;
                      final isLoadingMore = state is SearchProductsLoadingMore;
                      return searchResults.isEmpty
                          ? _buildEmptyState()
                          : AddListViewProducts(
                              data: searchResults,
                              isLoadingMore: isLoadingMore,
                              onLoadMore: () => context
                                  .read<SearchProductsCubit>()
                                  .fetchNextAvailableProductsNotInStorePage(),
                            );
                    } else if (state is SearchProductsInitial) {
                      List products = state.products;
                      return buildList(products);
                    }
                    return _buildInitialState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          context.watch<AddProductCubit>().selectedProducts.isNotEmpty
              ? SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    backgroundColor: darkBlueColor,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const MultiSheetAddProduct(),
                      );
                    },
                    child: const Text(
                      'إضافة البيانات',
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'لا يوجد منتج بهذا الاسم',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text(
        'قم بالبحث عن المنتج الذي تريد إضافته',
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }
}
