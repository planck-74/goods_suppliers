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
  final List<OrderModel> ordersConfirmed; // Added
  final List<OrderModel> ordersDelivering; // Added
  final List<OrderModel> ordersDone;
  final List<OrderModel> ordersCanceled;
  final List<OrderModel> ordersNeglected; // Added
  final List selectedProducts;
  final List clients;
  final int ordersDoneTotal;
  final int ordersCanceledTotal;
  final double averageDeliveryHours;
  
  // Pagination tracking for each tab
  final bool hasMoreRecent;
  final bool hasMorePreparing;
  final bool hasMoreConfirmed; // Added
  final bool hasMoreDelivering; // Added
  final bool hasMoreDone;
  final bool hasMoreCanceled;
  final bool hasMoreNeglected; // Added
  
  // Loading states for pagination
  final bool isLoadingMoreRecent;
  final bool isLoadingMorePreparing;
  final bool isLoadingMoreConfirmed; // Added
  final bool isLoadingMoreDelivering; // Added
  final bool isLoadingMoreDone;
  final bool isLoadingMoreCanceled;
  final bool isLoadingMoreNeglected; // Added
  
  // Last documents for pagination
  final DocumentSnapshot? lastRecentDoc;
  final DocumentSnapshot? lastPreparingDoc;
  final DocumentSnapshot? lastConfirmedDoc; // Added
  final DocumentSnapshot? lastDeliveringDoc; // Added
  final DocumentSnapshot? lastDoneDoc;
  final DocumentSnapshot? lastCanceledDoc;
  final DocumentSnapshot? lastNeglectedDoc; // Added

  OrdersLoaded({
    required this.orders,
    required this.ordersRecent,
    required this.ordersPreparing,
    required this.ordersConfirmed, // Added
    required this.ordersDelivering, // Added
    required this.ordersDone,
    required this.ordersCanceled,
    required this.ordersNeglected, // Added
    required this.selectedProducts,
    required this.clients,
    required this.ordersDoneTotal,
    required this.ordersCanceledTotal,
    required this.averageDeliveryHours,
    this.hasMoreRecent = true,
    this.hasMorePreparing = true,
    this.hasMoreConfirmed = true, // Added
    this.hasMoreDelivering = true, // Added
    this.hasMoreDone = true,
    this.hasMoreCanceled = true,
    this.hasMoreNeglected = true, // Added
    this.isLoadingMoreRecent = false,
    this.isLoadingMorePreparing = false,
    this.isLoadingMoreConfirmed = false, // Added
    this.isLoadingMoreDelivering = false, // Added
    this.isLoadingMoreDone = false,
    this.isLoadingMoreCanceled = false,
    this.isLoadingMoreNeglected = false, // Added
    this.lastRecentDoc,
    this.lastPreparingDoc,
    this.lastConfirmedDoc, // Added
    this.lastDeliveringDoc, // Added
    this.lastDoneDoc,
    this.lastCanceledDoc,
    this.lastNeglectedDoc, // Added
  });
  
  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? ordersRecent,
    List<OrderModel>? ordersPreparing,
    List<OrderModel>? ordersConfirmed, // Added
    List<OrderModel>? ordersDelivering, // Added
    List<OrderModel>? ordersDone,
    List<OrderModel>? ordersCanceled,
    List<OrderModel>? ordersNeglected, // Added
    List? selectedProducts,
    List? clients,
    int? ordersDoneTotal,
    int? ordersCanceledTotal,
    double? averageDeliveryHours,
    bool? hasMoreRecent,
    bool? hasMorePreparing,
    bool? hasMoreConfirmed, // Added
    bool? hasMoreDelivering, // Added
    bool? hasMoreDone,
    bool? hasMoreCanceled,
    bool? hasMoreNeglected, // Added
    bool? isLoadingMoreRecent,
    bool? isLoadingMorePreparing,
    bool? isLoadingMoreConfirmed, // Added
    bool? isLoadingMoreDelivering, // Added
    bool? isLoadingMoreDone,
    bool? isLoadingMoreCanceled,
    bool? isLoadingMoreNeglected, // Added
    DocumentSnapshot? lastRecentDoc,
    DocumentSnapshot? lastPreparingDoc,
    DocumentSnapshot? lastConfirmedDoc, // Added
    DocumentSnapshot? lastDeliveringDoc, // Added
    DocumentSnapshot? lastDoneDoc,
    DocumentSnapshot? lastCanceledDoc,
    DocumentSnapshot? lastNeglectedDoc, // Added
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      ordersRecent: ordersRecent ?? this.ordersRecent,
      ordersPreparing: ordersPreparing ?? this.ordersPreparing,
      ordersConfirmed: ordersConfirmed ?? this.ordersConfirmed, // Added
      ordersDelivering: ordersDelivering ?? this.ordersDelivering, // Added
      ordersDone: ordersDone ?? this.ordersDone,
      ordersCanceled: ordersCanceled ?? this.ordersCanceled,
      ordersNeglected: ordersNeglected ?? this.ordersNeglected, // Added
      selectedProducts: selectedProducts ?? this.selectedProducts,
      clients: clients ?? this.clients,
      ordersDoneTotal: ordersDoneTotal ?? this.ordersDoneTotal,
      ordersCanceledTotal: ordersCanceledTotal ?? this.ordersCanceledTotal,
      averageDeliveryHours: averageDeliveryHours ?? this.averageDeliveryHours,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
      hasMorePreparing: hasMorePreparing ?? this.hasMorePreparing,
      hasMoreConfirmed: hasMoreConfirmed ?? this.hasMoreConfirmed, // Added
      hasMoreDelivering: hasMoreDelivering ?? this.hasMoreDelivering, // Added
      hasMoreDone: hasMoreDone ?? this.hasMoreDone,
      hasMoreCanceled: hasMoreCanceled ?? this.hasMoreCanceled,
      hasMoreNeglected: hasMoreNeglected ?? this.hasMoreNeglected, // Added
      isLoadingMoreRecent: isLoadingMoreRecent ?? this.isLoadingMoreRecent,
      isLoadingMorePreparing: isLoadingMorePreparing ?? this.isLoadingMorePreparing,
      isLoadingMoreConfirmed: isLoadingMoreConfirmed ?? this.isLoadingMoreConfirmed, // Added
      isLoadingMoreDelivering: isLoadingMoreDelivering ?? this.isLoadingMoreDelivering, // Added
      isLoadingMoreDone: isLoadingMoreDone ?? this.isLoadingMoreDone,
      isLoadingMoreCanceled: isLoadingMoreCanceled ?? this.isLoadingMoreCanceled,
      isLoadingMoreNeglected: isLoadingMoreNeglected ?? this.isLoadingMoreNeglected, // Added
      lastRecentDoc: lastRecentDoc ?? this.lastRecentDoc,
      lastPreparingDoc: lastPreparingDoc ?? this.lastPreparingDoc,
      lastConfirmedDoc: lastConfirmedDoc ?? this.lastConfirmedDoc, // Added
      lastDeliveringDoc: lastDeliveringDoc ?? this.lastDeliveringDoc, // Added
      lastDoneDoc: lastDoneDoc ?? this.lastDoneDoc,
      lastCanceledDoc: lastCanceledDoc ?? this.lastCanceledDoc,
      lastNeglectedDoc: lastNeglectedDoc ?? this.lastNeglectedDoc, // Added
    );
  }
}

 class OrdersError extends OrdersState {
  final String? message;
  OrdersError([this.message]);
}