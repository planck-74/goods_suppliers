import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:goods/business_logic/cubits/reports/reports_cubit.dart';
import 'package:goods/business_logic/cubits/reports/reports_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar copy.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load all orders initially
    context.read<ReportsCubit>().fetchAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    String? trend,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                      color: trend.startsWith('+')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        color:
                            trend.startsWith('+') ? Colors.green : Colors.red,
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
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ReportsState state) {
    if (state is! ReportsLoaded) return const SizedBox();

    return RefreshIndicator(
      onRefresh: () => context.read<ReportsCubit>().refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Wrap(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  child: _buildKPICard(
                    title: 'إجمالي الطلبات',
                    value: '${state.totalOrders}',
                    subtitle: _buildPeriodSubtitle(state),
                    color: Colors.blue,
                    icon: Icons.receipt_long,
                    trend: state.totalOrders > 50 ? '+12%' : null,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  child: _buildKPICard(
                    title: 'الطلبات المكتملة',
                    value: '${state.completedOrders}',
                    subtitle: 'تم التوصيل بنجاح',
                    color: Colors.green,
                    icon: Icons.check_circle,
                    trend: state.successRate > 80 ? '+8%' : null,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  child: _buildKPICard(
                    title: 'قيد التحضير',
                    value: '${state.ordersPreparing.length}',
                    subtitle: 'جاري العمل عليها',
                    color: Colors.orange,
                    icon: Icons.hourglass_top,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  child: _buildKPICard(
                    title: 'في انتظار التأكيد',
                    value: '${state.ordersRecent.length}',
                    subtitle: 'تحتاج مراجعة',
                    color: Colors.purple,
                    icon: Icons.pending_actions,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pie Chart Container
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
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
                    child: _buildOrdersPieChart(state),
                  ),
                  const SizedBox(height: 16),
                  _buildPieChartLegend(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialTab(ReportsState state) {
    if (state is! ReportsLoaded) return const SizedBox();

    return RefreshIndicator(
      onRefresh: () => context.read<ReportsCubit>().refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'إجمالي المبيعات',
                    value: '${state.ordersDoneTotal.toStringAsFixed(0)} جـ',
                    subtitle: 'المبيعات المحققة',
                    color: Colors.green,
                    icon: Icons.attach_money,
                    trend: state.ordersDoneTotal > 10000 ? '+15%' : null,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'المبيعات المهدرة',
                    value: '${state.ordersCanceledTotal.toStringAsFixed(0)} جـ',
                    subtitle: 'قيمة الطلبات الملغية',
                    color: Colors.red,
                    icon: Icons.money_off,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'متوسط قيمة الفاتورة',
                    value: '${state.averageOrderValue.toStringAsFixed(0)} جـ',
                    subtitle: 'متوسط كل طلب',
                    color: Colors.blue,
                    icon: Icons.receipt,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'معدل الفقدان',
                    value: '${state.lossRate.toStringAsFixed(1)}%',
                    subtitle: 'نسبة المبيعات المفقودة',
                    color: Colors.orange,
                    icon: Icons.trending_down,
                  ),
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
                    child: _buildRevenueBarChart(state),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab(ReportsState state) {
    if (state is! ReportsLoaded) return const SizedBox();

    return RefreshIndicator(
      onRefresh: () => context.read<ReportsCubit>().refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Performance KPIs Grid
            Wrap(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'متوسط وقت التوصيل',
                    value:
                        '${state.averageDeliveryHours.toStringAsFixed(1)} ساعة',
                    subtitle: 'من الطلب للتسليم',
                    color: Colors.blue,
                    icon: Icons.timer,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'عدد العملاء',
                    value: '${state.totalClients}',
                    subtitle: '\إعاد نشطين',
                    color: Colors.purple,
                    icon: Icons.people,
                    trend: state.totalClients > 20 ? '+5%' : null,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'معدل النجاح',
                    value: '${state.successRate.toStringAsFixed(1)}%',
                    subtitle: 'نسبة الطلبات المكتملة',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: _buildKPICard(
                    title: 'معدل الإلغاء',
                    value: '${state.canceledOrdersPercent.toStringAsFixed(1)}%',
                    subtitle: 'نسبة الطلبات الملغية',
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Performance Chart
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
                mainAxisSize: MainAxisSize.min,
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
                    child: _buildPerformanceLineChart(state),
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
      ),
    );
  }

  Widget _buildOrdersPieChart(ReportsLoaded state) {
    final sections = <PieChartSectionData>[];

    if (state.completedOrders > 0) {
      sections.add(PieChartSectionData(
        color: Colors.green,
        value: state.completedOrders.toDouble(),
        title: '${state.completedOrders}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    if (state.ordersPreparing.isNotEmpty) {
      sections.add(PieChartSectionData(
        color: Colors.orange,
        value: state.ordersPreparing.length.toDouble(),
        title: '${state.ordersPreparing.length}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    if (state.ordersRecent.isNotEmpty) {
      sections.add(PieChartSectionData(
        color: Colors.purple,
        value: state.ordersRecent.length.toDouble(),
        title: '${state.ordersRecent.length}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    if (state.ordersCanceled.isNotEmpty) {
      sections.add(PieChartSectionData(
        color: Colors.red,
        value: state.ordersCanceled.length.toDouble(),
        title: '${state.ordersCanceled.length}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: sections,
      ),
    );
  }

  Widget _buildPieChartLegend(ReportsLoaded state) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        if (state.completedOrders > 0) _buildLegendItem('مكتملة', Colors.green),
        if (state.ordersPreparing.isNotEmpty)
          _buildLegendItem('قيد التحضير', Colors.orange),
        if (state.ordersRecent.isNotEmpty)
          _buildLegendItem('في الانتظار', Colors.purple),
        if (state.ordersCanceled.isNotEmpty)
          _buildLegendItem('ملغية', Colors.red),
      ],
    );
  }

  Widget _buildRevenueBarChart(ReportsLoaded state) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (state.ordersDoneTotal + state.ordersCanceledTotal) * 1.2,
        barTouchData: BarTouchData(enabled: true),
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
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: state.ordersDoneTotal,
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
                toY: state.ordersCanceledTotal,
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
    );
  }

  Widget _buildPerformanceLineChart(ReportsLoaded state) {
    return LineChart(
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
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, state.successRate),
              FlSpot(1, state.successRate + 3),
              FlSpot(2, state.successRate - 3),
              FlSpot(3, state.successRate + 2),
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, state.canceledOrdersPercent),
              FlSpot(1, state.canceledOrdersPercent - 2),
              FlSpot(2, state.canceledOrdersPercent + 4),
              FlSpot(3, state.canceledOrdersPercent - 1),
            ],
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: const FlDotData(show: true),
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

  String _buildPeriodSubtitle(ReportsLoaded state) {
    if (state.startDate != null && state.endDate != null) {
      return 'من ${state.startDate!.day}/${state.startDate!.month}\n إلى ${state.endDate!.day}/${state.endDate!.month}';
    }
    return 'جميع الفترات';
  }

  Widget _buildEmptyState(ReportsEmpty state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorState(ReportsError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<ReportsCubit>().refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
                context.read<ReportsCubit>().fetchOrdersByPeriod(start, end);
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
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري تحليل البيانات...'),
                      ],
                    ),
                  );
                }

                if (state is ReportsError) {
                  return _buildErrorState(state);
                }

                if (state is ReportsEmpty) {
                  return _buildEmptyState(state);
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
