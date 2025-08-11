import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/available_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/offer_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/unavailable_screen.dart';
import 'package:goods/presentation/sheets/sheet_store_search.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedTabIndex.dispose();
    super.dispose();
  }

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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => StoreSearchSheet(
                            selectedTabIndexNotifier: _selectedTabIndex),
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
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
                height: 40,
                color: Theme.of(context).hoverColor,
                child: TabBar(
                  isScrollable: false,
                  tabs: const [
                    Tab(text: 'عروض'),
                    Tab(text: 'موجود'),
                    Tab(text: 'غير موجود'),
                  ],
                  onTap: (index) {
                    _selectedTabIndex.value = index;
                  },
                ),
              ),
              const Flexible(

                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [Offer(), Available(), UnAvailable()],
                ),
              ),
            ],
          )),
    );
  }
}
