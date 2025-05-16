import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/dialog_confirmation.dart';
import 'package:goods/presentation/custom_widgets/rectangle_Elevated_button.dart';

class LowerContainer extends StatelessWidget {
  final OrderModel order;
  final ClientModel client;
  final List<TextEditingController> controllers;
  final List<bool> selectionList;

  final VoidCallback onPressed;

  final List selectedProducts;

  const LowerContainer(
      {super.key,
      required this.order,
      required this.client,
      required this.controllers,
      required this.selectionList,
      required this.selectedProducts,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton2(
            elevation: 5,
            height: 60,
            width: 170,
            color: Colors.green,
            sideColor: Colors.green,
            child: const Text(
              'بدء التحضير',
              style: TextStyle(fontSize: 20, color: whiteColor),
            ),
            onPressed: () => showConfirmationDialog(
              context: context,
              content: 'هل أنت جاهز لتحضير هذا الطلب',
              onConfirm: () {
                // startPreparing(context, order);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton2(
            elevation: 5,
            height: 60,
            width: 170,
            color: Colors.red.withOpacity(0.9),
            sideColor: Colors.red,
            child: const Text(
              'رفض',
              style: TextStyle(fontSize: 20, color: whiteColor),
            ),
            onPressed: () => showConfirmationDialog(
              context: context,
              content: 'هل أنت متاكد من رفض الطلب',
              elevatedButtonbackgroundColor: Colors.red,
              elevatedButtonName: 'رفض',
              onConfirm: () {
                //  => cancel(context, order)
              },
            ),
          ),
        ],
      ),
    );
  }
}
