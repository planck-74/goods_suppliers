import 'package:flutter/material.dart';
import 'package:goods/presentation/custom_widgets/buildappbar.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/cash_screens.dart/Paid_widget.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/cash_screens.dart/payments_dues_widget.dart';

class Cash extends StatefulWidget {
  const Cash({super.key});

  @override
  State<Cash> createState() => _CashState();
}

class _CashState extends State<Cash> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: buildAppBar(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            context: context,
            screenName: 'كاشات',
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(35),
              child: Container(
                height: 35,
                color: Theme.of(context).hoverColor,
                child: const TabBar(isScrollable: true, tabs: [
                  Tab(
                    text: 'مستحقات',
                  ),
                  Tab(
                    text: 'مدفوعات',
                  ),
                  Tab(
                    text: 'تم السداد ',
                  ),
                ]),
              ),
            ),
            onTap: () {},
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: TabBarView(
                  children: [
                    paymentDues(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        context: context,
                        color: const Color(0xFF04D939),
                        text: 'مستحقاتك'),
                    paymentDues(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        context: context,
                        color: Colors.red,
                        text: 'مدفوعاتك'),
                    paid(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        context: context),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
