import 'package:flutter/material.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
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
                child: const TabBar(
                    labelStyle: TextStyle(fontSize: 14, fontFamily: 'Cairo'),
                    indicatorColor: Colors.grey,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        text: 'حديث',
                      ),
                      Tab(
                        text: 'جارٍ التحضير',
                      ),
                      Tab(
                        text: 'تم التوصيل',
                      ),
                      Tab(
                        text: 'ملغي',
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
