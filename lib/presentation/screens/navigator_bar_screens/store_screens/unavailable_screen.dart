import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_listview_builder_unavailable.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/sheet_classification_unavailable.dart';

class UnAvailable extends StatefulWidget {
  const UnAvailable({super.key});

  @override
  State<UnAvailable> createState() => _UnAvailableState();
}

class _UnAvailableState extends State<UnAvailable> {
  @override
  void initState() {
    super.initState();
    context.read<UnAvailableCubit>().fetchInitialUnAvailableProducts(storeId);
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
                const SizedBox(
                  width: 12,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      customOutlinedButton(
                        onPressed: () => showCLassifiactionOfferSheet(context),
                        width: 80,
                        height: 25,
                        context: context,
                        child: const Row(
                          mainAxisSize: MainAxisSize
                              .min, // Adjust the size based on content
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center content horizontally
                          children: [
                            Text(
                              '  تصنيف',
                              style: TextStyle(color: darkBlueColor),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            ImageIcon(
                                size: 12,
                                color: primaryColor,
                                AssetImage(
                                  'assets/icons/triangle.png',
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      customOutlinedButton(
                        onPressed: () => context
                            .read<UnAvailableCubit>()
                            .fetchInitialUnAvailableProducts(storeId),
                        width: 57,
                        height: 25,
                        context: context,
                        child: const Row(
                          mainAxisSize: MainAxisSize
                              .min, // Adjust the size based on content
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center content horizontally
                          children: [
                            Text(
                              'إلغاء ×',
                              style: TextStyle(color: primaryColor),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      )
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
                await context
                    .read<UnAvailableCubit>()
                    .fetchInitialUnAvailableProducts(storeId);
              },
              child: BlocBuilder<UnAvailableCubit, UnAvailableState>(
                builder: (context, state) {
                  if (state is UnavailableLoading) {
                    return Center(
                        child: customCircularProgressIndicator(
                            context: context, height: 50, width: 50));
                  } else if (state is UnavailableLoaded ||
                      state is UnavailableLoadingMore) {
                    final unAvailableProducts = state is UnavailableLoaded
                        ? state.unAvailableProducts
                        : (state as UnavailableLoadingMore).products;
                    final isLoadingMore = state is UnavailableLoadingMore;
                    return unAvailableProducts.isEmpty
                        ? const Center(
                            child: Text(
                            'لا توجد منتجات لعرضها',
                            style: TextStyle(color: Colors.black),
                          ))
                        : ListViewUnavailable(
                            data: unAvailableProducts,
                            isLoadingMore: isLoadingMore);
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

void showCLassifiactionOfferSheet(
  BuildContext context,
) {
  showModalBottomSheet(
    backgroundColor: whiteColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const SheetClassificationUnavailable();
    },
  );
}
