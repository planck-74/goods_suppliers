import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/available/available_cubit.dart';
import 'package:goods/presentation/cards/card_available.dart';

class AvailableProductsList extends StatefulWidget {
  final List<dynamic> data;
  final String storeId;
  final bool isLoadingMore;

  const AvailableProductsList({
    super.key,
    required this.data,
    required this.storeId,
    this.isLoadingMore = false,
  });

  @override
  _AvailableProductsListState createState() => _AvailableProductsListState();
}

class _AvailableProductsListState extends State<AvailableProductsList> {
  late List<dynamic> productData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    productData = widget.data;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant AvailableProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      productData = widget.data;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<AvailableCubit>()
          .fetchNextAvailableProductsPage(widget.storeId);
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
          return AvailableCard(
            product: productData[index],
            storeId: widget.storeId,
            index: index,
            productData: productData,
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
