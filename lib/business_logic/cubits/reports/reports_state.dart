import 'package:equatable/equatable.dart';
import 'package:goods/data/models/order_model.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<OrderModel> orders;
  final List<OrderModel> ordersRecent;
  final List<OrderModel> ordersPreparing;
  final List<OrderModel> ordersDone;
  final List<OrderModel> ordersCanceled;
  final List<String> clients;
  final double ordersDoneTotal;
  final double ordersCanceledTotal;
  final double averageDeliveryHours;
  final double canceledOrdersPercent;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportsLoaded({
    required this.orders,
    required this.ordersRecent,
    required this.ordersPreparing,
    required this.ordersDone,
    required this.ordersCanceled,
    required this.clients,
    required this.ordersDoneTotal,
    required this.ordersCanceledTotal,
    required this.averageDeliveryHours,
    required this.canceledOrdersPercent,
    this.startDate,
    this.endDate,
  });

  // Computed properties for better readability and performance
  int get totalOrders => orders.length;
  int get completedOrders => ordersDone.length;
  int get totalClients => clients.length;
  
  double get successRate => totalOrders > 0 
      ? (completedOrders / totalOrders) * 100 
      : 0.0;
      
  double get averageOrderValue => ordersDone.isNotEmpty 
      ? ordersDoneTotal / ordersDone.length 
      : 0.0;
      
  double get lossRate => (ordersDoneTotal + ordersCanceledTotal) > 0 
      ? (ordersCanceledTotal / (ordersDoneTotal + ordersCanceledTotal)) * 100 
      : 0.0;

  @override
  List<Object?> get props => [
        orders,
        ordersRecent,
        ordersPreparing,
        ordersDone,
        ordersCanceled,
        clients,
        ordersDoneTotal,
        ordersCanceledTotal,
        averageDeliveryHours,
        canceledOrdersPercent,
        startDate,
        endDate,
      ];
}

class ReportsEmpty extends ReportsState {
  final String message;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportsEmpty({
    required this.message,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [message, startDate, endDate];
}

class ReportsError extends ReportsState {
  final String message;
  final String? errorCode;

  const ReportsError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}