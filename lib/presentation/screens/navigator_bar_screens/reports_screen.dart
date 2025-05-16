import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/order_model.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/custom_widgets/date_picker.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Initially fetch all orders (or you can set a default period)
    context.read<OrdersCubit>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(
          context, const Text('تقاريرك', style: TextStyle(color: whiteColor))),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                color: whiteColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18))),
            // Pass the callback to get the selected period
            child: DatePicker(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              context: context,
              onDateSelected: (DateTime start, DateTime end) {
                setState(() {
                  startDate = start;
                  endDate = end;
                });
                // Fetch orders for the selected period
                context.read<OrdersCubit>().fetchOrdersByPeriod(start, end);
              },
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              if (state is OrdersLoaded) {
                List orders = state.orders;
                List<OrderModel> ordersDone = state.ordersDone;
                List ordersCanceled = state.ordersCanceled;
                int ordersDoneTotal = state.ordersDoneTotal;
                int ordersCanceledTotal = state.ordersCanceledTotal;
                double avgDelivery = state.averageDeliveryHours;

                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12))),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.brown,
                            image: 'assets/icons/invoice.png',
                            title: 'عدد الفواتير المستلمة',
                            value: '${orders.length}',
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.green,
                            title: 'عدد الفواتير المحققة',
                            value: '${ordersDone.length}',
                            child: Image.asset(
                              'assets/icons/done_invoice.png',
                              height: 55,
                            ),
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.red,
                            title: 'نسبة الفواتير المرفوضة',
                            value:
                                '${(ordersCanceled.length / (ordersDone.length + ordersCanceled.length) * 100).toStringAsFixed(2)} %',
                            child: Image.asset(
                              'assets/icons/canceled_invoice.png',
                              height: 55,
                            ),
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.blue,
                            image: 'assets/icons/clients.png',
                            title: 'عدد العملاء',
                            value: ' ${state.clients.length}',
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.green,
                            image: 'assets/icons/cash.png',
                            title: 'متوسط قيمة الفاتورة',
                            value:
                                '${(ordersDoneTotal / ordersDone.length)} جـ',
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.brown,
                            title: 'إجمالي المبيعات المحققة',
                            value: '$ordersDoneTotal جـ',
                            child: Image.asset(
                              'assets/icons/done.png',
                              height: 55,
                            ),
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: Colors.brown,
                            title: 'قيمة المبيعات المهدرة',
                            value: '$ordersCanceledTotal جـ',
                            child: Image.asset(
                              'assets/icons/canceled.png',
                              height: 55,
                            ),
                          ),
                          ReportsContainer(
                            screenWidth: screenWidth,
                            color: const Color.fromARGB(255, 235, 212, 11),
                            image: 'assets/icons/delivery_truck.png',
                            title: 'متوسط مدة التوصيل',
                            value: '${avgDelivery.toStringAsFixed(0)} ساعة',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (state is OrdersLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const SizedBox();
            },
          )
        ],
      ),
    );
  }
}

class ReportsContainer extends StatelessWidget {
  const ReportsContainer({
    super.key,
    required this.screenWidth,
    required this.color,
    this.image,
    required this.title,
    this.child,
    required this.value,
  });

  final double screenWidth;
  final Color color;
  final String? image;
  final String title;
  final String value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
        width: screenWidth,
        decoration: BoxDecoration(
            color: whiteColor,
            border: Border.all(color: color, width: .8),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: child ??
                  ImageIcon(color: color, size: 60, AssetImage(image ?? '')),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: darkBlueColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: darkBlueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
