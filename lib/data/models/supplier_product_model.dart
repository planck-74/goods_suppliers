class Product {
  final String productId;
  final String name;
  final String classification;
  final String imageUrl;
  final String note;
  final String manufacturer;
  final String size;
  final String package;
  final int price;
  final int? offerPrice;
  final int maxOrderQuantity;
  final int minOrderQuantity;
  final int? maxOrderQuantityForOffer;
  final int salesCount;
  final bool isOnSale;
  final bool availability;
  final DateTime? endDate;

  Product({
    required this.productId,
    required this.name,
    required this.classification,
    required this.imageUrl,
    required this.note,
    required this.manufacturer,
    required this.size,
    required this.package,
    required this.price,
    required this.offerPrice,
    required this.maxOrderQuantity,
    required this.minOrderQuantity,
    required this.maxOrderQuantityForOffer,
    required this.salesCount,
    required this.isOnSale,
    required this.availability,
    required this.endDate,
  });

  factory Product.toMap(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      classification: json['classification'],
      imageUrl: json['imageUrl'],
      note: json['note'],
      manufacturer: json['manufacturer'],
      size: json['size'],
      package: json['package'],
      price: json['price'],
      offerPrice: json['offerPrice'],
      maxOrderQuantity: json['maxOrderQuantity'],
      minOrderQuantity: json['minOrderQuantity'],
      maxOrderQuantityForOffer: json['maxOrderQuantityForOffer'],
      salesCount: json['salesCount'],
      isOnSale: json['isOnSale'],
      availability: json['availability'],
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate']) ?? DateTime(1970, 1, 1)
          : DateTime(1970, 1, 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'classification': classification,
      'imageUrl': imageUrl,
      'note': note,
      'manufacturer': manufacturer,
      'size': size,
      'package': package,
      'price': price,
      'offerPrice': offerPrice,
      'maxOrderQuantity': maxOrderQuantity,
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantityForOffer': maxOrderQuantityForOffer,
      'salesCount': salesCount,
      'isOnSale': isOnSale,
      'availability': availability,
      'endDate': endDate?.toIso8601String(),
    };
  }
}
