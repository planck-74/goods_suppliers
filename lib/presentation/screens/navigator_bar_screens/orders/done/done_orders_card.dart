import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/data/functions/data_formater.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/rectangle_Elevated_button.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/widgets/upper_rows.dart';
import 'package:goods/presentation/sheets/client_sheet.dart';

class DoneOrdersCard extends StatefulWidget {
  final ClientModel client;
  final OrderModel order;
  final List orders;
  final String state;

  const DoneOrdersCard({
    super.key,
    required this.order,
    required this.client,
    required this.state,
    required this.orders,
  });

  @override
  State<DoneOrdersCard> createState() => _DoneOrdersCardState();
}

class _DoneOrdersCardState extends State<DoneOrdersCard> {
  List<int> initControllers = [];

  @override
  void initState() {
    super.initState();
    initControllers = List.generate(
      widget.order.products.length,
      (index) {
        final controllerValue = widget.order.products[index]['controller'] ?? 0;
        return controllerValue;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final client = widget.client;
    final selectedProducts = context.read<OrdersCubit>().selectedProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.96;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                upperRows(context, order, client),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'تم التوصيل بتاريخ',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          Text(
                            formatTimestamp(order.doneAt ?? order.date),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // استخدام Expanded لجعل الأزرار تتكيف مع عرض الشاشة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton2(
                        elevation: 5,
                        height: 50,
                        width: double.infinity,
                        color: const Color(0xFF012340),
                        sideColor: const Color(0xFF012340),
                        child: const Text(
                          'العميل',
                          style: TextStyle(fontSize: 18, color: whiteColor),
                        ),
                        onPressed: () async {
                          showModalBottomSheet(
                            backgroundColor: whiteColor,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (BuildContext context) {
                              return ClientDetailsSheet(client: widget.client);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton2(
                        elevation: 5,
                        height: 50,
                        width: double.infinity,
                        color: whiteColor,
                        sideColor: const Color.fromARGB(255, 215, 215, 215),
                        child: const Text(
                          'الفاتورة',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        onPressed: () async {
                          final c = context
                              .read<OrdersCubit>()
                              .controllersList(order);
                          final k = context
                              .read<OrdersCubit>()
                              .productSelection(order);
                          await context
                              .read<OrdersCubit>()
                              .initselectedProducts(
                                  order.products, k, selectedProducts, c);
                          Navigator.pushNamed(context, '/PreparingItemsScreen',
                              arguments: {
                                'order': order,
                                'client': client,
                                'initControllers': initControllers
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
