
// ============= Canceled Screen =============
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/canceled/canceled_orders_card.dart';
import 'package:goods/presentation/skeletons/done__orders_card_skeleton.dart';

class Canceled extends StatefulWidget {
  const Canceled({super.key});

  @override
  State<Canceled> createState() => _CanceledState();
}

class _CanceledState extends State<Canceled> {
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
      context.read<OrdersCubit>().loadMoreCanceledOrders();
    }
  }

  Future<void> _refreshOrders() async {
    await context.read<OrdersCubit>().fetchInitialOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return const DoneOrdersCardSkeleton();
            },
          );
        }

        if (state is OrdersLoaded) {
          List canceledOrders = List.from(state.ordersCanceled);

          canceledOrders.sort((a, b) => isRecentFirst
                  ? b.date.compareTo(a.date)
                  : a.date.compareTo(b.date)
              );

          return Column(
            children: [
              _buildSortingBar(),
              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _refreshOrders,
                  child: canceledOrders.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: canceledOrders.length + 
                              (state.isLoadingMoreCanceled ? 1 : 0) +
                              (!state.hasMoreCanceled && canceledOrders.isNotEmpty ? 1 : 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == canceledOrders.length) {
                              if (state.isLoadingMoreCanceled) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              } else if (!state.hasMoreCanceled) {
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

                            final order = canceledOrders[index];
                            final client = order.client;

                            return CanceledOrdersCard(
                              client: client,
                              order: order,
                              state: 'مرفوض',
                              orders: canceledOrders,
                            );
                          },
                        )
                      : ListView(
                          controller: _scrollController,
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('لا توجد طلبات ملغية')),
                          ],
                        ),
                ),
              ),
            ],
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

  Widget _buildSortingBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
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