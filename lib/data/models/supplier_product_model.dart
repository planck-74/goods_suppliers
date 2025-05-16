class StoreProduct {
  String productId;
  bool availability;
  int price;
  int minOrderQuantity;
  int maxOrderQuantity;
  bool? isOnSale;
  int? offerPrice;
  DateTime? endDate;
  int? maxOrderQuantityForOffer;

  StoreProduct({
    required this.productId,
    required this.availability,
    required this.price,
    required this.minOrderQuantity,
    required this.maxOrderQuantity,
    this.isOnSale,
    this.offerPrice,
    this.endDate,
    this.maxOrderQuantityForOffer,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'availability': availability,
      'price': price,
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      'isOnSale': isOnSale,
      'offerPrice': offerPrice,
      'endDate': endDate?.toIso8601String(),
      'maxOrderQuantityForOffer': maxOrderQuantityForOffer,
    };
  }

  StoreProduct.fromMap(Map<String, dynamic> map)
      : productId = map['productId'],
        availability = map['availability'],
        price = map['price'],
        minOrderQuantity = map['minOrderQuantity'],
        maxOrderQuantity = map['maxOrderQuantity'],
        isOnSale = map['isOnSale'],
        offerPrice = map['offerPrice'],
        endDate =
            map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
        maxOrderQuantityForOffer = map['maxOrderQuantityForOffer'];
}
