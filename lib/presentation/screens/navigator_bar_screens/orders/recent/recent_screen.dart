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
  bool isRecentFirst = true;
  
  /// Scroll controller for detecting when to load more
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial load is handled by the parent widget or when cubit is created
    // If not loaded yet, load initial data
    if (context.read<OrdersCubit>().state is OrdersInitial) {
      context.read<OrdersCubit>().fetchInitialOrders();
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // Trigger load more when reaching 80% of the list
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<OrdersCubit>().loadMoreRecentOrders();
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
          final recentOrders = state.ordersRecent;
          List sortedOrders = List.from(recentOrders);

          if (sortedOrders.isNotEmpty) {
            sortedOrders.sort((a, b) {
              return isRecentFirst
                  ? b.date.compareTo(a.date) 
                  : a.date.compareTo(b.date);  
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
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: sortedOrders.length + 
                              (state.isLoadingMoreRecent ? 1 : 0) +
                              (!state.hasMoreRecent && sortedOrders.isNotEmpty ? 1 : 0),
                          itemBuilder: (BuildContext context, int index) {
                            // Show loading indicator at the bottom
                            if (index == sortedOrders.length) {
                              if (state.isLoadingMoreRecent) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              } else if (!state.hasMoreRecent) {
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
                      : ListView(
                          controller: _scrollController,
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text('لا توجد طلبات حديثة'),
                            ),
                          ],
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

        if (state is OrdersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('حدث خطأ في تحميل الطلبات'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<OrdersCubit>().fetchInitialOrders(),
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
                      : Colors.blue,
                ),
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

void startPreparing(BuildContext context, dynamic order) {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'جاري التحضير');
}

void cancel(BuildContext context, dynamic order) {
  final ordersCubit = BlocProvider.of<OrdersCubit>(context);
  ordersCubit.updateState(order.orderCode.toString(), 'ملغي');
}