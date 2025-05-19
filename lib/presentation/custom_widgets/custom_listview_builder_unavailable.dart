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
        
        return unAvailableCard(
            context: context,
            index: index,
            productData: widget.data,
            product: widget.data[index]);
      },
    );
  }
}
