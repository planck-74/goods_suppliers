import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            child: CachedNetworkImage(
              imageUrl: product['imageUrl'],
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: customCircularProgressIndicator(
                  context: context,
                  value: null,
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  'لا توجد صورة',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
        )
      : Container();
}
