import 'package:flutter/material.dart';
import 'package:goods/presentation/cards/card_available.dart';

class AvailableProductsList extends StatefulWidget {
  final List<dynamic> data;
  final String storeId;

  const AvailableProductsList(
      {super.key, required this.data, required this.storeId});

  @override
  _AvailableProductsListState createState() => _AvailableProductsListState();
}

class _AvailableProductsListState extends State<AvailableProductsList> {
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
        final dynamicData =
            productData[index]['dynamicData'] as Map<String, dynamic>;
        final staticData =
            productData[index]['staticData'] as Map<String, dynamic>?;

        return AvailableCard(
          staticData: staticData,
          dynamicData: dynamicData,
          storeId: widget.storeId,
          index: index,
          productData: productData,
        );
      },
    );
  }
}
