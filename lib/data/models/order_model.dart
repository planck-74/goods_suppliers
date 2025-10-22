import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/data/models/client_model.dart';

class OrderModel {
  final String clientId;
  final Timestamp date;
  String state;
  final int orderCode;
  final int total;
  final int totalWithOffer;
  final List products;
  final Timestamp? doneAt;
  final String note; // Added note field
  final bool reDelivery; // Added reDelivery field
  ClientModel? client;

  OrderModel({
    required this.clientId,
    required this.state,
    required this.orderCode,
    required this.total,
    required this.totalWithOffer,
    required this.date,
    required this.products,
    this.doneAt,
    this.note = '', // Default value for note
    this.reDelivery = false, // Default value for reDelivery
    this.client,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      clientId: map['clientId'] ?? '',
      state: map['state'] ?? '',
      orderCode: map['orderCode'] is int ? map['orderCode'] : 0,
      total: map['total'] is int ? map['total'] : 0,
      totalWithOffer: map['totalWithOffer'] is int ? map['totalWithOffer'] : 0,
      date: map['date'] is Timestamp ? map['date'] : Timestamp.now(),
      products: map['products'] is List ? map['products'] : [],
      doneAt: map['doneAt'] is Timestamp ? map['doneAt'] : null,
      note: map['note'] ?? '', // Map note field
      reDelivery: map['reDelivery'] is bool ? map['reDelivery'] : false, // Map reDelivery field
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(map);
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'state': state,
      'total': total,
      'totalWithOffer': totalWithOffer,
      'orderCode': orderCode,
      'date': date,
      'products': products,
      'doneAt': doneAt,
      'note': note, // Add note to map
      'reDelivery': reDelivery, // Add reDelivery to map
    };
  }
}
