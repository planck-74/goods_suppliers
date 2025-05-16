import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel {
  final String uid;
  final String businessName;
  final String category;
  final String imageUrl;
  final String phoneNumber;
  final String secondPhoneNumber;
  final GeoPoint geoPoint;
  final String storeId;
  final String government;
  final String town;

  SupplierModel({
    required this.uid,
    required this.businessName,
    required this.category,
    required this.imageUrl,
    required this.phoneNumber,
    required this.secondPhoneNumber,
    required this.geoPoint,
    required this.storeId,
    required this.government,
    required this.town,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      uid: map['uid'] ?? '',
      businessName: map['businessName'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      secondPhoneNumber: map['secondPhoneNumber'] ?? '',
      geoPoint: map['geoLocation'] != null
          ? GeoPoint(map['geoLocation'].latitude, map['geoLocation'].longitude)
          : const GeoPoint(0, 0),
      storeId: map['storeId'] ?? '',
      government: map['government'] ?? '',
      town: map['town'] ?? '',
    );
  }

  factory SupplierModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null");
    }
    return SupplierModel.fromMap(data as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'businessName': businessName,
      'category': category,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'secondPhoneNumber': secondPhoneNumber,
      'geoLocation': geoPoint,
      'storeId': storeId,
      'government': government,
      'town': town,
    };
  }
}
