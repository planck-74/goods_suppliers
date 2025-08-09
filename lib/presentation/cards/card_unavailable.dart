import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/sheets/sheet_unavailable.dart';

Widget unAvailableCard({
  required Map<String, dynamic> product,
  required int index,
  required List productData,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
    child: Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 10, // Blur radius
            offset: const Offset(0, 3), // Shadow position (x, y)
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProductImage(imageUrl: product['imageUrl']),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  height: 60,
                  width: 1.0,
                  color: darkBlueColor,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ProductDetails(
                    product: product,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: AvailabilityButton(
              onPressed: () => _showSheet(context, index, product, productData),
            ),
          ),
        ],
      ),
    ),
  );
}

class ProductImage extends StatelessWidget {
  final String? imageUrl;

  const ProductImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 100;
    const double imageHeight = 120;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return SizedBox(
        height: imageHeight,
        width: imageWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2.0),
          child: Image.network(
            imageUrl!,
            height: imageHeight,
            width: imageWidth,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
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
      );
    } else {
      return Container(
        height: imageHeight,
        width: imageWidth,
        color: Colors.grey[200],
        child: const Center(child: Text('No Image')),
      );
    }
  }
}

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final String title = '${product['name']}'
        '${product['size'] != null ? ' - ${product['size']}' : ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2, // Allows the title to wrap into a second line
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${product['price']} جـ',
          style: const TextStyle(color: Colors.lightGreen, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'أقل كمية للطلب: ${product['minOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          'أقصي كمية للطلب: ${product['maxOrderQuantity']}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

/// زر تفعيل المنتج
class AvailabilityButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AvailabilityButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'إتاحة المنتج',
        style: TextStyle(
          color: Colors.lightGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// دالة لإظهار الـ BottomSheet
void _showSheet(BuildContext context, int index, Map<String, dynamic> product,
    List productData) {
  showModalBottomSheet(
    backgroundColor: whiteColor,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SheetUnavailable(
        index: index,
        product: product,
        productData: productData,
      );
    },
  );
}
