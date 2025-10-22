import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  static const int pageSize = 5;

  // Stream subscriptions for real-time updates
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  // Separate caches for orders and clients
  final Map<String, OrderModel> _ordersCache = {};
  final Map<String, ClientModel> _clientsCache = {};

  // Track order states for transition handling
  final Map<String, String> _orderStates = {}; // orderCode -> state

  List<TextEditingController> controllers = [];
  List<Map> selectedProducts = [];
  List<bool> selectionList = [];
  List<String> clients = [];

  int ordersDoneTotal = 0;
  int ordersCanceledTotal = 0;
  double canceledOrdersPercent = 0;
  double averageDeliveryHours = 0.0;

  OrdersCubit() : super(OrdersInitial());

  /// Initial fetch with real-time listeners
  Future<void> fetchInitialOrders() async {
    emit(OrdersLoading());
    try {
      // Fetch initial data
      final results = await Future.wait([
        _fetchOrdersByState('جاري التاكيد', null),
        _fetchOrdersByState('مؤكد', null),
        _fetchOrdersByState('جاري التحضير', null),
        _fetchOrdersByState('جاري التوصيل', null),
        _fetchOrdersByState('تم التوصيل', null),
        _fetchOrdersByState('مهمل', null),
        _fetchOrdersByState('ملغي', null),
      ]);

      final recentData = results[0];
      final confirmedData = results[1];
      final preparingData = results[2];
      final deliveringData = results[3];
      final doneData = results[4];
      final neglectedData = results[5];
      final canceledData = results[6];

      // Track initial states
      _trackOrderStates(recentData.orders, 'جاري التاكيد');
      _trackOrderStates(confirmedData.orders, 'مؤكد');
      _trackOrderStates(preparingData.orders, 'جاري التحضير');
      _trackOrderStates(deliveringData.orders, 'جاري التوصيل');
      _trackOrderStates(doneData.orders, 'تم التوصيل');
      _trackOrderStates(neglectedData.orders, 'مهمل');
      _trackOrderStates(canceledData.orders, 'ملغي');

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
        ordersConfirmed: confirmedData.orders,
        ordersDelivering: deliveringData.orders,
        ordersNeglected: neglectedData.orders,
        hasMoreConfirmed: confirmedData.hasMore,
        hasMoreDelivering: deliveringData.hasMore,
        hasMoreNeglected: neglectedData.hasMore,
        lastConfirmedDoc: confirmedData.lastDoc,
        lastDeliveringDoc: deliveringData.lastDoc,
        lastNeglectedDoc: neglectedData.lastDoc,
      ));

      // Start listening to real-time updates
      _startRealtimeListeners();
    } catch (e) {
      emit(OrdersError('خطأ في تحميل الطلبات: ${e.toString()}'));
    }
  }

  /// Track order states in memory
  void _trackOrderStates(List<OrderModel> orders, String state) {
    for (var order in orders) {
      _orderStates[order.orderCode.toString()] = state;
    }
  }

  /// Start real-time listeners for order changes
  void _startRealtimeListeners() {
    final states = [
      'جاري التاكيد',
      'مؤكد',
      'جاري التحضير',
      'جاري التوصيل',
      'تم التوصيل',
      'مهمل',
      'ملغي',
    ];

    for (var orderState in states) {
      _streamSubscriptions[orderState] = db
          .collection('orders')
          .where('state', isEqualTo: orderState)
          .orderBy('date', descending: true)
          .limit(pageSize)
          .snapshots()
          .listen(
            (snapshot) => _handleRealtimeUpdate(orderState, snapshot),
            onError: (error) => debugPrint('Stream error for $orderState: $error'),
          );
    }
  }

  /// Handle real-time updates from Firestore
  Future<void> _handleRealtimeUpdate(
    String orderState,
    QuerySnapshot snapshot,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    // Process document changes
    for (var change in snapshot.docChanges) {
      final order = OrderModel.fromFirestore(change.doc);
      final orderCode = order.orderCode.toString();
      
      // Fetch client if not cached
      if (!_clientsCache.containsKey(order.clientId)) {
        final client = await fetchClient(order.clientId);
        if (client != null) {
          _clientsCache[order.clientId!] = client;
        }
      }
      
      order.client = _clientsCache[order.clientId] ?? _getDefaultClient();
      _ordersCache[orderCode] = order;

      switch (change.type) {
        case DocumentChangeType.added:
          _handleOrderAdded(currentState, order, orderState);
          break;
        case DocumentChangeType.modified:
          _handleOrderModified(currentState, order, orderState);
          break;
        case DocumentChangeType.removed:
          _handleOrderRemoved(currentState, order, orderState);
          break;
      }
    }
  }

  /// Handle when an order is added to a state
  void _handleOrderAdded(OrdersLoaded state, OrderModel order, String orderState) {
    final orderCode = order.orderCode.toString();
    final oldState = _orderStates[orderCode];

    // Check if this is a state transition (order existed in another state)
    if (oldState != null && oldState != orderState) {
      // Remove from old state list
      var updatedState = _removeOrderFromList(state, orderCode, oldState);
      
      // Add to new state list
      updatedState = _addOrderToListByState(updatedState, order, orderState);
      
      // Update tracked state
      _orderStates[orderCode] = orderState;
      
      emit(updatedState);
    } else {
      // This is a genuinely new order
      final existingList = _getOrdersList(state, orderState);
      if (existingList.any((o) => o.orderCode == order.orderCode)) return;

      _orderStates[orderCode] = orderState;
      final updatedState = _addOrderToListByState(state, order, orderState);
      emit(updatedState);
    }
  }

  /// Handle when an order is modified
  void _handleOrderModified(OrdersLoaded state, OrderModel order, String orderState) {
    // Update the order in its current list
    final updatedState = _updateOrderInList(state, order, orderState);
    emit(updatedState);
  }

  /// Handle when an order is removed (moved to another state)
  void _handleOrderRemoved(OrdersLoaded state, OrderModel order, String orderState) {
    final orderCode = order.orderCode.toString();
    final updatedState = _removeOrderFromList(state, orderCode, orderState);
    
    // Don't remove from _orderStates here, as it might be added to another state
    // The add handler will update it
    
    emit(updatedState);
  }

  /// Get orders list by state
  List<OrderModel> _getOrdersList(OrdersLoaded state, String orderState) {
    switch (orderState) {
      case 'جاري التاكيد':
        return state.ordersRecent;
      case 'مؤكد':
        return state.ordersConfirmed;
      case 'جاري التحضير':
        return state.ordersPreparing;
      case 'جاري التوصيل':
        return state.ordersDelivering;
      case 'تم التوصيل':
        return state.ordersDone;
      case 'مهمل':
        return state.ordersNeglected;
      case 'ملغي':
        return state.ordersCanceled;
      default:
        return [];
    }
  }

  /// Remove order from specific list
  OrdersLoaded _removeOrderFromList(OrdersLoaded state, String orderCode, String orderState) {
    switch (orderState) {
      case 'جاري التاكيد':
        return state.copyWith(
          ordersRecent: state.ordersRecent.where((o) => o.orderCode.toString() != orderCode).toList(),
        );
      case 'مؤكد':
        return state.copyWith(
          ordersConfirmed: state.ordersConfirmed.where((o) => o.orderCode.toString() != orderCode).toList(),
        );
      case 'جاري التحضير':
        return state.copyWith(
          ordersPreparing: state.ordersPreparing.where((o) => o.orderCode.toString() != orderCode).toList(),
        );
      case 'جاري التوصيل':
        return state.copyWith(
          ordersDelivering: state.ordersDelivering.where((o) => o.orderCode.toString() != orderCode).toList(),
        );
      case 'تم التوصيل':
        final newDoneOrders = state.ordersDone.where((o) => o.orderCode.toString() != orderCode).toList();
        _calculateStatistics(newDoneOrders, state.ordersCanceled);
        return state.copyWith(
          ordersDone: newDoneOrders,
          ordersDoneTotal: ordersDoneTotal,
          averageDeliveryHours: averageDeliveryHours,
        );
      case 'مهمل':
        return state.copyWith(
          ordersNeglected: state.ordersNeglected.where((o) => o.orderCode.toString() != orderCode).toList(),
        );
      case 'ملغي':
        final newCanceledOrders = state.ordersCanceled.where((o) => o.orderCode.toString() != orderCode).toList();
        _calculateStatistics(state.ordersDone, newCanceledOrders);
        return state.copyWith(
          ordersCanceled: newCanceledOrders,
          ordersCanceledTotal: ordersCanceledTotal,
        );
      default:
        return state;
    }
  }

  /// Update order in specific list
  OrdersLoaded _updateOrderInList(OrdersLoaded state, OrderModel order, String orderState) {
    switch (orderState) {
      case 'جاري التاكيد':
        return state.copyWith(
          ordersRecent: state.ordersRecent.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      case 'مؤكد':
        return state.copyWith(
          ordersConfirmed: state.ordersConfirmed.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      case 'جاري التحضير':
        return state.copyWith(
          ordersPreparing: state.ordersPreparing.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      case 'جاري التوصيل':
        return state.copyWith(
          ordersDelivering: state.ordersDelivering.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      case 'تم التوصيل':
        return state.copyWith(
          ordersDone: state.ordersDone.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      case 'مهمل':
        return state.copyWith(
          ordersNeglected: state.ordersNeglected.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      case 'ملغي':
        return state.copyWith(
          ordersCanceled: state.ordersCanceled.map((o) => o.orderCode == order.orderCode ? order : o).toList(),
        );
      default:
        return state;
    }
  }

  /// Add order to list by state
  OrdersLoaded _addOrderToListByState(OrdersLoaded state, OrderModel order, String orderState) {
    switch (orderState) {
      case 'جاري التاكيد':
        return state.copyWith(ordersRecent: [order, ...state.ordersRecent]);
      case 'مؤكد':
        return state.copyWith(ordersConfirmed: [order, ...state.ordersConfirmed]);
      case 'جاري التحضير':
        return state.copyWith(ordersPreparing: [order, ...state.ordersPreparing]);
      case 'جاري التوصيل':
        return state.copyWith(ordersDelivering: [order, ...state.ordersDelivering]);
      case 'تم التوصيل':
        _calculateStatistics([order, ...state.ordersDone], state.ordersCanceled);
        return state.copyWith(
          ordersDone: [order, ...state.ordersDone],
          ordersDoneTotal: ordersDoneTotal,
          averageDeliveryHours: averageDeliveryHours,
        );
      case 'مهمل':
        return state.copyWith(ordersNeglected: [order, ...state.ordersNeglected]);
      case 'ملغي':
        _calculateStatistics(state.ordersDone, [order, ...state.ordersCanceled]);
        return state.copyWith(
          ordersCanceled: [order, ...state.ordersCanceled],
          ordersCanceledTotal: ordersCanceledTotal,
        );
      default:
        return state;
    }
  }

  /// Generic method to load more orders
  Future<void> _loadMoreOrders({
    required String state,
    required String orderType,
    required List<OrderModel> Function(OrdersLoaded) getCurrentOrders,
    required bool Function(OrdersLoaded) hasMore,
    required bool Function(OrdersLoaded) isLoading,
    required DocumentSnapshot? Function(OrdersLoaded) getLastDoc,
    required OrdersLoaded Function(OrdersLoaded, List<OrderModel>, bool, DocumentSnapshot?) updateState,
  }) async {
    final currentState = this.state;
    if (currentState is! OrdersLoaded || !hasMore(currentState) || isLoading(currentState)) {
      return;
    }

    emit(_setLoadingState(currentState, orderType, true));

    try {
      final result = await _fetchOrdersByState(state, getLastDoc(currentState));
      
      // Track states for newly loaded orders
      _trackOrderStates(result.orders, state);
      
      final updatedOrders = [...getCurrentOrders(currentState), ...result.orders];

      if (state == 'تم التوصيل' || state == 'ملغي') {
        final doneOrders = state == 'تم التوصيل' ? updatedOrders : getCurrentOrders(currentState);
        final canceledOrders = state == 'ملغي' ? updatedOrders : getCurrentOrders(currentState);
        _calculateStatistics(doneOrders, canceledOrders);
      }

      emit(updateState(currentState, updatedOrders, result.hasMore, result.lastDoc));
    } catch (e) {
      emit(_setLoadingState(currentState, orderType, false));
    }
  }

  OrdersLoaded _setLoadingState(OrdersLoaded state, String orderType, bool isLoading) {
    switch (orderType) {
      case 'recent':
        return state.copyWith(isLoadingMoreRecent: isLoading);
      case 'confirmed':
        return state.copyWith(isLoadingMoreConfirmed: isLoading);
      case 'preparing':
        return state.copyWith(isLoadingMorePreparing: isLoading);
      case 'delivering':
        return state.copyWith(isLoadingMoreDelivering: isLoading);
      case 'done':
        return state.copyWith(isLoadingMoreDone: isLoading);
      case 'neglected':
        return state.copyWith(isLoadingMoreNeglected: isLoading);
      case 'canceled':
        return state.copyWith(isLoadingMoreCanceled: isLoading);
      default:
        return state;
    }
  }

  Future<void> loadMoreRecentOrders() => _loadMoreOrders(
        state: 'جاري التاكيد',
        orderType: 'recent',
        getCurrentOrders: (s) => s.ordersRecent,
        hasMore: (s) => s.hasMoreRecent,
        isLoading: (s) => s.isLoadingMoreRecent,
        getLastDoc: (s) => s.lastRecentDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersRecent: orders,
          hasMoreRecent: hasMore,
          lastRecentDoc: lastDoc,
          isLoadingMoreRecent: false,
        ),
      );

  Future<void> loadMoreConfirmedOrders() => _loadMoreOrders(
        state: 'مؤكد',
        orderType: 'confirmed',
        getCurrentOrders: (s) => s.ordersConfirmed,
        hasMore: (s) => s.hasMoreConfirmed,
        isLoading: (s) => s.isLoadingMoreConfirmed,
        getLastDoc: (s) => s.lastConfirmedDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersConfirmed: orders,
          hasMoreConfirmed: hasMore,
          lastConfirmedDoc: lastDoc,
          isLoadingMoreConfirmed: false,
        ),
      );

  Future<void> loadMorePreparingOrders() => _loadMoreOrders(
        state: 'جاري التحضير',
        orderType: 'preparing',
        getCurrentOrders: (s) => s.ordersPreparing,
        hasMore: (s) => s.hasMorePreparing,
        isLoading: (s) => s.isLoadingMorePreparing,
        getLastDoc: (s) => s.lastPreparingDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersPreparing: orders,
          hasMorePreparing: hasMore,
          lastPreparingDoc: lastDoc,
          isLoadingMorePreparing: false,
        ),
      );

  Future<void> loadMoreDeliveringOrders() => _loadMoreOrders(
        state: 'جاري التوصيل',
        orderType: 'delivering',
        getCurrentOrders: (s) => s.ordersDelivering,
        hasMore: (s) => s.hasMoreDelivering,
        isLoading: (s) => s.isLoadingMoreDelivering,
        getLastDoc: (s) => s.lastDeliveringDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersDelivering: orders,
          hasMoreDelivering: hasMore,
          lastDeliveringDoc: lastDoc,
          isLoadingMoreDelivering: false,
        ),
      );

  Future<void> loadMoreDoneOrders() => _loadMoreOrders(
        state: 'تم التوصيل',
        orderType: 'done',
        getCurrentOrders: (s) => s.ordersDone,
        hasMore: (s) => s.hasMoreDone,
        isLoading: (s) => s.isLoadingMoreDone,
        getLastDoc: (s) => s.lastDoneDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersDone: orders,
          hasMoreDone: hasMore,
          lastDoneDoc: lastDoc,
          isLoadingMoreDone: false,
          ordersDoneTotal: ordersDoneTotal,
          averageDeliveryHours: averageDeliveryHours,
        ),
      );

  Future<void> loadMoreNeglectedOrders() => _loadMoreOrders(
        state: 'مهمل',
        orderType: 'neglected',
        getCurrentOrders: (s) => s.ordersNeglected,
        hasMore: (s) => s.hasMoreNeglected,
        isLoading: (s) => s.isLoadingMoreNeglected,
        getLastDoc: (s) => s.lastNeglectedDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersNeglected: orders,
          hasMoreNeglected: hasMore,
          lastNeglectedDoc: lastDoc,
          isLoadingMoreNeglected: false,
          averageDeliveryHours: averageDeliveryHours,
        ),
      );

  Future<void> loadMoreCanceledOrders() => _loadMoreOrders(
        state: 'ملغي',
        orderType: 'canceled',
        getCurrentOrders: (s) => s.ordersCanceled,
        hasMore: (s) => s.hasMoreCanceled,
        isLoading: (s) => s.isLoadingMoreCanceled,
        getLastDoc: (s) => s.lastCanceledDoc,
        updateState: (s, orders, hasMore, lastDoc) => s.copyWith(
          ordersCanceled: orders,
          hasMoreCanceled: hasMore,
          lastCanceledDoc: lastDoc,
          isLoadingMoreCanceled: false,
          ordersCanceledTotal: ordersCanceledTotal,
        ),
      );

  Future<_PaginatedResult> _fetchOrdersByState(
    String orderState,
    DocumentSnapshot? lastDoc,
  ) async {
    Query query = db
        .collection('orders')
        .where('state', isEqualTo: orderState)
        .orderBy('date', descending: true)
        .limit(pageSize);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final querySnapshot = await query.get();
    final List<OrderModel> orders = [];
    DocumentSnapshot? newLastDoc;

    final uniqueClientIds = querySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['clientId'] as String?)
        .where((id) => id != null && !_clientsCache.containsKey(id))
        .toSet();

    if (uniqueClientIds.isNotEmpty) {
      await _batchFetchClients(uniqueClientIds);
    }

    for (var doc in querySnapshot.docs) {
      final order = OrderModel.fromFirestore(doc);

      if (_ordersCache.containsKey(order.orderCode.toString())) {
        orders.add(_ordersCache[order.orderCode.toString()]!);
      } else {
        order.client = _clientsCache[order.clientId] ?? _getDefaultClient();
        _ordersCache[order.orderCode.toString()] = order;
        orders.add(order);
      }

      newLastDoc = doc;
    }

    return _PaginatedResult(
      orders: orders,
      hasMore: querySnapshot.docs.length == pageSize,
      lastDoc: newLastDoc,
    );
  }

  Future<void> _batchFetchClients(Set<String?> clientIds) async {
    final validIds = clientIds.whereType<String>().toList();
    
    for (int i = 0; i < validIds.length; i += 10) {
      final batch = validIds.skip(i).take(10).toList();
      
      final querySnapshot = await db
          .collection('clients')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (var doc in querySnapshot.docs) {
        _clientsCache[doc.id] = ClientModel.fromFirestore(doc);
      }
    }
  }

  ClientModel _getDefaultClient() {
    return ClientModel(
      uid: '',
      businessName: 'عميل غير معروف',
      imageUrl: '',
      phoneNumber: '',
      secondPhoneNumber: '',
      geoLocation: const GeoPoint(30.0444, 31.2357),
      category: '',
      government: '',
      town: '',
      addressTyped: '',
    );
  }

  Future<ClientModel?> fetchClient(String? clientId) async {
    if (clientId == null) return null;
    
    if (_clientsCache.containsKey(clientId)) {
      return _clientsCache[clientId];
    }

    try {
      final clientDoc = await db.collection('clients').doc(clientId).get();
      
      if (clientDoc.exists) {
        final client = ClientModel.fromFirestore(clientDoc);
        _clientsCache[clientId] = client;
        return client;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _calculateStatistics(
      List<OrderModel> doneOrders, List<OrderModel> canceledOrders) {
    ordersDoneTotal =
        doneOrders.fold(0, (sum, order) => sum + order.totalWithOffer);
    ordersCanceledTotal =
        canceledOrders.fold(0, (sum, order) => sum + order.totalWithOffer);

    final totalOrders = doneOrders.length + canceledOrders.length;
    canceledOrdersPercent =
        totalOrders > 0 ? (canceledOrders.length / totalOrders) * 100 : 0;

    clients.clear();
    final uniqueClientIds = <String>{};
    for (var order in doneOrders) {
      if (order.client?.uid != null && order.client!.uid.isNotEmpty) {
        uniqueClientIds.add(order.client!.uid);
      }
    }
    clients = uniqueClientIds.toList();

    double totalDeliveryHours = 0;
    int deliveryCount = 0;
    
    for (var order in doneOrders) {
      if (order.doneAt != null) {
        final orderDate = order.date.toDate();
        final orderDoneAt = order.doneAt!.toDate();
        final diffHours = orderDoneAt.difference(orderDate).inMinutes / 60.0;
        totalDeliveryHours += diffHours;
        deliveryCount++;
      }
    }
    
    averageDeliveryHours =
        deliveryCount > 0 ? totalDeliveryHours / deliveryCount : 0;
  }

  /// Update order state - handles state transitions properly
  Future<void> updateState(String orderCode, String newState) async {
    try {
      // Update Firestore - streams will handle the rest
      await db.collection('orders').doc(orderCode).update({
        'state': newState,
        'doneAt': newState == 'تم التوصيل' ? FieldValue.serverTimestamp() : null,
      });
      
      // Note: The real-time listener will automatically handle:
      // 1. Removing from old state (via _handleOrderAdded detecting state change)
      // 2. Adding to new state (via DocumentChangeType.added)
      // No manual state management needed here
    } catch (e) {
      debugPrint('Error updating order state: $e');
      emit(OrdersError('خطأ في تحديث حالة الطلب: ${e.toString()}'));
    }
  }

  // Product selection and controller methods
  List<TextEditingController> controllersList(OrderModel order) {
    controllers = List.generate(
      order.products.length,
      (index) => TextEditingController(
        text: order.products[index]['controller']?.toString() ?? '',
      ),
    );
    return controllers;
  }

  List<bool> productSelection(OrderModel order) {
    if (order.products.isEmpty) return [];
    selectionList = List.filled(order.products.length, true);
    return selectionList;
  }

  void updateProductSelection(int index, bool value) {
    if (index >= 0 && index < selectionList.length) {
      selectionList[index] = value;
      final currentState = state;
      if (currentState is OrdersLoaded) {
        emit(currentState.copyWith());
      }
    }
  }

  bool areControllersEqual(List<TextEditingController> controllers, List products) {
    if (controllers.length != products.length) return false;
    
    for (int i = 0; i < controllers.length; i++) {
      final currentValue = int.tryParse(controllers[i].text);
      final storedValue = products[i]['controller'] ?? 0;
      if (currentValue != storedValue) return false;
    }
    return true;
  }

  Future<void> updateProductControllers(
    List<TextEditingController> controllers,
    List products,
    String orderCode,
  ) async {
    if (areControllersEqual(controllers, products)) return;

    final updatedProducts = List.generate(
      controllers.length,
      (index) => {
        ...products[index],
        'controller': int.tryParse(controllers[index].text) ?? 0,
      },
    );

    await db.collection('orders').doc(orderCode).update({
      'products': updatedProducts,
    });
  }

  Future<void> removeFromFirebase(List products, String orderCode) async {
    if (products.length > selectedProducts.length) {
      await db.collection('orders').doc(orderCode).update({
        'products': selectedProducts,
      });
    }
  }

  Future<void> initSelectedProducts(
    List products,
    List<bool> selection,
    List selectedProducts,
    List<TextEditingController> controllers,
  ) async {
    selectedProducts.clear();

    for (int i = 0; i < products.length; i++) {
      if (selection[i]) {
        products[i]['controller'] = int.tryParse(controllers[i].text) ?? 0;
        selectedProducts.add(products[i]);
      }
    }

    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState.copyWith(selectedProducts: selectedProducts));
    }
  }

  void clearCache() {
    _ordersCache.clear();
    _clientsCache.clear();
    _orderStates.clear();
  }

  @override
  Future<void> close() {
    // Cancel all stream subscriptions
    for (var subscription in _streamSubscriptions.values) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    
    // Dispose controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    clearCache();
    return super.close();
  }
}

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