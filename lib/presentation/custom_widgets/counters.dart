import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/custom_buttons/custom_buttons.dart';

class CounterRow extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onTapRemove;
  final VoidCallback onTap;
  final List<int> initControllers;
  final int index;
  final OrderModel order;
  final dynamic selectionList;
  final dynamic selectedProducts;
  final List<TextEditingController> controllers;
  final int minLimit;
  final int maxLimit;

  const CounterRow({
    super.key,
    required this.controller,
    required this.onTapRemove,
    required this.onTap,
    required this.initControllers,
    required this.index,
    required this.selectedProducts,
    required this.selectionList,
    required this.order,
    required this.controllers,
    required this.minLimit,
    required this.maxLimit,
  });

  @override
  _CounterRowState createState() => _CounterRowState();
}

class _CounterRowState extends State<CounterRow> {
  @override
  Widget build(BuildContext context) {
    int currentValue = int.tryParse(widget.controller.text) ?? widget.minLimit;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customcubidalElevatedButton(
          height: 30,
          width: 30,
          icon: Icons.add,
          iconSize: 20,
          context: context,
          backgroundColor:
              (currentValue < widget.initControllers[widget.index] &&
                      currentValue < widget.maxLimit)
                  ? Colors.green
                  : Colors.green.withOpacity(0.6),
          iconColor: whiteColor,
          onPressed: () async {
            if (currentValue < widget.initControllers[widget.index] &&
                currentValue < widget.maxLimit) {
              increment();
              await context.read<OrdersCubit>().initSelectedProducts(
                    widget.order.products,
                    widget.selectionList,
                    widget.selectedProducts,
                    widget.controllers,
                  );
            }
          },
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 30),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: IntrinsicWidth(
                child: Text(
                  currentValue.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        customcubidalElevatedButton(
          height: 30,
          width: 30,
          child: const Text(
            '−',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),
          iconSize: 10,
          context: context,
          backgroundColor: Colors.red,
          iconColor: whiteColor,
          onPressed: () async {
            if (currentValue > widget.minLimit) {
              decrement();
              await context.read<OrdersCubit>().initSelectedProducts(
                    widget.order.products,
                    widget.selectionList,
                    widget.selectedProducts,
                    widget.controllers,
                  );
            }
          },
        ),
      ],
    );
  }

  void increment() {
    int currentValue = int.tryParse(widget.controller.text) ?? widget.minLimit;
    if (currentValue < widget.maxLimit) {
      setState(() {
        widget.controller.text = (currentValue + 1).toString();
      });
    }
  }

  void decrement() {
    int currentValue = int.tryParse(widget.controller.text) ?? widget.minLimit;
    if (currentValue > widget.minLimit) {
      setState(() {
        widget.controller.text = (currentValue - 1).toString();
      });
    }
  }

  void validateInput(String value) {
    int newValue = int.tryParse(value) ?? widget.minLimit;
    if (newValue < widget.minLimit) {
      widget.controller.text = widget.minLimit.toString();
    } else if (newValue > widget.maxLimit) {
      widget.controller.text = widget.maxLimit.toString();
    }
  }

  void enforceLimits() {
    int currentValue = int.tryParse(widget.controller.text) ?? widget.minLimit;
    if (currentValue < widget.minLimit) {
      widget.controller.text = widget.minLimit.toString();
    } else if (currentValue > widget.maxLimit) {
      widget.controller.text = widget.maxLimit.toString();
    }
  }
}
