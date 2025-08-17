import 'package:cloud_firestore/cloud_firestore.dart';

String geoLocationToText(GeoPoint geoLocation) {
  return "${geoLocation.latitude},${geoLocation.longitude}";
}
