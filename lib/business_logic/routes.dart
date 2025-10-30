import 'package:flutter/material.dart';
import 'package:goods/presentation/screens/auth_screens/auth_custom_widgets.dart/location_picker.dart';
import 'package:goods/presentation/screens/auth_screens/sign_pages/otp_screen.dart';
import 'package:goods/presentation/screens/edit_profile_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/contact/chat_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/navigator_bar_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/orders_done&canceled_items.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/preparing/preparing_items_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/recent/recent_items_screen.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/store_screens/add_products/add_product.dart';

import '../presentation/screens/auth_screens/sign_pages/sign.dart';

final Map<String, WidgetBuilder> routes = {
  '/Sign': (context) => const Sign(),
  '/EditProfile': (context) => const EditProfile(),
  '/OtpScreen': (context) => const OtpScreen(),
  '/LocationPickerScreen': (context) => const LocationPickerScreen(),
  '/NavigatorBar': (context) => const NavigatorBar(),
  '/AddProduct': (context) => const AddProduct(),
  '/RecentItemsScreen': (context) => const RecentItemsScreen(),
  '/PreparingItemsScreen': (context) => const PreparingItemsScreen(),
  '/OrdersDoneCanceledItems': (context) => const OrdersDoneCanceledItems(),
  '/ChatScreen': (context) => const EnhancedChatScreen(),
};
