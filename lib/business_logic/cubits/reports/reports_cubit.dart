import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goods/business_logic/cubits/reports/reports_state.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportsCubit() : super(ReportsInitial());

  /// Fetch orders for a specific date range
  Future<void> fetchOrdersByPeriod(DateTime startDate, DateTime endDate) async {
    try {
      emit(ReportsLoading());

      // Validate date range
      if (startDate.isAfter(endDate)) {
        emit(const ReportsError(
          message: 'تاريخ البداية يجب أن يكون قبل تاريخ النهاية',
          errorCode: 'INVALID_DATE_RANGE',
        ));
        return;
      }

      // Fetch orders from Firestore with date filtering
      final querySnapshot = await _firestore
          .collection('orders')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      if (querySnapshot.docs.isEmpty) {
        emit(ReportsEmpty(
          message: 'لا توجد طلبات في الفترة من ${_formatDate(startDate)} إلى ${_formatDate(endDate)}',
          startDate: startDate,
          endDate: endDate,
        ));
        return;
      }

      // Convert documents to OrderModel objects
      final ordersData = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Process orders and calculate analytics
      final processedData = await _processOrdersData(ordersData);

      emit(ReportsLoaded(
        orders: ordersData,
        ordersRecent: processedData['ordersRecent'],
        ordersPreparing: processedData['ordersPreparing'],
        ordersDone: processedData['ordersDone'],
        ordersCanceled: processedData['ordersCanceled'],
        clients: processedData['clients'],
        ordersDoneTotal: processedData['ordersDoneTotal'],
        ordersCanceledTotal: processedData['ordersCanceledTotal'],
        averageDeliveryHours: processedData['averageDeliveryHours'],
        canceledOrdersPercent: processedData['canceledOrdersPercent'],
        startDate: startDate,
        endDate: endDate,
      ));

    } catch (e) {
      emit(ReportsError(
        message: 'حدث خطأ أثناء جلب البيانات: ${e.toString()}',
        errorCode: 'FETCH_ERROR',
      ));
    }
  }

  /// Fetch all orders without date filtering
  Future<void> fetchAllOrders() async {
    try {
      emit(ReportsLoading());

      final querySnapshot = await _firestore.collection('orders').get();

      if (querySnapshot.docs.isEmpty) {
        emit(const ReportsEmpty(message: 'لا توجد طلبات في النظام'));
        return;
      }

      final ordersData = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      final processedData = await _processOrdersData(ordersData);

      emit(ReportsLoaded(
        orders: ordersData,
        ordersRecent: processedData['ordersRecent'],
        ordersPreparing: processedData['ordersPreparing'],
        ordersDone: processedData['ordersDone'],
        ordersCanceled: processedData['ordersCanceled'],
        clients: processedData['clients'],
        ordersDoneTotal: processedData['ordersDoneTotal'],
        ordersCanceledTotal: processedData['ordersCanceledTotal'],
        averageDeliveryHours: processedData['averageDeliveryHours'],
        canceledOrdersPercent: processedData['canceledOrdersPercent'],
      ));

    } catch (e) {
      emit(ReportsError(
        message: 'حدث خطأ أثناء جلب البيانات: ${e.toString()}',
        errorCode: 'FETCH_ALL_ERROR',
      ));
    }
  }

  /// Refresh current data
  Future<void> refreshData() async {
    final currentState = state;
    if (currentState is ReportsLoaded) {
      if (currentState.startDate != null && currentState.endDate != null) {
        await fetchOrdersByPeriod(currentState.startDate!, currentState.endDate!);
      } else {
        await fetchAllOrders();
      }
    } else {
      await fetchAllOrders();
    }
  }

  /// Process orders data and calculate analytics
  Future<Map<String, dynamic>> _processOrdersData(List<OrderModel> ordersData) async {
    final ordersRecent = <OrderModel>[];
    final ordersPreparing = <OrderModel>[];
    final ordersDone = <OrderModel>[];
    final ordersCanceled = <OrderModel>[];
    final clients = <String>[];

    // Process each order and categorize by state
    for (var order in ordersData) {
      // Fetch client data for each order
      final client = await _fetchClient(order.clientId);
      if (client != null) {
        order.client = client;
      }

      // Categorize orders by state
      switch (order.state) {
        case 'جاري التاكيد':
          ordersRecent.add(order);
          break;
        case 'جاري التحضير':
          ordersPreparing.add(order);
          break;
        case 'تم التوصيل':
          ordersDone.add(order);
          break;
        case 'ملغي':
          ordersCanceled.add(order);
          break;
        default:
          // Handle unknown states
          ordersRecent.add(order);
      }
    }

    // Calculate financial totals
    final ordersDoneTotal = ordersDone.fold<double>(
      0.0, 
      (sum, order) => sum + order.totalWithOffer.toDouble(),
    );
    
    final ordersCanceledTotal = ordersCanceled.fold<double>(
      0.0, 
      (sum, order) => sum + order.totalWithOffer.toDouble(),
    );

    // Calculate cancellation percentage
    final totalProcessedOrders = ordersDone.length + ordersCanceled.length;
    final canceledOrdersPercent = totalProcessedOrders > 0 
        ? (ordersCanceled.length / totalProcessedOrders) * 100 
        : 0.0;

    // Collect unique client IDs from completed orders
    for (var order in ordersDone) {
      if (order.client?.uid != null && !clients.contains(order.client!.uid)) {
        clients.add(order.client!.uid);
      }
    }

    // Calculate average delivery time
    final averageDeliveryHours = _calculateAverageDeliveryTime(ordersDone);

    return {
      'ordersRecent': ordersRecent,
      'ordersPreparing': ordersPreparing,
      'ordersDone': ordersDone,
      'ordersCanceled': ordersCanceled,
      'clients': clients,
      'ordersDoneTotal': ordersDoneTotal,
      'ordersCanceledTotal': ordersCanceledTotal,
      'averageDeliveryHours': averageDeliveryHours,
      'canceledOrdersPercent': canceledOrdersPercent,
    };
  }

  /// Fetch client data from Firestore
  Future<ClientModel?> _fetchClient(String? clientId) async {
    if (clientId == null || clientId.isEmpty) return null;

    try {
      final clientDoc = await _firestore
          .collection('clients')
          .doc(clientId)
          .get();

      if (clientDoc.exists) {
        return ClientModel.fromFirestore(clientDoc);
      }
    } catch (e) {
      // Log error but don't throw - continue processing other orders
      // ignore: avoid_print
      print('Error fetching client $clientId: $e');
    }

    // Return default client if fetch fails
    return ClientModel(
      uid: clientId,
      businessName: 'عميل غير محدد',
      imageUrl: '',
      phoneNumber: '',
      secondPhoneNumber: '',
      geoLocation: const GeoPoint(30.0444, 31.2357), // Cairo coordinates
      category: '',
      government: '',
      town: '', addressTyped: '',
    );
  }

  /// Calculate average delivery time in hours
  double _calculateAverageDeliveryTime(List<OrderModel> completedOrders) {
    if (completedOrders.isEmpty) return 0.0;

    double totalDeliveryHours = 0.0;
    int validDeliveryCount = 0;

    for (var order in completedOrders) {
      if (order.doneAt != null) {
        final orderDate = order.date.toDate();
        final completionDate = order.doneAt!.toDate();
        final deliveryTime = completionDate.difference(orderDate);
        
        // Only count positive delivery times (completed after ordered)
        if (deliveryTime.inMinutes > 0) {
          totalDeliveryHours += deliveryTime.inMinutes / 60.0;
          validDeliveryCount++;
        }
      }
    }

    return validDeliveryCount > 0 ? totalDeliveryHours / validDeliveryCount : 0.0;
  }

  /// Helper method to format dates for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get analytics summary for quick overview
  Map<String, dynamic> getAnalyticsSummary() {
    final currentState = state;
    if (currentState is! ReportsLoaded) return {};

    return {
      'totalOrders': currentState.totalOrders,
      'completedOrders': currentState.completedOrders,
      'successRate': currentState.successRate,
      'totalRevenue': currentState.ordersDoneTotal,
      'averageOrderValue': currentState.averageOrderValue,
      'totalClients': currentState.totalClients,
      'averageDeliveryHours': currentState.averageDeliveryHours,
      'period': currentState.startDate != null && currentState.endDate != null
          ? '${_formatDate(currentState.startDate!)} - ${_formatDate(currentState.endDate!)}'
          : 'جميع الفترات',
    };
  }

  /// Clear current reports data
  void clearReports() {
    emit(ReportsInitial());
  }
}