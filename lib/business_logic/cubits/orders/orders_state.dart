import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/data/models/order_model.dart';

@immutable
abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final List<OrderModel> ordersRecent;
  final List<OrderModel> ordersPreparing;
  final List<OrderModel> ordersDone;
  final List<OrderModel> ordersCanceled;
  final List selectedProducts;
  final List clients;
  final int ordersDoneTotal;
  final int ordersCanceledTotal;
  final double averageDeliveryHours;
  
  // Pagination tracking for each tab
  final bool hasMoreRecent;
  final bool hasMorePreparing;
  final bool hasMoreDone;
  final bool hasMoreCanceled;
  
  // Loading states for pagination
  final bool isLoadingMoreRecent;
  final bool isLoadingMorePreparing;
  final bool isLoadingMoreDone;
  final bool isLoadingMoreCanceled;
  
  // Last documents for pagination
  final DocumentSnapshot? lastRecentDoc;
  final DocumentSnapshot? lastPreparingDoc;
  final DocumentSnapshot? lastDoneDoc;
  final DocumentSnapshot? lastCanceledDoc;

  OrdersLoaded({
    required this.orders,
    required this.ordersRecent,
    required this.ordersPreparing,
    required this.ordersDone,
    required this.ordersCanceled,
    required this.selectedProducts,
    required this.clients,
    required this.ordersDoneTotal,
    required this.ordersCanceledTotal,
    required this.averageDeliveryHours,
    this.hasMoreRecent = true,
    this.hasMorePreparing = true,
    this.hasMoreDone = true,
    this.hasMoreCanceled = true,
    this.isLoadingMoreRecent = false,
    this.isLoadingMorePreparing = false,
    this.isLoadingMoreDone = false,
    this.isLoadingMoreCanceled = false,
    this.lastRecentDoc,
    this.lastPreparingDoc,
    this.lastDoneDoc,
    this.lastCanceledDoc,
  });
  
  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? ordersRecent,
    List<OrderModel>? ordersPreparing,
    List<OrderModel>? ordersDone,
    List<OrderModel>? ordersCanceled,
    List? selectedProducts,
    List? clients,
    int? ordersDoneTotal,
    int? ordersCanceledTotal,
    double? averageDeliveryHours,
    bool? hasMoreRecent,
    bool? hasMorePreparing,
    bool? hasMoreDone,
    bool? hasMoreCanceled,
    bool? isLoadingMoreRecent,
    bool? isLoadingMorePreparing,
    bool? isLoadingMoreDone,
    bool? isLoadingMoreCanceled,
    DocumentSnapshot? lastRecentDoc,
    DocumentSnapshot? lastPreparingDoc,
    DocumentSnapshot? lastDoneDoc,
    DocumentSnapshot? lastCanceledDoc,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      ordersRecent: ordersRecent ?? this.ordersRecent,
      ordersPreparing: ordersPreparing ?? this.ordersPreparing,
      ordersDone: ordersDone ?? this.ordersDone,
      ordersCanceled: ordersCanceled ?? this.ordersCanceled,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      clients: clients ?? this.clients,
      ordersDoneTotal: ordersDoneTotal ?? this.ordersDoneTotal,
      ordersCanceledTotal: ordersCanceledTotal ?? this.ordersCanceledTotal,
      averageDeliveryHours: averageDeliveryHours ?? this.averageDeliveryHours,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
      hasMorePreparing: hasMorePreparing ?? this.hasMorePreparing,
      hasMoreDone: hasMoreDone ?? this.hasMoreDone,
      hasMoreCanceled: hasMoreCanceled ?? this.hasMoreCanceled,
      isLoadingMoreRecent: isLoadingMoreRecent ?? this.isLoadingMoreRecent,
      isLoadingMorePreparing: isLoadingMorePreparing ?? this.isLoadingMorePreparing,
      isLoadingMoreDone: isLoadingMoreDone ?? this.isLoadingMoreDone,
      isLoadingMoreCanceled: isLoadingMoreCanceled ?? this.isLoadingMoreCanceled,
      lastRecentDoc: lastRecentDoc ?? this.lastRecentDoc,
      lastPreparingDoc: lastPreparingDoc ?? this.lastPreparingDoc,
      lastDoneDoc: lastDoneDoc ?? this.lastDoneDoc,
      lastCanceledDoc: lastCanceledDoc ?? this.lastCanceledDoc,
    );
  }
}

class OrdersError extends OrdersState {
  final String? message;
  OrdersError([this.message]);
}