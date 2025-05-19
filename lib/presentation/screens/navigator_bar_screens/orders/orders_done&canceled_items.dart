import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/functions/data_formater.dart';
import 'package:goods/data/functions/price_calculator.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/widgets/items_card.dart';

class OrdersDoneCanceledItems extends StatefulWidget {
  const OrdersDoneCanceledItems({super.key});

  @override
  State<OrdersDoneCanceledItems> createState() => _OrState();
}

class _OrState extends State<OrdersDoneCanceledItems> {
  List<TextEditingController> controllers = [];
  List<bool> productSelection = [];

  @override
  Widget build(BuildContext context) {
    List<Map> selectedProducts = context.read<OrdersCubit>().selectedProducts;

    // List<bool> selectionList = context.read<OrdersCubit>().selectionList;

    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ClientModel client = data['client'];
    final OrderModel order = data['order'];
    // int countTrueValues(List<bool> list) {
    //   // Filter the list for true values and get the length of the filtered list
    //   return list.where((item) => item == true).length;
    // }

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Center(child: Text('تفاصيل الطلب')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UpperContainer(
              order: order,
              client: client,
              selectedProducts: selectedProducts,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 232, 232, 232),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: Column(
                  children: List.generate(order.products.length, (index) {
                    return ItemsCard(
                      itemCount: order.products.length,
                      product: order.products[index],
                      controller: controllers.isNotEmpty
                          ? controllers[index]
                          : TextEditingController(),
                      index: index,
                      order: order,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class UpperContainer extends StatelessWidget {
  final OrderModel order;

  final ClientModel client;

  final List selectedProducts;
  const UpperContainer(
      {super.key,
      required this.order,
      required this.client,
      required this.selectedProducts});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.businessName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'ملاحظات:  لا توجد ملاحظات',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.25),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6))),
                    child: BlocBuilder<OrdersCubit, OrdersState>(
                      builder: (context, state) {
                        return Text(
                          'الإجمالي :  ${calculateTotalWithOffer(selectedProducts)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                formatTimestamp(order.date),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
