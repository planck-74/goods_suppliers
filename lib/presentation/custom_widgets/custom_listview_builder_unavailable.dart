import 'package:flutter/material.dart';
import 'package:goods/presentation/cards/add_products_card.dart';
import 'package:goods/presentation/cards/card_unavailable.dart';

Widget buildList(List data) {
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (context, index) {
      // Remove .data() since data[index] is already a Map.
      final product = data[index] as Map<String, dynamic>;
      return AddProductsCard(product: product);
    },
  );
}

class ListViewUnavailable extends StatefulWidget {
  final List<dynamic> data;

  const ListViewUnavailable({super.key, required this.data});

  @override
  State<ListViewUnavailable> createState() => _ListViewUnavailableState();
}

class _ListViewUnavailableState extends State<ListViewUnavailable> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        // These keys already return maps, so no need for extra processing.
        final dynamicData =
            widget.data[index]['dynamicData'] as Map<String, dynamic>;
        final staticData = widget.data[index]['staticData']
            as Map<String, dynamic>?; // Nullable, if needed

        return unAvailableCard(
          staticData!,
          context,
          dynamicData,
          index: index,
          productData: widget.data,
        );
      },
    );
  }
}
