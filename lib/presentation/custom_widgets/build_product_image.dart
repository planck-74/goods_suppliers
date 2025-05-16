import 'package:flutter/material.dart';
import 'package:goods/presentation/custom_widgets/custom_progress_indicator.dart';

Widget buildProductImage(
    BuildContext context, Map product, double? height, double? width) {
  return product.containsKey('imageUrl')
      ? Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.network(
              product['imageUrl'],
              fit: BoxFit.fitWidth,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: customCircularProgressIndicator(
                    context: context,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'لا توجد صورة',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
              },
            ),
          ),
        )
      : Container();
}
