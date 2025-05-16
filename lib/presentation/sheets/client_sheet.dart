import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goods/data/functions/open_google_maps.dart';
import 'package:goods/presentation/custom_widgets/top_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:goods/data/models/client_model.dart';

class ClientDetailsSheet extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsSheet({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'بيانات العميل',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          /// اسم المكان
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const ImageIcon(AssetImage('assets/images/market.png')),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${client.businessName} - ${client.category}',
                        style: const TextStyle(fontSize: 16)),
                    const Text('اسم المكان',
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                  ],
                ),
              ],
            ),
          ),

          /// رقم الهاتف الأول
          GestureDetector(
            onTap: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: client.phoneNumber);
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
              } else {
                showTopBar(
                    color: Colors.red,
                    context: context,
                    message:
                        'لا يمكن فتح تطبيق الهاتف،إضغط مطولاً لنسخ الرقم !');
              }
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: client.phoneNumber ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رقم الهاتف!')),
              );
              showTopBar(context: context, message: 'تم النسخ إلى الحافظة ');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.phoneNumber ?? 'غير متوفر',
                          style: const TextStyle(fontSize: 16)),
                      const Text('رقم الهاتف',
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              final Uri phoneUri =
                  Uri(scheme: 'tel', path: client.secondPhoneNumber);
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
              } else {
                showTopBar(
                    color: Colors.red,
                    context: context,
                    message:
                        'لا يمكن فتح تطبيق الهاتف،إضغط مطولاً لنسخ الرقم !');
              }
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: client.secondPhoneNumber));

              showTopBar(context: context, message: 'تم النسخ إلى الحافظة ');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_android_sharp,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.secondPhoneNumber,
                          style: const TextStyle(fontSize: 16)),
                      const Text('رقم هاتف أخر',
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              openGoogleMaps(
                  client.geoPoint.latitude, client.geoPoint.longitude);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.map_outlined,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${client.government} ${client.town}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Text('العنوان',
                          style:
                              TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
