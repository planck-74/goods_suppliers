class Product {
  String? productId;
  String? imageUrl;
  String? name;
  String? manufacturer;
  String? size;
  String? package;
  String? classification;
  String? note;

  bool availability;  
  bool isOnSale; 
  DateTime? endDate;

  int? minOrderQuantity;
  int? maxOrderQuantity;
  double? price;
  int salesCount; // 0 by default

  List<String>? keywords; // new field

  Product({
    this.productId,
    this.imageUrl,
    this.name,
    this.manufacturer,
    this.size,
    this.package,
    this.classification,
    this.note,
    this.availability = false,
    this.isOnSale = false,
    this.endDate,
    this.minOrderQuantity,
    this.maxOrderQuantity,
    this.price,
    this.salesCount = 0,
    this.keywords,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      final toDate = v.toDate;
      if (toDate is Function) return toDate();
    } catch (_) {}
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'] as String?,
      imageUrl: map['imageUrl'] as String?,
      name: map['name'] as String?,
      manufacturer: map['manufacturer'] as String?,
      size: map['size'] as String?,
      package: map['package'] as String?,
      classification: map['classification'] as String?,
      note: map['note'] as String?,
      availability: map['availability'] == true,
      isOnSale: map['isOnSale'] == true,
      endDate: _parseDate(map['endDate']),
      minOrderQuantity: (map['minOrderQuantity'] is num)
          ? (map['minOrderQuantity'] as num).toInt()
          : null,
      maxOrderQuantity: (map['maxOrderQuantity'] is num)
          ? (map['maxOrderQuantity'] as num).toInt()
          : null,
      price: map['price'] != null
          ? (map['price'] is num
              ? (map['price'] as num).toDouble()
              : double.tryParse(map['price'].toString()))
          : null,
      salesCount: (map['salesCount'] is num)
          ? (map['salesCount'] as num).toInt()
          : 0,
      keywords: (map['keywords'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'imageUrl': imageUrl,
      'name': name,
      'manufacturer': manufacturer,
      'size': size,
      'package': package,
      'classification': classification,
      'note': note,
      'availability': availability,
      'isOnSale': isOnSale,
      'endDate': endDate,
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      'price': price,
      'salesCount': salesCount,
      'keywords': keywords,
    };
  }
}
