class Product {
  String? productId;
  String? imageUrl;
  String? name;
  String? manufacturer;
  String? size;
  String? package;
  String? classification;
  String? note;

  int? salesCount;

  Product({
    this.productId,
    this.imageUrl,
    this.name,
    this.manufacturer,
    this.size,
    this.package,
    this.classification, // New field added
    this.note, // New field added
    this.salesCount,
  });

  factory Product.fromMap(
    Map<String, dynamic> map,
  ) {
    return Product(
      productId: map['productId'],
      imageUrl: map['imageUrl'],
      name: map['name'],
      manufacturer: map['manufacturer'],
      size: map['size'],
      package: map['package'],
      classification: map['classification'], // New field added
      note: map['note'], // New field added
      salesCount: map['salesCount'],
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
      'classification': classification, // New field added
      'note': note, // New field added
      'salesCount': salesCount,
    };
  }
}
