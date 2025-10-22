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
  bool isRecentFirst = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<OrdersCubit>().loadMorePreparingOrders();
    }
  }

  Future<void> _refreshOrders() async {
    await context.read<OrdersCubit>().fetchInitialOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          List preparingOrders = List.from(state.ordersPreparing);

          preparingOrders.sort((a, b) => isRecentFirst
              ? b.date.compareTo(a.date)
              : a.date.compareTo(b.date));

          return Column(
            children: [
              _buildSortingBar(),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _refreshOrders,
                  child: preparingOrders.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: preparingOrders.length +
                              (state.isLoadingMorePreparing ? 1 : 0) +
                              (!state.hasMorePreparing &&
                                      preparingOrders.isNotEmpty
                                  ? 1
                                  : 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == preparingOrders.length) {
                              if (state.isLoadingMorePreparing) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              } else if (!state.hasMorePreparing) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'تم عرض جميع الطلبات',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                );
                              }
                            }

                            final order = preparingOrders[index];
                            final client = order.client;

                            return RecentOrdersCard(
                              client: client,
                              order: order,
                              state: 'بدء التوصيل',
                              onPressed1: () => showConfirmationDialog(
                                context: context,
                                content: 'هل تم توصيل هذا الطلب؟',
                                onConfirm: () =>
                                    startDelivering(context, order),
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
                      : ListView(
                          controller: _scrollController,
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('لا توجد طلبات جارٍ التحضير')),
                          ],
                        ),
                ),
              ),
            ],
          );
        } else if (state is OrdersLoading) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => const RecentOrdersCardSkeleton(),
          );
        } else if (state is OrdersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('حدث خطأ في تحميل الطلبات'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<OrdersCubit>().fetchInitialOrders(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

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
                  isRecentFirst = false;
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
                  isRecentFirst = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

void startDelivering(BuildContext context, dynamic order) async {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'جاري التوصيل');

  final currentOrder = order as OrderModel;
  final products = currentOrder.products;
  List<String> Ids = [];

  for (var product in products) {
    final productId = product['product']['productId'];
    Ids.add(productId);
  }
  print(Ids.length);
  updateSaleCount(Ids);
}

void cancel(BuildContext context, dynamic order) {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'ملغي');
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
