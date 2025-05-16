import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/contact/contact_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/reports_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/main_store.dart';
import 'package:goods/presentation/screens/profile_screen.dart';
import 'orders/orders_screen.dart';

class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});

  @override
  State<NavigatorBar> createState() => _NvigatorBarState();
}

class _NvigatorBarState extends State<NavigatorBar> {
  int selectedIndex = 0;

  List<Widget> navigatorBarScreens = [
    const Orders(),
    const Store(),
    const Reports(),
    const Contact(),
    const Profile(),
  ];
  itemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: navigatorBarScreens,
      ),
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: 14,
          fixedColor: primaryColor,
          elevation: 20,
          iconSize: 32,
          selectedFontSize: 14,
          unselectedItemColor: darkBlueColor.withOpacity(0.95),
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 38,
                AssetImage('assets/icons/invoice.png'),
              ),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 34,
                AssetImage('assets/icons/hanger.png'),
              ),
              label: 'المخزن',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 40,
                AssetImage('assets/icons/reports.png'),
              ),
              label: 'تقارير',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 38,
                AssetImage('assets/icons/chat.png'),
              ),
              label: 'تـواصل',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                size: 36,
                AssetImage('assets/icons/user.png'),
              ),
              label: 'الحساب',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: itemSelected,
        ),
      ),
    );
  }
}
