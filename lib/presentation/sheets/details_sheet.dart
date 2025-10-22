import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/models/order_model.dart';

class DetailsSheet extends StatelessWidget {
  final OrderModel order;

  const DetailsSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isReDelivered = order.reDelivery == true;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'تفاصيل الطلب المهمل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1.2),
            const SizedBox(height: 12),

            // النص الأساسي
            RichText(
              textAlign: TextAlign.justify,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                      text: 'لقد تم نقل هذا الطلب إلى قائمة المهملات لمرور '),
                  TextSpan(
                    text: '3 أيام ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: 'دون اتخاذ إجراء حياله، وتم توقيع غرامة قدرها '),
                  TextSpan(
                    text: '100 جنيه.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // لو لم يُعاد توصيل الطلب
            if (!isReDelivered) ...[
              RichText(
                textAlign: TextAlign.justify,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                        text: 'يمكنك إعادة توصيل الطلب وتخفيض الغرامة إلى '),
                    TextSpan(
                      text: '50٪ ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text: 'في حال تنفيذ العملية خلال 24 ساعة القادمة.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(order.orderCode.toString())
                        .update({'reDelivery': true});

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم إعادة توصيل الطلب وتخفيض الغرامة إلى 50٪',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'إعادة توصيل الطلب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ] else ...[
         
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    '✅ تم إعادة توصيل هذا الطلب وتخفيض الغرامة بنسبة 50٪',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
