import 'package:flutter/material.dart';
import 'package:goods/data/models/order_model.dart';

@immutable
abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  List orders;
  List ordersRecent;
  List ordersPreparing;
  List<OrderModel> ordersDone;
  List ordersCanceled;
  List selectedProducts;
  List clients;
  int ordersDoneTotal;
  int ordersCanceledTotal;
  double averageDeliveryHours;

  OrdersLoaded(
      this.orders,
      this.ordersRecent,
      this.ordersPreparing,
      this.ordersDone,
      this.ordersCanceled,
      this.selectedProducts,
      this.clients,
      this.ordersDoneTotal,
      this.ordersCanceledTotal,
      this.averageDeliveryHours);
}

class OrdersError extends OrdersState {
  OrdersError();
}
