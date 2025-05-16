import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/available_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/offer_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/unavailable_screen.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: customAppBar(
              context,
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {},
                    child: const Text(
                      'بضاعتك',
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/AddProduct');
                    },
                    icon: const Icon(
                      Icons.add,
                    ),
                  ),
                ],
              )),
          body: Column(
            children: [
              Container(
                height: 35,
                color: Theme.of(context).hoverColor,
                child: const TabBar(tabs: [
                  Tab(
                    text: 'عروض',
                  ),
                  Tab(
                    text: 'موجود',
                  ),
                  Tab(
                    text: 'غير موجود',
                  ),
                ]),
              ),
              const Flexible(
                child: TabBarView(
                  children: [Offer(), Available(), UnAvailable()],
                ),
              ),
            ],
          )),
    );
  }
}
