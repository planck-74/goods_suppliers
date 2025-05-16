import 'package:flutter/material.dart';
import 'package:goods/presentation/custom_widgets/counter.dart';

class PriceQuantitySection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController minQuantityController;
  final TextEditingController maxQuantityController;

  const PriceQuantitySection({
    super.key,
    required this.priceController,
    required this.minQuantityController,
    required this.maxQuantityController,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Price Row
        buildFieldRow(
          context: context,
          label: 'السعر',
          controller: priceController,
          minLimit: 1,
          maxLimit: 9999,
        ),
        const SizedBox(height: 10),
        // Maximum Quantity Row
        buildFieldRow(
          context: context,
          label: 'أقل كمية للطلب',
          controller: minQuantityController,
          minLimit: 1,
          maxLimit: 100,
        ),
        const SizedBox(height: 10),
        // Maximum Quantity Row

        // Maximum Quantity Row
        buildFieldRow(
          context: context,
          label: 'أقصى كمية للطلب',
          controller: maxQuantityController,
          minLimit: 1,
          maxLimit: 100,
        ),
      ],
    );
  }
}

Widget buildFieldRow({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required int minLimit,
  required int maxLimit,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
      ),
      Counter(controller: controller, minLimit: minLimit, maxLimit: maxLimit)
    ],
  );
}

class PriceQuantitySectionAddButton extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController minQuantityController;
  final TextEditingController maxQuantityController;
  final Map<String, dynamic>? product;

  const PriceQuantitySectionAddButton({
    super.key,
    required this.priceController,
    required this.minQuantityController,
    required this.maxQuantityController,
    this.product,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildFieldRowAddButton(
          context: context,
          label: 'السعر',
          controller: priceController,
          minLimit: 1,
          maxLimit: 9999,
          product: product ?? {},
          theKey: 'price',
        ),
        const SizedBox(height: 10),
        // Maximum Quantity Row
        buildFieldRowAddButton(
          context: context,
          label: 'أقل كمية للطلب',
          controller: minQuantityController,
          minLimit: 1,
          maxLimit: 100,
          product: product ?? {},
          theKey: 'minOrderQuantity',
        ),
        const SizedBox(height: 10),

        buildFieldRowAddButton(
            context: context,
            label: 'أقصى كمية للطلب',
            controller: maxQuantityController,
            minLimit: 1,
            maxLimit: 100,
            product: product ?? {},
            theKey: 'maxOrderQuantity'),
      ],
    );
  }
}

Widget buildFieldRowAddButton({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required int minLimit,
  required int maxLimit,
  required Map<String, dynamic> product,
  required String theKey,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
      ),
      AddProductCounter(
        controller: controller,
        minLimit: minLimit,
        maxLimit: maxLimit,
        product: product,
        theKey: theKey,
      )
    ],
  );
}
