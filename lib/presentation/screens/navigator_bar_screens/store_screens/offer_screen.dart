import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_cubit.dart';
import 'package:goods/business_logic/cubits/offer_cubit/offer_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';
import 'package:goods/presentation/custom_widgets/custom_listview_builder_offer.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';
import 'package:goods/presentation/sheets/sheet_classification_offer.dart';

class Offer extends StatefulWidget {
  const Offer({super.key});

  @override
  State<Offer> createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  @override
  void initState() {
    super.initState();
    context.read<OfferCubit>().fetchCombinedOnSaleProducts(storeId);
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            .read<OfferCubit>()
                            .fetchCombinedOnSaleProducts(storeId),
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
                return context
                    .read<OfferCubit>()
                    .fetchCombinedOnSaleProducts(storeId);
              },
              child: BlocBuilder<OfferCubit, OfferState>(
                builder: (context, state) {
                  if (state is OfferLoading) {
                    return Center(
                        child: customCircularProgressIndicator(
                            context: context, height: 50, width: 50));
                  } else if (state is OfferLoaded) {
                    final offerProducts = state.offerProducts;
                    return offerProducts.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد منتجات لعرضها',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : offerProductsList(
                            data: offerProducts, storeId: storeId ?? '');
                  } else if (state is OfferError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل المنتجات: ${state.message}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
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
      return const SheetClassificationOffer();
    },
  );
}
