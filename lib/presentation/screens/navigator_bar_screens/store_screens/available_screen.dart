import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/business_logic/cubits/available/available_state.dart';
import 'package:goods/business_logic/cubits/dynamic_cubit/dynamic_product_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_listview_builder_available.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/sheet_classification_available.dart';

class Available extends StatefulWidget {
  const Available({super.key});

  @override
  State<Available> createState() => _AvailableState();
}

class _AvailableState extends State<Available> {
  @override
  void initState() {
    super.initState();
    context.read<AvailableCubit>().available(storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      customOutlinedButton(
                        onPressed: () =>
                            showCLassifiactionAvailableSheet(context),
                        width: 80,
                        height: 25,
                        context: context,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '  تصنيف',
                              style: TextStyle(color: darkBlueColor),
                            ),
                            SizedBox(width: 5),
                            ImageIcon(
                              size: 12,
                              color: primaryColor,
                              AssetImage('assets/icons/triangle.png'),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      customOutlinedButton(
                        onPressed: () => context
                            .read<DynamicProductCubit>()
                            .syncStoreProducts(context, storeId),
                        width: 80,
                        height: 25,
                        context: context,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'مزامنة 🔄',
                              style: TextStyle(color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      customOutlinedButton(
                        onPressed: () =>
                            context.read<AvailableCubit>().available(storeId),
                        width: 57,
                        height: 25,
                        context: context,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إلغاء ×',
                              style: TextStyle(color: primaryColor),
                            ),
                            SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                await context.read<AvailableCubit>().available(storeId);
              },
              child: BlocBuilder<AvailableCubit, AvailableState>(
                builder: (context, state) {
                  if (state is AvailableLoading) {
                    return Center(
                        child: customCircularProgressIndicator(
                            context: context, height: 50, width: 50));
                  } else if (state is AvailableLoaded) {
                    final availableProducts = state.AvailableProducts;
                    return availableProducts.isEmpty
                        ? const Center(
                            child: Text(
                            'لا توجد منتجات لعرضها',
                            style: TextStyle(color: Colors.black),
                          ))
                        : AvailableProductsList(
                            data: availableProducts, storeId: storeId);
                  }
                  return const Center(
                      child: Text(
                    'لا توجد منتجات لعرضها',
                    style: TextStyle(color: Colors.black),
                  ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showCLassifiactionAvailableSheet(
  BuildContext context,
) {
  showModalBottomSheet(
    backgroundColor: whiteColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const SheetClassificationAvailable();
    },
  );
}
