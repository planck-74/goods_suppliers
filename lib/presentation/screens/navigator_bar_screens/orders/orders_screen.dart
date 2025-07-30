import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/canceled/canceled_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/done/done_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/preparing/preparing_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/recent/recent_screen.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _ordersState();
}

class _ordersState extends State<Orders> {
  @override
@override
void initState() {
  super.initState();
  _loadOrders(); 
}

void _loadOrders() async {
  await context.read<OrdersCubit>().fetchOrders();
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: customAppBar(
              context,
              const Row(
                children: [
                  Text(
                    'فواتيرك',
                    style: TextStyle(color: whiteColor),
                  )
                ],
              )),
          body: Column(
            children: [
              Container(
                height: 40,
                color: whiteColor,
                child: TabBar(
                    labelStyle: TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                    indicatorColor: Colors.grey,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('حديث'),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: BlocBuilder<OrdersCubit, OrdersState>(
                                builder: (context, state) {
                                  if (state is OrdersLoaded) {
                                    return Text(
                                      '${context.read<OrdersCubit>().ordersRecent.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                                Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('جارٍ التحضير'),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: BlocBuilder<OrdersCubit, OrdersState>(
                                builder: (context, state) {
                                  if (state is OrdersLoaded) {
                                    return Text(
                                      '${context.read<OrdersCubit>().ordersPreparing.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                     Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('تم التوصيل'),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: BlocBuilder<OrdersCubit, OrdersState>(
                                builder: (context, state) {
                                  if (state is OrdersLoaded) {
                                    return Text(
                                      '${context.read<OrdersCubit>().ordersDone.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                     Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('ملغي'),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: BlocBuilder<OrdersCubit, OrdersState>(
                                builder: (context, state) {
                                  if (state is OrdersLoaded) {
                                    return Text(
                                      '${context.read<OrdersCubit>().ordersCanceled.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                    
                   
                    ]),
              ),
              const Flexible(
                child: TabBarView(
                  children: [
                    Recent(),
                    Preparing(),
                    Done(),
                    Canceled(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
