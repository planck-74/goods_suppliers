import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/client_model.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/orders_done&canceled_items.dart';
import 'package:goods/presentation/screens/navigator_bar_screens/orders/preparing/preparing_items.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';

class PreparingItemsScreen extends StatefulWidget {
  const PreparingItemsScreen({super.key});

  @override
  State<PreparingItemsScreen> createState() => _RecentItemsState();
}

class _RecentItemsState extends State<PreparingItemsScreen> {
  List<TextEditingController> controllers = [];
  List<bool> productSelection = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic> data =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final OrderModel order = data['order'];

      setState(() {
        controllers = context.read<OrdersCubit>().controllersList(order);
        productSelection = context.read<OrdersCubit>().productSelection(order);
      });
    });
  }

  void onCheckBoxChanged(bool value, int index) {
    setState(() {
      productSelection[index] = value; // Local update for the UI
    });

    // Update the selection list in the OrdersCubit
    context.read<OrdersCubit>().updateProductSelection(index, value);
  }

  @override
  Widget build(BuildContext context) {
    List<Map> selectedProducts = context.read<OrdersCubit>().selectedProducts;

    List<bool> selectionList = context.read<OrdersCubit>().selectionList;

    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ClientModel client = data['client'];
    final OrderModel order = data['order'];
    final List<int> initControllers = data['initControllers'];
   
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: customAppBar(
        context,
        Row(
          children: [
            const Text(
              'تفاصيل الطلب',
              style: TextStyle(color: whiteColor),
            ),
            const Spacer(flex: 1),
            Text(
              '${order.products.length} أصناف',
              style: const TextStyle(
                color: whiteColor,
              ),
            ),
            const SizedBox(
              width: 12,
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UpperContainer(
              order: order,
              client: client,
              selectedProducts: selectedProducts,
            ),
            preparingItems(
                products: order.products,
                selectionList: selectionList,
                controllers: controllers,
                onCheckBoxChanged: onCheckBoxChanged,
                order: order,
                selectedProducts: selectedProducts,
                initControllers: initControllers),
          ],
        ),
      ),
    );
  }
}
