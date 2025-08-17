import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String uid;
  final String businessName;
  final String category;
  final String imageUrl;
  final String phoneNumber;
  final String secondPhoneNumber;
  final GeoPoint geoLocation;
  final String government;
  final String town;
  final String addressTyped;

  ClientModel({
    required this.uid,
    required this.businessName,
    required this.category,
    required this.imageUrl,
    required this.phoneNumber,
    required this.secondPhoneNumber,
    required this.geoLocation,
    required this.government,
    required this.town,
    required this.addressTyped,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      uid: map['uid'] ?? '',
      businessName: map['businessName'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      secondPhoneNumber: map['secondPhoneNumber'] ?? '',
      geoLocation: map['geoLocation'] != null
          ? GeoPoint(map['geoLocation'].latitude, map['geoLocation'].longitude)
          : const GeoPoint(0, 0),
      government: map['government'] ?? '',
      town: map['town'] ?? '',
      addressTyped: map['addressTyped'] ?? '',
    );
  }

  factory ClientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null");
    }
    return ClientModel.fromMap(data as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'businessName': businessName,
      'category': category,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'secondPhoneNumber': secondPhoneNumber,
      'geoLocation': geoLocation,
      'government': government,
      'town': town,
      'addressTyped': addressTyped,
    };
  }
}
