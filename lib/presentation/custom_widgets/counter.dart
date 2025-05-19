import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/add_product/add_product_cubit.dart';

class Counter extends StatelessWidget {
  final TextEditingController controller;
  final int minLimit;
  final int maxLimit;
  const Counter({
    super.key,
    required this.controller,
    required this.minLimit,
    required this.maxLimit,
  });

  void _increment() {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue < maxLimit) {
      controller.text = (currentValue + 1).toString();
    }
  }

  void _decrement() {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > minLimit) {
      controller.text = (currentValue - 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decrement,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicWidth(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _increment,
        ),
      ],
    );
  }
}

class AddProductCounter extends StatelessWidget {
  final TextEditingController controller;
  final int minLimit;
  final int maxLimit;
  final Map<String, dynamic>? product;
  final String theKey;

  const AddProductCounter({
    super.key,
    required this.controller,
    required this.minLimit,
    required this.maxLimit,
    this.product,
    required this.theKey,
  });

  void _increment(BuildContext context) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue < maxLimit) {
      int newValue = currentValue + 1;
      controller.text = newValue.toString();

      if (product != null) {
        final updatedProduct = {
          ...product!,
          theKey: newValue,
        };
        context.read<AddProductCubit>().updateProduct(updatedProduct);
      }
    }
  }

  void _decrement(BuildContext context) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > minLimit) {
      int newValue = currentValue - 1;
      controller.text = newValue.toString();

      if (product != null) {
        final updatedProduct = {
          ...product!,
          theKey: newValue,
        };
        context.read<AddProductCubit>().updateProduct(updatedProduct);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            _decrement(context);
          },
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicWidth(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  isDense: true,
                  border: InputBorder.none,
                ),
                onSubmitted: (String value) {
                  final parsed = int.tryParse(value.trim()) ?? minLimit;

                  controller.text = parsed.toString();
                  controller.selection =
                      TextSelection.collapsed(offset: controller.text.length);

                  if (product != null) {
                    final currentValue = product![theKey] ?? 0;
                    if (parsed != currentValue) {
                      final updatedProduct = {
                        ...product!,
                        theKey: parsed,
                      };
                      context
                          .read<AddProductCubit>()
                          .updateProduct(updatedProduct);
                    }
                  }
                },
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _increment(context);
          },
        ),
      ],
    );
  }
}
