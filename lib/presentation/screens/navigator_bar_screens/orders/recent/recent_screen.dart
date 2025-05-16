import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/dialog_confirmation.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/recent/recent_orders_card.dart';
import 'package:goods/presentation/skeletons/recent_orders_card_skeleton.dart';

class Recent extends StatefulWidget {
  const Recent({super.key});

  @override
  State<Recent> createState() => _RecentState();
}

class _RecentState extends State<Recent> {
  /// Flag to indicate sorting order.
  /// When true: orders are sorted from recent (newest) to past (oldest)
  /// When false: orders are sorted from oldest to newest.
  bool isRecentFirst = true;

  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().fetchOrders();
  }

  Future<void> _refreshOrders() async {
    await context.read<OrdersCubit>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          final recentOrders = state.ordersRecent;
          List sortedOrders = List.from(recentOrders);

          if (sortedOrders.isNotEmpty) {
            sortedOrders.sort((a, b) {
              // Assuming order.date is a DateTime object.
              return isRecentFirst
                  ? b.date.compareTo(a.date) // Descending: newest first.
                  : a.date.compareTo(b.date); // Ascending: oldest first.
            });
          }

          return Column(
            children: [
              _buildClassificationBar(),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _refreshOrders,
                  child: sortedOrders.isNotEmpty
                      ? ListView.builder(
                          itemCount: sortedOrders.length,
                          itemBuilder: (BuildContext context, int index) {
                            final order = sortedOrders[index];
                            final client = order.client;

                            return RecentOrdersCard(
                              client: client,
                              order: order,
                              state: 'بدء التحضير',
                              onPressed1: () => showConfirmationDialog(
                                context: context,
                                content: 'هل أنت جاهز لتحضير هذا الطلب؟',
                                onConfirm: () => startPreparing(context, order),
                              ),
                              onPressed2: () => showConfirmationDialog(
                                context: context,
                                content: 'هل أنت متأكد من رفض الطلب؟',
                                elevatedButtonbackgroundColor: Colors.red,
                                elevatedButtonName: 'رفض',
                                onConfirm: () => cancel(context, order),
                              ),
                              orders: sortedOrders,
                              navigatorScreen: '/RecentItemsScreen',
                            );
                          },
                        )
                      : const Center(
                          child: Text('لا توجد طلبات حديثة'),
                        ),
                ),
              ),
            ],
          );
        }

        if (state is OrdersLoading) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return const RecentOrdersCardSkeleton();
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildClassificationBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
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
                const Text(
                  'الأقدم أولاً ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                ),
                Icon(
                  Icons.arrow_upward,
                  color: isRecentFirst
                      ? Colors.grey
                      : Colors.blue, // Highlight selected
                ),
              ],
            ),
            onPressed: () {
              if (isRecentFirst) {
                setState(() {
                  isRecentFirst = false; // Sort from past to recent
                });
              }
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Row(
              children: [
                const Text(
                  'الأحدث أولاً ',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                ),
                Icon(
                  Icons.arrow_downward,
                  color: isRecentFirst ? Colors.blue : Colors.grey,
                ),
              ],
            ),
            onPressed: () {
              if (!isRecentFirst) {
                setState(() {
                  isRecentFirst = true; // Sort from recent to past
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

void startPreparing(BuildContext context, dynamic order) {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'جاري التحضير');
  ordersCubit.ordersPreparing.add(order);
  ordersCubit.ordersRecent.remove(order);
}

void cancel(BuildContext context, dynamic order) {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'ملغي');
  ordersCubit.ordersCanceled.add(order);
  ordersCubit.ordersRecent.remove(order);
}
