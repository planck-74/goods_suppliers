import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/dialog_confirmation.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/recent/recent_orders_card.dart';
import 'package:goods/presentation/skeletons/recent_orders_card_skeleton.dart';

class Preparing extends StatefulWidget {
  const Preparing({super.key});

  @override
  State<Preparing> createState() => _PreparingState();
}

class _PreparingState extends State<Preparing> {
  /// Sorting flag: true = Newest First, false = Oldest First
  bool isRecentFirst = true;

  /// Refresh orders by re-fetching them from Firestore
  Future<void> _refreshOrders() async {
    await context.read<OrdersCubit>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          List preparingOrders = List.from(state.ordersPreparing);

          // Sort orders based on the flag
          preparingOrders.sort((a, b) => isRecentFirst
                  ? b.date.compareTo(a.date) // Newest First
                  : a.date.compareTo(b.date) // Oldest First
              );

          return Column(
            children: [
              _buildSortingBar(),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _refreshOrders,
                  child: preparingOrders.isNotEmpty
                      ? ListView.builder(
                          itemCount: preparingOrders.length,
                          itemBuilder: (BuildContext context, int index) {
                            final order = preparingOrders[index];
                            final client = order.client;

                            return RecentOrdersCard(
                              client: client,
                              order: order,
                              state: 'توصيل',
                              onPressed1: () => showConfirmationDialog(
                                context: context,
                                content: 'هل تم توصيل هذا الطلب؟',
                                onConfirm: () => orderDone(context, order),
                              ),
                              onPressed2: () => showConfirmationDialog(
                                context: context,
                                content: 'هل أنت متأكد من رفض الطلب؟',
                                elevatedButtonbackgroundColor: Colors.red,
                                elevatedButtonName: 'رفض',
                                onConfirm: () => cancel(context, order),
                              ),
                              orders: preparingOrders,
                              navigatorScreen: '/PreparingItemsScreen',
                            );
                          },
                        )
                      : const Center(child: Text('لا توجد طلبات جارٍ التحضير')),
                ),
              ),
            ],
          );
        } else if (state is OrdersLoading) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => const RecentOrdersCardSkeleton(),
          );
        }
        return const SizedBox();
      },
    );
  }

  /// Sorting Bar Widget (⬆⬇)
  Widget _buildSortingBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Row(
              children: [
                const Text('الأقدم أولاً ',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 15)),
                Icon(Icons.arrow_upward,
                    color: isRecentFirst ? Colors.grey : Colors.blue),
              ],
            ),
            onPressed: () {
              if (isRecentFirst) {
                setState(() {
                  isRecentFirst = false; // Switch to Oldest First
                });
              }
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Row(
              children: [
                const Text('الأحدث أولاً ',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 15)),
                Icon(Icons.arrow_downward,
                    color: isRecentFirst ? Colors.blue : Colors.grey),
              ],
            ),
            onPressed: () {
              if (!isRecentFirst) {
                setState(() {
                  isRecentFirst = true; // Switch to Newest First
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Called when an order is marked as done (delivered).
void orderDone(BuildContext context, dynamic order) async {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  List<String> Ids = [];
  // Update the order state in Firestore.
  ordersCubit.updateState(order.orderCode.toString(), 'تم التوصيل');
  ordersCubit.ordersDone.add(order);
  ordersCubit.ordersPreparing.remove(order);

  final currentOrder = order as OrderModel;
  final products = currentOrder.products;

  for (var product in products) {
    final productId = product['product']['productId'];
    Ids.add(productId);
  }
  print(Ids.length);
  updateSaleCount(Ids);
}

/// Called when an order is cancelled.
void cancel(BuildContext context, dynamic order) {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'ملغي');
  ordersCubit.ordersCanceled.add(order);
  ordersCubit.ordersPreparing.remove(order);
}

Future<void> updateSaleCount(List<String> ids) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in querySnapshot.docs) {
      final currentSales = doc.data()['salesCount'] ?? 0;
      final docRef = doc.reference;
      batch.update(docRef, {'salesCount': currentSales + 1});
    }

    await batch.commit();
    print('Sales count updated for ${ids.length} products.');
  } catch (e) {
    print('Error updating sales count: $e');
  }
}
