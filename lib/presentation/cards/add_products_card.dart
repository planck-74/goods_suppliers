import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/build_product_image.dart';
import 'package:goods/presentation/sheets/add_button.dart';

class AddProductsCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const AddProductsCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        width: screenWidth * 0.95,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          border: Border(bottom: BorderSide(color: Colors.black)),
          color: whiteColor,
        ),
        child: Stack(
          children: [
            // عرض صورة المنتج وتفاصيله في صف واحد
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProductImage(context, product, 140, 100),
                Expanded(
                  child: _buildProductDetails(),
                ),
              ],
            ),
            Positioned(
              top: 90,
              left: 10,
              child: AddButton(product: product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${product['name']}${product['size'] != null ? ' - ${product['size']}' : ''}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (product['package'] != null) ...[
            const SizedBox(height: 10),
            Text(
              product['package'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (product['note'] != null && product['note'] != '') ...[
            const SizedBox(height: 10),
            Text(
              'ملحوظة: ${product['note']}',
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
