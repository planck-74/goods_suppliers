import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:goods/business_logic/cubits/orders/orders_cubit.dart';
import 'package:goods/business_logic/cubits/orders/orders_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:goods/presentation/custom_widgets/date_picker.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with TickerProviderStateMixin {
  DateTime? startDate;
  DateTime? endDate;
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // context.read<OrdersCubit>().fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    String? trend,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkBlueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(OrdersState state) {
    if (state is! OrdersLoaded) return const SizedBox();

    final orders = state.orders;
    final ordersDone = state.ordersDone;
    final ordersCanceled = state.ordersCanceled;
    final ordersPreparing = state.ordersPreparing;
    final ordersRecent = state.ordersRecent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Performance Indicators
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            children: [
              _buildKPICard(
                title: 'إجمالي الطلبات',
                value: '${orders.length}',
                subtitle: 'جميع الفترات المختارة',
                color: Colors.blue,
                icon: Icons.receipt_long,
                trend: '+12%',
              ),
              _buildKPICard(
                title: 'الطلبات المكتملة',
                value: '${ordersDone.length}',
                subtitle: 'تم التوصيل بنجاح',
                color: Colors.green,
                icon: Icons.check_circle,
                trend: '+8%',
              ),
              _buildKPICard(
                title: 'قيد التحضير',
                value: '${ordersPreparing.length}',
                subtitle: 'جاري العمل عليها',
                color: Colors.orange,
                icon: Icons.hourglass_top,
              ),
              _buildKPICard(
                title: 'في انتظار التأكيد',
                value: '${ordersRecent.length}',
                subtitle: 'تحتاج مراجعة',
                color: Colors.purple,
                icon: Icons.pending_actions,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Orders Status Chart
          Container(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'توزيع حالات الطلبات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: ordersDone.length.toDouble(),
                          title: '${ordersDone.length}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.orange,
                          value: ordersPreparing.length.toDouble(),
                          title: '${ordersPreparing.length}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.purple,
                          value: ordersRecent.length.toDouble(),
                          title: '${ordersRecent.length}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: ordersCanceled.length.toDouble(),
                          title: '${ordersCanceled.length}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem('مكتملة', Colors.green),
                    _buildLegendItem('قيد التحضير', Colors.orange),
                    _buildLegendItem('في الانتظار', Colors.purple),
                    _buildLegendItem('ملغية', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTab(OrdersState state) {
    if (state is! OrdersLoaded) return const SizedBox();

    final ordersDoneTotal = state.ordersDoneTotal;
    final ordersCanceledTotal = state.ordersCanceledTotal;
    final ordersDone = state.ordersDone;
    final avgInvoiceValue =
        ordersDone.isNotEmpty ? ordersDoneTotal / ordersDone.length : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Financial KPIs
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            children: [
              _buildKPICard(
                title: 'إجمالي المبيعات',
                value: '${ordersDoneTotal.toStringAsFixed(0)} جـ',
                subtitle: 'المبيعات المحققة',
                color: Colors.green,
                icon: Icons.attach_money,
                trend: '+15%',
              ),
              _buildKPICard(
                title: 'متوسط قيمة الفاتورة',
                value: '${avgInvoiceValue.toStringAsFixed(0)} جـ',
                subtitle: 'متوسط كل طلب',
                color: Colors.blue,
                icon: Icons.receipt,
              ),
              _buildKPICard(
                title: 'المبيعات المهدرة',
                value: '${ordersCanceledTotal.toStringAsFixed(0)} جـ',
                subtitle: 'قيمة الطلبات الملغية',
                color: Colors.red,
                icon: Icons.money_off,
              ),
              _buildKPICard(
                title: 'معدل الفقدان',
                value:
                    '${((ordersCanceledTotal / (ordersDoneTotal + ordersCanceledTotal)) * 100).toStringAsFixed(1)}%',
                subtitle: 'نسبة المبيعات المفقودة',
                color: Colors.orange,
                icon: Icons.trending_down,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'مقارنة الإيرادات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (ordersDoneTotal + ordersCanceledTotal) * 1.2,
                      barTouchData: const BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('مبيعات محققة');
                                case 1:
                                  return const Text('مبيعات مهدرة');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(0)}K',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: ordersDoneTotal.toDouble(),
                              color: Colors.green,
                              width: 40,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: ordersCanceledTotal.toDouble(),
                              color: Colors.red,
                              width: 40,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(OrdersState state) {
    if (state is! OrdersLoaded) return const SizedBox();

    final avgDelivery = state.averageDeliveryHours;
    final clients = state.clients;
    final ordersDone = state.ordersDone;
    final ordersCanceled = state.ordersCanceled;
    final canceledPercent = ordersCanceled.length /
        (ordersDone.length + ordersCanceled.length) *
        100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Performance KPIs
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            children: [
              _buildKPICard(
                title: 'متوسط وقت التوصيل',
                value: '${avgDelivery.toStringAsFixed(1)} ساعة',
                subtitle: 'من الطلب للتسليم',
                color: Colors.blue,
                icon: Icons.timer,
              ),
              _buildKPICard(
                title: 'عدد العملاء',
                value: '${clients.length}',
                subtitle: 'عملاء نشطين',
                color: Colors.purple,
                icon: Icons.people,
                trend: '+5%',
              ),
              _buildKPICard(
                title: 'معدل النجاح',
                value: '${(100 - canceledPercent).toStringAsFixed(1)}%',
                subtitle: 'نسبة الطلبات المكتملة',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              _buildKPICard(
                title: 'معدل الإلغاء',
                value: '${canceledPercent.toStringAsFixed(1)}%',
                subtitle: 'نسبة الطلبات الملغية',
                color: Colors.red,
                icon: Icons.cancel,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Performance Chart
          // Use a fixed height instead of Expanded to avoid overflow and overlapping
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // يخلي الارتفاع حسب المحتوى

              children: [
                const Text(
                  'مؤشرات الأداء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const titles = [
                                'الأسبوع 1',
                                'الأسبوع 2',
                                'الأسبوع 3',
                                'الأسبوع 4'
                              ];
                              if (value.toInt() < titles.length) {
                                return Text(titles[value.toInt()]);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}%');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 85),
                            FlSpot(1, 88),
                            FlSpot(2, 82),
                            FlSpot(3, 92),
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 15),
                            FlSpot(1, 12),
                            FlSpot(2, 18),
                            FlSpot(3, 8),
                          ],
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('معدل النجاح', Colors.green),
                    const SizedBox(width: 20),
                    _buildLegendItem('معدل الإلغاء', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(
        context,
        const Text('تقاريرك', style: TextStyle(color: whiteColor)),
      ),
      body: Column(
        children: [
          // Date Picker Section
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
              color: whiteColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: DatePicker(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              context: context,
              onDateSelected: (DateTime start, DateTime end) {
                setState(() {
                  startDate = start;
                  endDate = end;
                });
                // context.read<OrdersCubit>().fetchOrdersByPeriod(start, end);
              },
            ),
          ),

          // Tabs Section
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: darkBlueColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: darkBlueColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard),
                  text: 'نظرة عامة',
                ),
                Tab(
                  icon: Icon(Icons.attach_money),
                  text: 'المالية',
                ),
                Tab(
                  icon: Icon(Icons.trending_up),
                  text: 'الأداء',
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                if (state is OrdersLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(state),
                    _buildFinancialTab(state),
                    _buildPerformanceTab(state),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
