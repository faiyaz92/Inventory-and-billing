import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class PerformanceDetailsPage extends StatefulWidget {
  final String entityType;
  final String entityId;

  const PerformanceDetailsPage({super.key, required this.entityType, required this.entityId});

  @override
  _PerformanceDetailsPageState createState() => _PerformanceDetailsPageState();
}

class _PerformanceDetailsPageState extends State<PerformanceDetailsPage> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 365)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<AdminOrderCubit>();
        cubit.fetchOrdersForEntity(widget.entityType, widget.entityId, dateRange.start, dateRange.end);
        return cubit;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: '${widget.entityType.capitalize()} Performance'),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AdminOrderCubit, AdminOrderState>(
              builder: (context, state) {
                if (state is AdminOrderListFetchLoading) {
                  return _buildShimmerEffect();
                } else if (state is AdminOrderListFetchSuccess) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEntityNameCard(context),
                          const SizedBox(height: 16),
                          _buildDateRangeCard(context),
                          const SizedBox(height: 16),
                          _buildStatsCard(state),
                          const SizedBox(height: 16),
                          _buildGraphCard(state),
                          const SizedBox(height: 16),
                          _buildOrderCountGraphCard(state),
                          const SizedBox(height: 16),
                          _buildOrdersCard(state),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Error loading data. Please try again.',
                      style: TextStyle(fontSize: 16, color: AppColors.red),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntityNameCard(BuildContext context) {
    return FutureBuilder<String>(
      future: context.read<AdminOrderCubit>().fetchEntityName(widget.entityType, widget.entityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.all(16.0),
                child: Container(height: 24, color: Colors.white),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${widget.entityType.capitalize()}: ${widget.entityId}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black12, offset: Offset(1, 1))],
                  ),
                ),
              ),
            ),
          );
        } else {
          final entityName = snapshot.data ?? widget.entityId;
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${widget.entityType.capitalize()}: $entityName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black12, offset: Offset(1, 1))],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDateRangeCard(BuildContext context) {
    final formatter = DateFormat('dd-MM-yyyy');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Date Range: ${formatter.format(dateRange.start)} - ${formatter.format(dateRange.end)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: dateRange,
              builder: (context, child) => Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() => dateRange = picked);
              context.read<AdminOrderCubit>().fetchOrdersForEntity(widget.entityType, widget.entityId, picked.start, picked.end);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard(AdminOrderListFetchSuccess state) {
    final totalOrders = state.orders.length;
    final totalAmount = state.orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final isCustomer = widget.entityType == 'customer';
    final lastOrderText = isCustomer && state.orders.isNotEmpty ? _daysSinceLastOrder(state.orders.first) : null;

    final stats = [
      {
        'label': 'Total Orders',
        'value': totalOrders.toString(),
        'color': AppColors.textPrimary,
        'highlight': AppColors.blue.withOpacity(0.3),
      },
      {
        'label': 'Total Amount',
        'value': '₹${totalAmount.toStringAsFixed(2)}',
        'color': AppColors.textPrimary,
        'highlight': AppColors.green.withOpacity(0.3),
      },
      if (lastOrderText != null)
        {
          'label': 'Last Order',
          'value': lastOrderText,
          'color': AppColors.textSecondary,
          'highlight': AppColors.primary.withOpacity(0.3),
        },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                shadows: [Shadow(blurRadius: 2, color: Colors.black12, offset: Offset(1, 1))],
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                color: AppColors.textSecondary.withOpacity(0.5),
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: stats.asMap().entries.map((entry) {
                final stat = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: stat['highlight'] as Color,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      child: Text(
                        stat['label'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        child: Text(
                          stat['value'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            color: stat['color'] as Color,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard(AdminOrderListFetchSuccess state) {
    final data = _generateGraphData(state.orders, dateRange);
    if (data.spots.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16.0),
          child: const Center(child: Text('No data available for this period')),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Amount Trend',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  data.trend == Trend.up ? '↑ Up' : data.trend == Trend.down ? '↓ Down' : '↔ Neutral',
                  style: TextStyle(
                    fontSize: 14,
                    color: data.trend == Trend.up ? Colors.green : data.trend == Trend.down ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (data.spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) / 5).ceilToDouble(),
                    verticalInterval: data.spots.length / 5,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.dates.length) {
                            final date = data.dates[index];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  data.interval == 'daily'
                                      ? '${date.day}/${date.month}'
                                      : data.interval == 'weekly'
                                      ? 'W${(date.day / 7).ceil()}'
                                      : '${date.month}/${date.year % 100}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.spots,
                      isCurved: true,
                      color: data.trend == Trend.up ? Colors.green : Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4,
                          color: data.trend == Trend.up ? Colors.green : Colors.red,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (data.trend == Trend.up ? Colors.green : Colors.red).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < data.dates.length) {
                          final date = data.dates[index];
                          final dateText = data.interval == 'daily'
                              ? '${date.day}/${date.month}/${date.year}'
                              : data.interval == 'weekly'
                              ? 'Week of ${date.day}/${date.month}/${date.year}'
                              : '${date.month}/${date.year}';
                          return LineTooltipItem(
                            '₹${spot.y.toStringAsFixed(2)}\n$dateText',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }
                        return null;
                      }).toList(),
                    ),
                  ),
                  minY: 0,
                  maxY: (data.spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCountGraphCard(AdminOrderListFetchSuccess state) {
    final data = _generateOrderCountGraphData(state.orders, dateRange);
    if (data.spots.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16.0),
          child: const Center(child: Text('No order count data available for this period')),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Count Trend',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  data.trend == Trend.up ? '↑ Up' : data.trend == Trend.down ? '↓ Down' : '↔ Neutral',
                  style: TextStyle(
                    fontSize: 14,
                    color: data.trend == Trend.up ? Colors.green : data.trend == Trend.down ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (data.spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) / 5).ceilToDouble(),
                    verticalInterval: data.spots.length / 5,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.dates.length) {
                            final date = data.dates[index];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  data.interval == 'daily'
                                      ? '${date.day}/${date.month}'
                                      : data.interval == 'weekly'
                                      ? 'W${(date.day / 7).ceil()}'
                                      : '${date.month}/${date.year % 100}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.spots,
                      isCurved: true,
                      color: data.trend == Trend.up ? Colors.green : Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 4,
                          color: data.trend == Trend.up ? Colors.green : Colors.red,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (data.trend == Trend.up ? Colors.green : Colors.red).withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < data.dates.length) {
                          final date = data.dates[index];
                          final dateText = data.interval == 'daily'
                              ? '${date.day}/${date.month}/${date.year}'
                              : data.interval == 'weekly'
                              ? 'Week of ${date.day}/${date.month}/${date.year}'
                              : '${date.month}/${date.year}';
                          return LineTooltipItem(
                            '${spot.y.toInt()} orders\n$dateText',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }
                        return null;
                      }).toList(),
                    ),
                  ),
                  minY: 0,
                  maxY: (data.spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersCard(AdminOrderListFetchSuccess state) {
    final groupedOrders = <String, List<Order>>{};
    final formatter = DateFormat('MMM dd, yyyy');
    for (var order in state.orders) {
      final dateKey = formatter.format(order.orderDate);
      groupedOrders[dateKey] = groupedOrders[dateKey] ?? [];
      groupedOrders[dateKey]!.add(order);
    }

    final dates = groupedOrders.keys.toList()..sort((a, b) => formatter.parse(b).compareTo(formatter.parse(a)));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        child: ExpansionTile(
          title: const Text(
            'View Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final orders = groupedOrders[date]!;
                return StickyHeader(
                  header: Container(
                    width: double.infinity,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      date,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  content: Column(
                    children: orders.map((order) => _buildOrderCard(context, order, state)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, AdminOrderListFetchSuccess state) {
    final statusStyles = context.read<AdminOrderCubit>().getStatusColors(order.status);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () => sl<Coordinator>().navigateToAdminOrderDetailsPage(order.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt, color: AppColors.primary, size: 36),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Customer: ${order.userName}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.read<AdminOrderCubit>().formatOrderDate(order.orderDate),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textSecondary.withOpacity(0.5), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Table(
                    border: TableBorder(
                      verticalInside: BorderSide(color: AppColors.textSecondary.withOpacity(0.5), width: 1),
                      horizontalInside: BorderSide(color: AppColors.textSecondary.withOpacity(0.5), width: 1),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildTableRow(
                        'Products',
                        context.read<AdminOrderCubit>().getProductNames(order.items),
                        maxLines: 2,
                      ),
                      _buildTableRow(
                        'Status',
                        order.status,
                        valueColor: statusStyles['color'],
                        backgroundColor: statusStyles['backgroundColor'],
                        valueWeight: order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'processing'
                            ? FontWeight.bold
                            : null,
                      ),
                      _buildTableRow(
                        'Total',
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: AppColors.textPrimary,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
      String label,
      String value, {
        bool isBold = false,
        FontWeight? valueWeight,
        Color? valueColor = AppColors.textSecondary,
        Color? backgroundColor,
        BorderRadius? borderRadius,
        int maxLines = 1,
      }) {
    return TableRow(
      decoration: backgroundColor != null || borderRadius != null
          ? BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      )
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: valueWeight ?? (isBold ? FontWeight.bold : FontWeight.normal),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  GraphData _generateGraphData(List<Order> orders, DateTimeRange range) {
    final duration = range.end.difference(range.start).inDays;
    final interval = duration <= 7 ? 'daily' : (duration <= 90 ? 'weekly' : 'monthly');
    final Map<DateTime, double> aggregated = {};

    for (var order in orders) {
      final date = interval == 'daily'
          ? DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day)
          : interval == 'weekly'
          ? DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day - order.orderDate.weekday + 1)
          : DateTime(order.orderDate.year, order.orderDate.month);
      aggregated[date] = (aggregated[date] ?? 0) + order.totalAmount;
    }

    final sortedDates = aggregated.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final amount = aggregated[date]!;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    final trend = spots.isEmpty || spots.length == 1
        ? Trend.neutral
        : spots.last.y > spots.first.y
        ? Trend.up
        : Trend.down;

    return GraphData(spots: spots, interval: interval, trend: trend, dates: sortedDates);
  }

  GraphData _generateOrderCountGraphData(List<Order> orders, DateTimeRange range) {
    final duration = range.end.difference(range.start).inDays;
    final interval = duration <= 7 ? 'daily' : (duration <= 90 ? 'weekly' : 'monthly');
    final Map<DateTime, int> aggregated = {};

    for (var order in orders) {
      final date = interval == 'daily'
          ? DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day)
          : interval == 'weekly'
          ? DateTime(order.orderDate.year, order.orderDate.month, order.orderDate.day - order.orderDate.weekday + 1)
          : DateTime(order.orderDate.year, order.orderDate.month);
      aggregated[date] = (aggregated[date] ?? 0) + 1;
    }

    final sortedDates = aggregated.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final count = aggregated[date]!.toDouble();
      spots.add(FlSpot(i.toDouble(), count));
    }

    final trend = spots.isEmpty || spots.length == 1
        ? Trend.neutral
        : spots.last.y > spots.first.y
        ? Trend.up
        : Trend.down;

    return GraphData(spots: spots, interval: interval, trend: trend, dates: sortedDates);
  }

  String _daysSinceLastOrder(Order order) {
    final diff = DateTime.now().difference(order.orderDate);
    return '${diff.inDays} days ago';
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(height: 80, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 80, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 80, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 80, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 80, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class GraphData {
  final List<FlSpot> spots;
  final String interval;
  final Trend trend;
  final List<DateTime> dates;

  GraphData({required this.spots, required this.interval, required this.trend, required this.dates});
}

enum Trend { up, down, neutral }

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}