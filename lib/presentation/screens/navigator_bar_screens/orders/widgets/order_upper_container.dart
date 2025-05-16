import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/functions/data_formater.dart';
import 'package:goods/data/functions/price_calculator.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';

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
