import 'package:flutter/material.dart';

int calculateTotalWithOffer(List products) {
  int total = 0;
  for (var product in products) {
    if (product is Map && product.containsKey('controller')) {
      // Get the normal price as an integer.
      int normalPrice = product['price'] ?? 0;

      // Extract the quantity from the controller.
      int quantity = product['controller'] is TextEditingController
          ? int.tryParse(product['controller'].text) ?? 0
          : product['controller'] ?? 0;

      // Check if the product is on sale.
      bool isOnSale = product['isOnSale'] ?? false;
      if (isOnSale) {
        // Retrieve the offer price if available, or fallback to the normal price.
        int offerPrice = product['offerPrice'] ?? normalPrice;

        // Retrieve the maximum quantity allowed for the offer.
        int maxOfferQty = product['maxOrderQuantityForOffer'] ?? quantity;

        if (quantity <= maxOfferQty) {
          total += offerPrice * quantity;
        } else {
          int extraQty = quantity - maxOfferQty;
          total += offerPrice * maxOfferQty + normalPrice * extraQty;
        }
      } else {
        total += normalPrice * quantity;
      }
    }
  }
  return total;
}
