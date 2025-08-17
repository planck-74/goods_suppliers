import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods/data/functions/data_formater.dart';
import 'package:goods/data/functions/geoPointToText.dart';
import 'package:goods/data/functions/price_calculator.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/rectangle_Elevated_button.dart';
import 'package:goods/presentation/sheets/client_sheet.dart';

class DoneCanceledCards extends StatelessWidget {
  final ClientModel client;
  final OrderModel order;
  final List orders;
  final String state;
  final VoidCallback onPressed1;
  final VoidCallback? onPressed2;

  const DoneCanceledCards({
    super.key,
    required this.order,
    required this.client,
    required this.state,
    required this.onPressed1,
    this.onPressed2,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth * 0.96;
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
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              '🗺️',
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        Text(
                          formatTimestamp(order.date),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    ElevatedButton2(
                      child: const Text(
                        'نسخ',
                        style: TextStyle(color: whiteColor),
                      ),
                      width: 75,
                      formKey: '',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                              text: geoLocationToText(client.geoLocation)),
                        );
                      },
                      height: 30,
                    ),
                  ],
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي الفاتورة : ${calculateTotalWithOffer(order.products)} جـ',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'عدد الأصناف : ${order.products.length}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton2(
                      elevation: 5,
                      height: 50,
                      width: constraints.maxWidth * 0.45,
                      color: Colors.green,
                      sideColor: Colors.green,
                      child: Text(
                        state,
                        style: const TextStyle(fontSize: 18, color: whiteColor),
                      ),
                      onPressed: onPressed1,
                    ),
                    ElevatedButton2(
                      elevation: 5,
                      height: 50,
                      width: constraints.maxWidth * 0.45,
                      color: whiteColor,
                      sideColor: const Color.fromARGB(255, 215, 215, 215),
                      child: const Text(
                        'الفاتورة',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      onPressed: () async {
                        Navigator.pushNamed(
                          context,
                          '/OrderItems',
                          arguments: {
                            'order': order,
                            'client': client,
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton2(
                    elevation: 5,
                    height: 50,
                    width: constraints.maxWidth * 0.9,
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
                          return ClientDetailsSheet(client: client);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
