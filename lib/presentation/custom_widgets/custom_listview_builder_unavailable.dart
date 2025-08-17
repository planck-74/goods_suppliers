import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/unavailable/unavailable_cubit.dart';
import 'package:goods/presentation/cards/add_products_card.dart';
import 'package:goods/presentation/cards/card_unavailable.dart';

class UnAvailableProductsList extends StatefulWidget {
  final List<dynamic> data;
  final String storeId;
  final bool isLoadingMore;

  const UnAvailableProductsList({
    super.key,
    required this.data,
    required this.storeId,
    this.isLoadingMore = false,
  });

  @override
  _UnAvailableProductsListState createState() => _UnAvailableProductsListState();
}

class _UnAvailableProductsListState extends State<UnAvailableProductsList> {
  late List<dynamic> productData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    productData = widget.data;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant UnAvailableProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      productData = widget.data;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<UnAvailableCubit>()
          .fetchNextUnAvailableProductsPage(widget.storeId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = productData.length + (widget.isLoadingMore ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < productData.length) {
          return unAvailableCard(
            product: productData[index],
         
            index: index,
            productData: productData, context: context,
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class AddListViewProducts extends StatefulWidget {
  final List<dynamic> data;
  final bool isLoadingMore;
  final void Function()? onLoadMore;

  const AddListViewProducts(
      {super.key,
      required this.data,
      this.isLoadingMore = false,
      this.onLoadMore});

  @override
  State<AddListViewProducts> createState() => _AddListViewProductsState();
}

class _AddListViewProductsState extends State<AddListViewProducts> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.onLoadMore != null) widget.onLoadMore!();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = widget.data.length + (widget.isLoadingMore ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < widget.data.length) {
          final product = widget.data[index] as Map<String, dynamic>;
          return AddProductsCard(product: product);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

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
