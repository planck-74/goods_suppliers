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
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  int selectedIndex = 0;

  final List<NavigationItem> navigationItems = [
    NavigationItem(
      screen: const Orders(),
      icon: 'assets/icons/invoice.png',
      label: 'الطلبات',
      iconSize: 38,
    ),
    NavigationItem(
      screen: const Store(),
      icon: 'assets/icons/hanger.png',
      label: 'المخزن',
      iconSize: 34,
    ),
    NavigationItem(
      screen: const Reports(),
      icon: 'assets/icons/reports.png',
      label: 'تقارير',
      iconSize: 40,
    ),
    NavigationItem(
      screen: const Contact(),
      icon: 'assets/icons/chat.png',
      label: 'تـواصل',
      iconSize: 38,
    ),
    NavigationItem(
      screen: const Profile(),
      icon: 'assets/icons/user.png',
      label: 'الحساب',
      iconSize: 36,
    ),
  ];

  void itemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد إذا كان الجهاز desktop أم لا
        bool isDesktop = constraints.maxWidth >= 768;
        
        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'نظام إدارة السلع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = navigationItems[index];
                      final isSelected = selectedIndex == index;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected 
                              ? primaryColor.withOpacity(0.1)
                              : null,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: ListTile(
                          leading: ImageIcon(
                            AssetImage(item.icon),
                            size: item.iconSize * 0.8, // أصغر شوية للسايدبار
                            color: isSelected 
                                ? primaryColor 
                                : darkBlueColor.withOpacity(0.7),
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                              color: isSelected 
                                  ? primaryColor 
                                  : darkBlueColor.withOpacity(0.8),
                            ),
                          ),
                          onTap: () => itemSelected(index),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ));
                    },
                  ),
                ),
                // Footer info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'إصدار 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkBlueColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: navigationItems[selectedIndex].screen,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Container(
        height: 75,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedFontSize: 14,
          selectedFontSize: 14,
          fixedColor: primaryColor,
          elevation: 0, // إزالة الـ elevation الافتراضي
          iconSize: 32,
          unselectedItemColor: darkBlueColor.withOpacity(0.95),
          items: navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(item.icon),
                size: item.iconSize,
              ),
              label: item.label,
            );
          }).toList(),
          currentIndex: selectedIndex,
          onTap: itemSelected,
        ),
      ),
    );
  }
}

// Helper class لتنظيم بيانات الـ navigation
class NavigationItem {
  final Widget screen;
  final String icon;
  final String label;
  final double iconSize;

  NavigationItem({
    required this.screen,
    required this.icon,
    required this.label,
    required this.iconSize,
  });
}