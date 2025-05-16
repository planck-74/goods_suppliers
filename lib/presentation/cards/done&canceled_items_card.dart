// import 'package:flutter/material.dart';
// import 'package:goods/data/global/theme/theme_data.dart';
// import 'package:goods/data/models/order_model.dart';

// class DoneCanceledItemsCard extends StatefulWidget {
//   final Map<String, dynamic>? staticData;
//   final Map<String, dynamic> dynamicData;
//   final TextEditingController controller;

//   final int itemCount;
//   final int index;

//   OrderModel order;

//   DoneCanceledItemsCard({
//     super.key,
//     required this.staticData,
//     required this.dynamicData,
//     required this.controller,
//     required this.itemCount,
//     required this.index,
//     required this.order,
//   });

//   @override
//   _RecentPreparingItemsCardState createState() =>
//       _RecentPreparingItemsCardState();
// }

// class _RecentPreparingItemsCardState extends State<DoneCanceledItemsCard> {
//   Map<String, dynamic> product = {};

//   @override
//   void initState() {
//     super.initState();
//     product.addAll(widget.dynamicData);
//     if (widget.staticData != null) {
//       product.addAll(widget.staticData!);
//     }
//   }

//   Widget _buildProductImage() {
//     if (widget.staticData != null &&
//         widget.staticData!.containsKey('imageUrl')) {
//       return SizedBox(
//         height: 100,
//         width: 100,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8.0),
//           child: Image.network(
//             widget.staticData!['imageUrl'],
//             fit: BoxFit.fitHeight,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded /
//                           (loadingProgress.expectedTotalBytes ?? 1)
//                       : null,
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return Center(
//                 child: Text('لا توجد صورة',
//                     style: Theme.of(context).textTheme.headlineMedium),
//               );
//             },
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         height: 100,
//         width: 70,
//         color: Colors.grey[200],
//         child: const Center(
//             child: Text(
//           'الصورة غير متوفرة',
//           style: TextStyle(fontSize: 8),
//         )),
//       );
//     }
//   }

//   Widget _buildProductDetails() {
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.staticData?['name'] ?? '',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleMedium
//                   ?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               widget.staticData?['unit'] ?? '',
//               style: const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//             const SizedBox(height: 4),
//             Text('الإجمالي : ${widget.dynamicData['price']} جـ',
//                 style: const TextStyle(color: Colors.lightGreen, fontSize: 18)),
//             const SizedBox(
//               height: 12,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
//       child: Container(
//         padding: const EdgeInsets.all(5),
//         decoration: const BoxDecoration(
//             color: whiteColor,
//             borderRadius: BorderRadius.all(Radius.circular(12))),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProductImage(),
//                   const SizedBox(width: 12.0),
//                   _buildProductDetails(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
