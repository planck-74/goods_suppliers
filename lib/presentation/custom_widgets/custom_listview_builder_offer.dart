import 'package:flutter/material.dart';
import 'package:goods/presentation/cards/card_offer.dart';

class offerProductsList extends StatefulWidget {
  final List<dynamic> data;
  final String storeId;

  const offerProductsList(
      {super.key, required this.data, required this.storeId});

  @override
  _offerProductsListState createState() => _offerProductsListState();
}

class _offerProductsListState extends State<offerProductsList> {
  late List<dynamic> productData;

  @override
  void initState() {
    super.initState();
    productData = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: productData.length,
      itemBuilder: (context, index) {
        return OfferCard(
          product: productData[index],
          storeId: widget.storeId,
          index: index,
          productData: productData,
        );
      },
    );
  }
}
