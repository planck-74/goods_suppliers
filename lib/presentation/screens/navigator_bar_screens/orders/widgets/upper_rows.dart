import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods/data/functions/data_formater.dart';
import 'package:goods/data/functions/open_google_maps.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/rectangle_Elevated_button.dart';
import 'package:goods/presentation/custom_widgets/top_bar.dart';

Widget upperRows(BuildContext context, OrderModel order, ClientModel client) {
  return Column(
    children: [
      Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${client.businessName} - ${client.government} ${client.town}',
                style: const TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  const Text(
                    '🗺️',
                    style: TextStyle(fontSize: 24),
                  ),
                  TextButton(
                    onPressed: () {
                      openGoogleMaps(client.geoLocation.latitude,
                          client.geoLocation.longitude);
                    },
                    child: Text(
                      client.addressTyped,
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
              Text(
                formatTimestamp(order.date),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Positioned(
              top: 40,
              left: 0,
              child: ElevatedButton2(
                child: const Text(
                  'نسخ',
                  style: TextStyle(color: whiteColor),
                ),
                width: 75,
                height: 30,
                formKey: '',
                onPressed: () {
                  final latitude = client.geoLocation.latitude;
                  final longitude = client.geoLocation.longitude;
                  final googleMapsUrl =
                      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

                  Clipboard.setData(ClipboardData(text: googleMapsUrl));

                  showTopBar(
                      context: context, message: 'تم نسخ الموقع إلى الحافظة');
                },
              )),
        ],
      ),
      const Divider(),
      Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الفاتورة : ${order.totalWithOffer} جـ',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 54,
              ),
              Text(
                'عدد الأصناف : ${order.products.length}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      const Divider(),
    ],
  );
}
