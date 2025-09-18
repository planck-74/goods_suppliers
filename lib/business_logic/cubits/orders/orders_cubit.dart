import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  static const int pageSize = 10; // Number of items per page
  
  // Cache for all orders to avoid refetching
  final Map<String, OrderModel> _ordersCache = {};
  
  List<TextEditingController> controllers = [];
  List<Map> selectedProducts = [];
  List<bool> selectionList = [];
  List<String> clients = [];

  int ordersDoneTotal = 0;
  int ordersCanceledTotal = 0;
  double canceledOrdersPercent = 0;
  double averageDeliveryHours = 0.0;

  OrdersCubit() : super(OrdersInitial());

  /// Initial fetch for all tabs - fetches first page of each order state
  Future<void> fetchInitialOrders() async {
    emit(OrdersLoading());
    try {
      // Fetch first page for each state
      final recentData = await _fetchOrdersByState('جاري التاكيد', null);
      final preparingData = await _fetchOrdersByState('جاري التحضير', null);
      final doneData = await _fetchOrdersByState('تم التوصيل', null);
      final canceledData = await _fetchOrdersByState('ملغي', null);

      // Calculate statistics for done and canceled orders
      _calculateStatistics(doneData.orders, canceledData.orders);

      emit(OrdersLoaded(
        orders: [],
        ordersRecent: recentData.orders,
        ordersPreparing: preparingData.orders,
        ordersDone: doneData.orders,
        ordersCanceled: canceledData.orders,
        selectedProducts: selectedProducts,
        clients: clients,
        ordersDoneTotal: ordersDoneTotal,
        ordersCanceledTotal: ordersCanceledTotal,
        averageDeliveryHours: averageDeliveryHours,
        hasMoreRecent: recentData.hasMore,
        hasMorePreparing: preparingData.hasMore,
        hasMoreDone: doneData.hasMore,
        hasMoreCanceled: canceledData.hasMore,
        lastRecentDoc: recentData.lastDoc,
        lastPreparingDoc: preparingData.lastDoc,
        lastDoneDoc: doneData.lastDoc,
        lastCanceledDoc: canceledData.lastDoc,
      ));
    } catch (e) {
      emit(OrdersError('Error fetching orders: ${e.toString()}'));
    }
  }

  /// Load more recent orders
  Future<void> loadMoreRecentOrders() async {
    final currentState = state;
    if (currentState is! OrdersLoaded || 
        !currentState.hasMoreRecent || 
        currentState.isLoadingMoreRecent) return;

    emit(currentState.copyWith(isLoadingMoreRecent: true));

    try {
      final result = await _fetchOrdersByState(
        'جاري التاكيد', 
        currentState.lastRecentDoc
      );

      final updatedRecent = [...currentState.ordersRecent, ...result.orders];

      emit(currentState.copyWith(
        ordersRecent: updatedRecent,
        hasMoreRecent: result.hasMore,
        lastRecentDoc: result.lastDoc,
        isLoadingMoreRecent: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMoreRecent: false));
    }
  }

  /// Load more preparing orders
  Future<void> loadMorePreparingOrders() async {
    final currentState = state;
    if (currentState is! OrdersLoaded || 
        !currentState.hasMorePreparing || 
        currentState.isLoadingMorePreparing) return;

    emit(currentState.copyWith(isLoadingMorePreparing: true));

    try {
      final result = await _fetchOrdersByState(
        'جاري التحضير', 
        currentState.lastPreparingDoc
      );

      final updatedPreparing = [...currentState.ordersPreparing, ...result.orders];

      emit(currentState.copyWith(
        ordersPreparing: updatedPreparing,
        hasMorePreparing: result.hasMore,
        lastPreparingDoc: result.lastDoc,
        isLoadingMorePreparing: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMorePreparing: false));
    }
  }

  /// Load more done orders
  Future<void> loadMoreDoneOrders() async {
    final currentState = state;
    if (currentState is! OrdersLoaded || 
        !currentState.hasMoreDone || 
        currentState.isLoadingMoreDone) return;

    emit(currentState.copyWith(isLoadingMoreDone: true));

    try {
      final result = await _fetchOrdersByState(
        'تم التوصيل', 
        currentState.lastDoneDoc
      );

      final updatedDone = [...currentState.ordersDone, ...result.orders];
      
      // Recalculate statistics with new done orders
      _calculateStatistics(updatedDone, currentState.ordersCanceled);

      emit(currentState.copyWith(
        ordersDone: updatedDone,
        hasMoreDone: result.hasMore,
        lastDoneDoc: result.lastDoc,
        isLoadingMoreDone: false,
        ordersDoneTotal: ordersDoneTotal,
        averageDeliveryHours: averageDeliveryHours,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMoreDone: false));
    }
  }

  /// Load more canceled orders
  Future<void> loadMoreCanceledOrders() async {
    final currentState = state;
    if (currentState is! OrdersLoaded || 
        !currentState.hasMoreCanceled || 
        currentState.isLoadingMoreCanceled) return;

    emit(currentState.copyWith(isLoadingMoreCanceled: true));

    try {
      final result = await _fetchOrdersByState(
        'ملغي', 
        currentState.lastCanceledDoc
      );

      final updatedCanceled = [...currentState.ordersCanceled, ...result.orders];
      
      // Recalculate statistics with new canceled orders
      _calculateStatistics(currentState.ordersDone, updatedCanceled);

      emit(currentState.copyWith(
        ordersCanceled: updatedCanceled,
        hasMoreCanceled: result.hasMore,
        lastCanceledDoc: result.lastDoc,
        isLoadingMoreCanceled: false,
        ordersCanceledTotal: ordersCanceledTotal,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMoreCanceled: false));
    }
  }

  /// Helper method to fetch orders by state with pagination
  Future<_PaginatedResult> _fetchOrdersByState(
    String orderState,
    DocumentSnapshot? lastDoc,
  ) async {
    Query query = db.collection('orders')
        .where('state', isEqualTo: orderState)
        .orderBy('date', descending: true)
        .limit(pageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final querySnapshot = await query.get();
    final List<OrderModel> orders = [];
    DocumentSnapshot? newLastDoc;

    for (var doc in querySnapshot.docs) {
      final order = OrderModel.fromFirestore(doc);
      
      // Check cache first
      if (!_ordersCache.containsKey(order.orderCode)) {
        // Fetch client data if not in cache
        ClientModel? client = await fetchClient(order.clientId);
        client ??= ClientModel(
          uid: '',
          businessName: '',
          imageUrl: '',
          phoneNumber: '',
          secondPhoneNumber: '',
          geoLocation: const GeoPoint(30.0444, 31.2357),
          category: '',
          government: '',
          town: '',
          addressTyped: '',
        );
        order.client = client;
        _ordersCache[order.orderCode.toString()] = order;
      } else {
        order.client = _ordersCache[order.orderCode]!.client;
      }
      
      orders.add(order);
      newLastDoc = doc;
    }

    return _PaginatedResult(
      orders: orders,
      hasMore: querySnapshot.docs.length == pageSize,
      lastDoc: newLastDoc,
    );
  }

  /// Calculate statistics for done and canceled orders
  void _calculateStatistics(List<OrderModel> doneOrders, List<OrderModel> canceledOrders) {
    // Calculate totals
    ordersDoneTotal = doneOrders.fold(0, (sum, order) => sum + order.totalWithOffer);
    ordersCanceledTotal = canceledOrders.fold(0, (sum, order) => sum + order.totalWithOffer);
    
    // Calculate canceled percentage
    final totalOrders = doneOrders.length + canceledOrders.length;
    canceledOrdersPercent = totalOrders > 0 
        ? (canceledOrders.length / totalOrders) * 100 
        : 0;

    // Collect unique clients
    clients.clear();
    for (var order in doneOrders) {
      if (order.client?.uid != null && !clients.contains(order.client!.uid)) {
        clients.add(order.client!.uid);
      }
    }

    // Calculate average delivery hours
    double totalDeliveryHours = 0;
    int deliveryCount = 0;
    for (var order in doneOrders) {
      if (order.doneAt != null) {
        DateTime orderDate = order.date.toDate();
        DateTime orderDoneAt = order.doneAt!.toDate();
        double diffHours = orderDoneAt.difference(orderDate).inMinutes / 60.0;
        totalDeliveryHours += diffHours;
        deliveryCount++;
      }
    }
    averageDeliveryHours = deliveryCount > 0 ? totalDeliveryHours / deliveryCount : 0;
  }

  /// Update order state
  Future<void> updateState(String orderCode, String newState) async {
    await db.collection('orders').doc(orderCode).update({
      'state': newState,
      'doneAt': newState == 'تم التوصيل' ? FieldValue.serverTimestamp() : null,
    });

    final currentState = state;
    if (currentState is OrdersLoaded) {
      // Find and update the order in the appropriate list
      OrderModel? orderToMove;
      List<OrderModel> updatedRecent = List.from(currentState.ordersRecent);
      List<OrderModel> updatedPreparing = List.from(currentState.ordersPreparing);
      List<OrderModel> updatedDone = List.from(currentState.ordersDone);
      List<OrderModel> updatedCanceled = List.from(currentState.ordersCanceled);

      // Find the order in current lists
      for (var order in updatedRecent) {
        if (order.orderCode == orderCode) {
          orderToMove = order;
          updatedRecent.remove(order);
          break;
        }
      }
      if (orderToMove == null) {
        for (var order in updatedPreparing) {
          if (order.orderCode == orderCode) {
            orderToMove = order;
            updatedPreparing.remove(order);
            break;
          }
        }
      }

      // Add to appropriate list based on new state
      if (orderToMove != null) {
        orderToMove.state = newState;
        switch (newState) {
          case 'جاري التحضير':
            updatedPreparing.insert(0, orderToMove);
            break;
          case 'تم التوصيل':
            updatedDone.insert(0, orderToMove);
            break;
          case 'ملغي':
            updatedCanceled.insert(0, orderToMove);
            break;
        }
      }

      // Recalculate statistics if needed
      if (newState == 'تم التوصيل' || newState == 'ملغي') {
        _calculateStatistics(updatedDone, updatedCanceled);
      }

      emit(currentState.copyWith(
        ordersRecent: updatedRecent,
        ordersPreparing: updatedPreparing,
        ordersDone: updatedDone,
        ordersCanceled: updatedCanceled,
        ordersDoneTotal: ordersDoneTotal,
        ordersCanceledTotal: ordersCanceledTotal,
        averageDeliveryHours: averageDeliveryHours,
      ));
    }
  }

  Future<ClientModel?> fetchClient(String? clientId) async {
    if (clientId == null) return null;
    try {
      final DocumentSnapshot<Map<String, dynamic>> clientDoc =
          await db.collection('clients').doc(clientId).get();

      if (clientDoc.exists) {
        return ClientModel.fromFirestore(clientDoc);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Keep your existing helper methods unchanged
  List<TextEditingController> controllersList(order) {
    controllers = List.generate(
      order.products.length,
      (index) {
        final controllerValue =
            order.products[index]['controller']?.toString() ?? '';
        return TextEditingController(text: controllerValue);
      },
    );
    return controllers;
  }

  List<bool> productSelection(order) {
    if (order.products == null || order.products.isEmpty) {
      return [];
    }

    selectionList = List.generate(
      order.products.length,
      (index) => true,
    );

    return selectionList;
  }

  void updateProductSelection(int index, bool value) {
    selectionList[index] = value;
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState);
    }
  }

  bool areControllersEqual(
      List<TextEditingController> controllers, List products) {
    for (int i = 0; i < controllers.length; i++) {
      int? currentControllerValue = int.tryParse(controllers[i].text);
      int storedControllerValue = products[i]['controller'] ?? 0;
      if (currentControllerValue != storedControllerValue) {
        return false;
      }
    }
    return true;
  }

  Future<void> updateProductControllers(List<TextEditingController> controllers,
      List products, String orderCode) async {
    if (areControllersEqual(controllers, products)) {
      return;
    }

    DocumentReference orderDocRef = db.collection('orders').doc(orderCode);

    List updatedProducts = List.generate(controllers.length, (index) {
      return {
        ...products[index],
        'controller': int.tryParse(controllers[index].text) ?? 0,
      };
    });

    await orderDocRef.update({
      'products': updatedProducts,
    });
  }

  Future<void> removeFromFirebase(products, orderCode) async {
    if (products.length > selectedProducts.length) {
      await db
          .collection('orders')
          .doc(orderCode.toString())
          .update({'products': selectedProducts});
    }
  }

  Future<void> initselectedProducts(List products, List<bool> selection,
      List selectedProducts, List<TextEditingController> controllers) async {
    selectedProducts.clear();

    for (var i = 0; i < products.length; i++) {
      if (selection[i] == true) {
        products[i]['controller'] = int.parse(controllers[i].text);
        selectedProducts.add(products[i]);
      }
    }

    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState);
    }
  }
}

/// Helper class for paginated results
class _PaginatedResult {
  final List<OrderModel> orders;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;

  _PaginatedResult({
    required this.orders,
    required this.hasMore,
    this.lastDoc,
  });
}