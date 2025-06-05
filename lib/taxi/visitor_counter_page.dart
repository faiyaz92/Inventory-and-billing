import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/visitor_counter_cubit.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';

@RoutePage()
class VisitorCounterPage extends StatefulWidget {
  const VisitorCounterPage({super.key});

  @override
  _VisitorCounterPageState createState() => _VisitorCounterPageState();
}

class _VisitorCounterPageState extends State<VisitorCounterPage> {
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  String? _selectedFilter = 'week';
  final _visitorCounterCubit = sl<VisitorCounterCubit>();

  void _applyQuickFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();
      switch (filter) {
        case 'year':
          dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 365)),
            end: now,
          );
          break;
        case 'week':
          dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          );
          break;
        case 'month':
          dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          );
          break;
        case '3months':
          dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 90)),
            end: now,
          );
          break;
        case '6months':
          dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 180)),
            end: now,
          );
          break;
      }
    });
    _visitorCounterCubit.fetchVisitorCounts(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  }

  Widget _buildQuickFilterChips() {
    final filters = [
      {'label': 'Last 1 Year', 'value': 'year'},
      {'label': 'Week', 'value': 'week'},
      {'label': 'Month', 'value': 'month'},
      {'label': 'Last 3 Months', 'value': '3months'},
      {'label': 'Last 6 Months', 'value': '6months'},
    ];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.start,
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['value'];
            return ChoiceChip(
              label: Text(
                filter['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  _applyQuickFilter(filter['value'] as String);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateRangeCard(BuildContext context) {
    final formatter = DateFormat('dd-MM-yyyy');
    final totalDays = dateRange.end.difference(dateRange.start).inDays + 1;
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Total $totalDays days',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
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
                  colorScheme:
                  const ColorScheme.light(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                dateRange = picked;
                _selectedFilter = null;
              });
              _visitorCounterCubit.fetchVisitorCounts(
                startDate: picked.start,
                endDate: picked.end,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        _visitorCounterCubit.fetchVisitorCounts(
            startDate: dateRange.start, endDate: dateRange.end);
        return _visitorCounterCubit;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Visitor Counter'),
        body: Container(
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
            child: BlocBuilder<VisitorCounterCubit, VisitorCounterState>(
              builder: (context, state) {
                if (state is VisitorCounterLoading) {
                  return const Center(child: CustomLoadingDialog());
                } else if (state is VisitorCounterSuccess) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDateRangeCard(context),
                          const SizedBox(height: 16),
                          _buildQuickFilterChips(),
                          const SizedBox(height: 16),
                          _buildStatsCard(state),
                          const SizedBox(height: 16),
                          _buildVisitorCountGraphCard(state),
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

  Widget _buildStatsCard(VisitorCounterSuccess state) {
    final totalVisitors = state.visitorCounts.values
        .where((counter) => counter.page == 'TaxiBookingPage')
        .fold<int>(0, (sum, counter) => sum + counter.count);

    final stats = [
      {
        'label': 'Total Visitors',
        'value': totalVisitors.toString(),
        'color': AppColors.textPrimary,
        'highlight': AppColors.blue.withOpacity(0.3),
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
              'Visitor Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                shadows: [
                  Shadow(
                      blurRadius: 2,
                      color: Colors.black12,
                      offset: Offset(1, 1))
                ],
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
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

  Widget _buildVisitorCountGraphCard(VisitorCounterSuccess state) {
    final data = _generateVisitorCountGraphData(state.visitorCounts, dateRange);
    if (data.spots.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16.0),
          child: const Center(
              child: Text('No visitor count data available for this period')),
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
                  'Visitor Count Trend',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                Text(
                  data.trend == Trend.up
                      ? '↑ Up'
                      : data.trend == Trend.down
                      ? '↓ Down'
                      : '↔ Neutral',
                  style: TextStyle(
                    fontSize: 14,
                    color: data.trend == Trend.up
                        ? Colors.green
                        : data.trend == Trend.down
                        ? Colors.red
                        : Colors.grey,
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
                    horizontalInterval: (data.spots
                        .map((e) => e.y)
                        .reduce((a, b) => a > b ? a : b) /
                        5)
                        .ceilToDouble(),
                    verticalInterval: data.spots.length / 5,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
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
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.spots,
                      isCurved: true,
                      color: data.trend == Trend.up ? Colors.green : Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: data.trend == Trend.up
                                  ? Colors.green
                                  : Colors.red,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                        (data.trend == Trend.up ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) =>
                          touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index >= 0 && index < data.dates.length) {
                              final date = data.dates[index];
                              final dateText = data.interval == 'daily'
                                  ? '${date.day}/${date.month}/${date.year}'
                                  : data.interval == 'weekly'
                                  ? 'Week of ${date.day}/${date.month}/${date.year}'
                                  : '${date.month}/${date.year}';
                              return LineTooltipItem(
                                '${spot.y.toInt()} visitors\n$dateText',
                                const TextStyle(color: Colors.white, fontSize: 12),
                              );
                            }
                            return null;
                          }).toList(),
                    ),
                  ),
                  minY: 0,
                  maxY: (data.spots
                      .map((e) => e.y)
                      .reduce((a, b) => a > b ? a : b) *
                      1.1)
                      .ceilToDouble(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
                width: double.maxFinite, height: 2, color: AppColors.grey),
            const SizedBox(height: 8),
            _buildAverageVisitorCountCard(state),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageVisitorCountCard(VisitorCounterSuccess state) {
    final averages = _calculateAverageVisitorCount(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Average Visitor Count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(blurRadius: 2, color: Colors.black12, offset: Offset(1, 1))
            ],
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
          children: averages.entries.map((entry) {
            return TableRow(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
              ),
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Text(
                    '${entry.key.capitalize()} Avg Visitors',
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    child: Text(
                      entry.value.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
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
    );
  }

  Map<String, double> _calculateAverageVisitorCount(VisitorCounterSuccess state) {
    final visitorCounts = state.visitorCounts;
    final durationDays = dateRange.end.difference(dateRange.start).inDays + 1;
    if (visitorCounts.isEmpty || durationDays <= 0) {
      return {'daily': 0.0, 'weekly': 0.0, 'monthly': 0.0};
    }

    final totalVisitors = visitorCounts.values
        .where((counter) => counter.page == 'TaxiBookingPage')
        .fold<int>(0, (sum, counter) => sum + counter.count);

    final dailyAvg = durationDays > 0 ? totalVisitors / durationDays : 0.0;
    final weeklyAvg = dailyAvg * 7;
    final monthlyAvg = dailyAvg * 30;

    return {
      'daily': dailyAvg,
      'weekly': weeklyAvg,
      'monthly': monthlyAvg,
    };
  }

  GraphData _generateVisitorCountGraphData(
      Map<DateTime, VisitorCounter> visitors, DateTimeRange range) {
    final duration = range.end.difference(range.start).inDays;
    final interval =
    duration <= 7 ? 'daily' : (duration <= 90 ? 'weekly' : 'monthly');
    final Map<DateTime, int> aggregated = {};

    for (var entry in visitors.entries) {
      if (entry.value.page != 'TaxiBookingPage') continue;
      final date = interval == 'daily'
          ? DateTime(entry.key.year, entry.key.month, entry.key.day)
          : interval == 'weekly'
          ? DateTime(entry.key.year, entry.key.month,
          entry.key.day - entry.key.weekday + 1)
          : DateTime(entry.key.year, entry.key.month);
      aggregated[date] = (aggregated[date] ?? 0) + entry.value.count;
    }

    final sortedDates = aggregated.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final visitorCount = aggregated[date]!.toDouble();
      spots.add(FlSpot(i.toDouble(), visitorCount));
    }

    final trend = spots.isEmpty || spots.length == 1
        ? Trend.neutral
        : spots.last.y > spots.first.y
        ? Trend.up
        : Trend.down;

    return GraphData(
        spots: spots, interval: interval, trend: trend, dates: sortedDates);
  }
}

class GraphData {
  final List<FlSpot> spots;
  final String interval;
  final Trend trend;
  final List<DateTime> dates;

  GraphData({
    required this.spots,
    required this.interval,
    required this.trend,
    required this.dates,
  });
}

enum Trend { up, down, neutral }

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}