import 'package:cloud_firestore/cloud_firestore.dart';

String geoPointToText(GeoPoint geoPoint) {
  return "${geoPoint.latitude},${geoPoint.longitude}";
}
