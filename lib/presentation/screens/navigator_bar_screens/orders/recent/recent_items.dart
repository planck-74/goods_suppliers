import 'package:flutter/material.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/recent/recent_items_card.dart';

Widget recentItems({
  required List products,
  required List<bool> selectionList,
  required List<TextEditingController> controllers,
  required Function(bool, int) onCheckBoxChanged,
  required dynamic order,
  required List<Map<dynamic, dynamic>> selectedProducts,
  required List<int> initControllers,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          color: Color.fromARGB(255, 232, 232, 232),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        children: List.generate(products.length, (index) {
          return RecentItemsCard(
            checkBoxValue:
                selectionList.isNotEmpty ? selectionList[index] : true,
            itemCount: products.length,
            product: products[index]['product'],
            initControllers: initControllers,
            controller: controllers.isNotEmpty
                ? controllers[index]
                : TextEditingController(),
            index: index,
            onCheckBoxChanged: (bool value, index) {
              onCheckBoxChanged(value, index);
            },
            order: order,
            selectionList: selectionList,
            selectedProducts: selectedProducts,
            controllers: controllers,
          );
        }),
      ),
    ),
  );
}
