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

class CanceledOrdersCard extends StatefulWidget {
  final ClientModel client;
  final OrderModel order;
  final List orders;
  final String state;

  const CanceledOrdersCard({
    super.key,
    required this.order,
    required this.client,
    required this.state,
    required this.orders,
  });

  @override
  State<CanceledOrdersCard> createState() => _CanceledOrdersCardState();
}

class _CanceledOrdersCardState extends State<CanceledOrdersCard> {
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
    OrderModel order = widget.order;
    ClientModel client = widget.client;
    List<Map> selectedProducts = context.read<OrdersCubit>().selectedProducts;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Adjust the radius here
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(6))),
        width: MediaQuery.of(context).size.width * .96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            upperRows(context, order, client),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تم الرفض بتاريخ',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        formatTimestamp(order.doneAt ?? order.date),
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider()
                ],
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (BuildContext context) {
                            return ClientDetailsSheet(client: widget.client);
                          },
                        );
                      }),
                ),
                const SizedBox(
                  width: 12,
                ),
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
                        final c =
                            context.read<OrdersCubit>().controllersList(order);

                        final k =
                            context.read<OrdersCubit>().productSelection(order);
                        await context.read<OrdersCubit>().initSelectedProducts(
                            order.products, k, selectedProducts, c);
                        Navigator.pushNamed(context, '/PreparingItemsScreen',
                            arguments: {
                              'order': order,
                              'client': client,
                              'initControllers': initControllers
                            });
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
