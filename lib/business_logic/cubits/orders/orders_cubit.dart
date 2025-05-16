import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final List<OrderModel> ordersRecent = [];
  final List<OrderModel> ordersPreparing = [];
  final List<OrderModel> ordersDone = [];
  final List<OrderModel> ordersCanceled = [];
  final List<OrderModel> orders = [];
  List<TextEditingController> controllers = [];
  List<Map> selectedProducts = [];
  List<bool> selectionList = [];
  List<String> clients = [];

  int ordersDoneTotal = 0;
  int ordersCanceledTotal = 0;
  double canceledOrdersPercent = 0;
  double averageDeliveryHours = 0.0;

  OrdersCubit() : super(OrdersInitial());

  /// Fetch all orders without filtering.
  Future<List<OrderModel>> fetchOrders() async {
    emit(OrdersLoading());
    try {
      final querySnapshot = await db.collection('orders').get();
      final ordersData = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Reset lists and totals
      ordersRecent.clear();
      ordersPreparing.clear();
      ordersDone.clear();
      ordersCanceled.clear();
      ordersDoneTotal = 0;
      ordersCanceledTotal = 0;

      for (var order in ordersData) {
        ClientModel? client = await fetchClient(order.clientId);
        client ??= ClientModel(
          uid: '',
          businessName: '',
          imageUrl: '',
          phoneNumber: '',
          secondPhoneNumber: '',
          geoPoint: const GeoPoint(30.0444, 31.2357),
          category: '',
          government: '',
          town: '',
        );
        order.client = client;

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
        }
      }

      // Calculate totals for ordersDone and ordersCanceled
      ordersDoneTotal =
          ordersDone.fold(0, (sum, order) => sum + order.totalWithOffer);
      ordersCanceledTotal =
          ordersCanceled.fold(0, (sum, order) => sum + order.totalWithOffer);
      canceledOrdersPercent = (ordersCanceled.length /
              (ordersDone.length + ordersCanceled.length)) *
          100;

      // Collect unique client ids from ordersDone
      clients.clear();
      for (var order in ordersDone) {
        if (order.client?.uid != null && !clients.contains(order.client!.uid)) {
          clients.add(order.client!.uid);
        }
      }

      // Compute average delivery period (in hours) based on 'date' and 'doneAt'
      double totalDeliveryHours = 0;
      int deliveryCount = 0;
      for (var order in ordersDone) {
        if (order.doneAt != null) {
          DateTime orderDate = order.date.toDate();
          DateTime orderDoneAt = order.doneAt!.toDate();
          double diffHours = orderDoneAt.difference(orderDate).inMinutes / 60.0;
          totalDeliveryHours += diffHours;
          deliveryCount++;
        }
      }
      averageDeliveryHours =
          deliveryCount > 0 ? totalDeliveryHours / deliveryCount : 0;

      emit(OrdersLoaded(
        ordersData,
        ordersRecent,
        ordersPreparing,
        ordersDone,
        ordersCanceled,
        selectedProducts,
        clients,
        ordersDoneTotal,
        ordersCanceledTotal,
        averageDeliveryHours,
      ));
      return ordersData;
    } catch (e) {
      emit(OrdersError());
      return [];
    }
  }

  /// Fetch orders that fall within the provided start and end dates.
  Future<List<OrderModel>> fetchOrdersByPeriod(
      DateTime start, DateTime end) async {
    emit(OrdersLoading());
    try {
      final querySnapshot = await db
          .collection('orders')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final ordersData = querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Reset lists and totals
      ordersRecent.clear();
      ordersPreparing.clear();
      ordersDone.clear();
      ordersCanceled.clear();
      ordersDoneTotal = 0;
      ordersCanceledTotal = 0;

      for (var order in ordersData) {
        ClientModel? client = await fetchClient(order.clientId);
        client ??= ClientModel(
          uid: '',
          businessName: '',
          imageUrl: '',
          phoneNumber: '',
          secondPhoneNumber: '',
          geoPoint: const GeoPoint(30.0444, 31.2357),
          category: '',
          government: '',
          town: '',
        );
        order.client = client;

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
        }
      }

      // Calculate totals for ordersDone and ordersCanceled
      ordersDoneTotal =
          ordersDone.fold(0, (sum, order) => sum + order.totalWithOffer);
      ordersCanceledTotal =
          ordersCanceled.fold(0, (sum, order) => sum + order.totalWithOffer);
      canceledOrdersPercent = (ordersCanceled.length /
              (ordersDone.length + ordersCanceled.length)) *
          100;

      // Collect unique client ids from ordersDone
      clients.clear();
      for (var order in ordersDone) {
        if (order.client?.uid != null && !clients.contains(order.client!.uid)) {
          clients.add(order.client!.uid);
        }
      }

      // Compute average delivery period (in hours) based on 'date' and 'doneAt'
      double totalDeliveryHours = 0;
      int deliveryCount = 0;
      for (var order in ordersDone) {
        if (order.doneAt != null) {
          DateTime orderDate = order.date.toDate();
          DateTime orderDoneAt = order.doneAt!.toDate();
          double diffHours = orderDoneAt.difference(orderDate).inMinutes / 60.0;
          totalDeliveryHours += diffHours;
          deliveryCount++;
        }
      }
      averageDeliveryHours =
          deliveryCount > 0 ? totalDeliveryHours / deliveryCount : 0;

      emit(OrdersLoaded(
        ordersData,
        ordersRecent,
        ordersPreparing,
        ordersDone,
        ordersCanceled,
        selectedProducts,
        clients,
        ordersDoneTotal,
        ordersCanceledTotal,
        averageDeliveryHours,
      ));
      return ordersData;
    } catch (e) {
      emit(OrdersError());
      return [];
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

  Future<void> updateState(String orderCode, String state) async {
    await db.collection('orders').doc(orderCode).update({
      'state': state,
      'doneAt': FieldValue.serverTimestamp(),
    });

    emit(OrdersLoaded(
      orders,
      ordersRecent,
      ordersPreparing,
      ordersDone,
      ordersCanceled,
      selectedProducts,
      clients,
      ordersDoneTotal,
      ordersCanceledTotal,
      averageDeliveryHours,
    ));
  }

  // Returns a list of TextEditingControllers based on the order's products.
  List<TextEditingController> controllersList(order) {
    controllers = List.generate(
      order.products.length,
      (index) {
        final controllerValue =
            order.products[index]['controller']?.toString() ?? '';
        return TextEditingController(text: controllerValue);
      },
    );
    emit(OrdersLoaded(
      orders,
      ordersRecent,
      ordersPreparing,
      ordersDone,
      ordersCanceled,
      selectedProducts,
      clients,
      ordersDoneTotal,
      ordersCanceledTotal,
      averageDeliveryHours,
    ));
    return controllers;
  }

  // Initialize the product selection list for the order.
  List<bool> productSelection(order) {
    if (order.products == null || order.products.isEmpty) {
      return [];
    }

    selectionList = List.generate(
      order.products.length,
      (index) => true,
    );

    emit(OrdersLoaded(
      orders,
      ordersRecent,
      ordersPreparing,
      ordersDone,
      ordersCanceled,
      selectedProducts,
      clients,
      ordersDoneTotal,
      ordersCanceledTotal,
      averageDeliveryHours,
    ));
    return selectionList;
  }

  void updateProductSelection(int index, bool value) {
    selectionList[index] = value;
    emit(OrdersLoaded(
      orders,
      ordersRecent,
      ordersPreparing,
      ordersDone,
      ordersCanceled,
      selectedProducts,
      clients,
      ordersDoneTotal,
      ordersCanceledTotal,
      averageDeliveryHours,
    ));
  }

  // Helper function to compare controllers with stored product values.
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

  // Updates product controllers if changes are detected.
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

  // Initializes the list of selected products based on user selection.
  Future<void> initselectedProducts(List products, List<bool> selection,
      List selectedProducts, List<TextEditingController> controllers) async {
    selectedProducts.clear();

    for (var i = 0; i < products.length; i++) {
      if (selection[i] == true) {
        products[i]['controller'] = int.parse(controllers[i].text);
        selectedProducts.add(products[i]);
      }
    }

    emit(OrdersLoaded(
      orders,
      ordersRecent,
      ordersPreparing,
      ordersDone,
      ordersCanceled,
      selectedProducts,
      clients,
      ordersDoneTotal,
      ordersCanceledTotal,
      averageDeliveryHours,
    ));
    print('Selected products updated: $selectedProducts');
  }
}
