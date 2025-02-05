import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/utils/AppColor.dart';
import 'package:requirment_gathering_app/utils/AppKeys.dart';
import 'package:requirment_gathering_app/utils/AppLabels.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompanyCubit>()..loadCompanies(),
      child: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          final cubit = context.read<CompanyCubit>();

          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSection(
                    title: AppLabels.followUpChartTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDropdown(
                          context,
                          cubit,
                          state.selectedYearForFollowUp,
                          cubit.getAvailableYears(),
                          cubit.updateSelectedYearForFollowUp,
                        ),
                        _buildFollowUpChart(cubit, state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: AppLabels.progressChartTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDropdown(
                          context,
                          cubit,
                          state.selectedYearForProgress,
                          cubit.getAvailableYears(),
                          cubit.updateSelectedYearForProgress,
                        ),
                        _buildProgressChart(cubit, state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: AppLabels.comparisonChartTitle,
                    child: _buildComparisonChart(cubit, state, context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Reusable section wrapper
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowGrey,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// Dropdown for selecting a year
  Widget _buildDropdown(
    BuildContext context,
    CompanyCubit cubit,
    String? selectedValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    // Remove duplicates using Set
    final uniqueOptions =
        options.toSet().toList(); // This will remove duplicates
    if (!uniqueOptions.contains(selectedValue)) {
      selectedValue = null;
    }
    return DropdownButton<String>(
      value: selectedValue,
      items: uniqueOptions.map((year) {
        return DropdownMenuItem(value: year, child: Text(year));
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  /// Follow-Up Chart (Pie Chart)
  Widget _buildFollowUpChart(CompanyCubit cubit, CompanyState state) {
    final data = cubit.getFollowUpDataForYear(state.selectedYearForFollowUp);
    bool hasData = data[AppKeys.totalKey]! > 0;

    return Column(
      children: [
        hasData
            ? SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: AppColors.green,
                        value: data[AppKeys.sentKey]!.toDouble(),
                        title: "${data[AppKeys.sentKey]}",
                        radius: 60,
                        titleStyle:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: AppColors.orange,
                        value: data[AppKeys.notSentKey]!.toDouble(),
                        title: "${data[AppKeys.notSentKey]}",
                        radius: 60,
                        titleStyle:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              )
            : _buildNoDataMessage(),

        // ✅ Email Sent & Email Not Sent Count Below Pie Chart (Wapas Add Kiya)
        if (hasData)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.green,
                    "${AppLabels.emailSentLabel}: ${data[AppKeys.sentKey]}"),
                const SizedBox(width: 20),
                _buildLegendItem(AppColors.orange,
                    "${AppLabels.emailNotSentLabel}: ${data[AppKeys.notSentKey]}"),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Progress Chart (Bar Chart)
  Widget _buildProgressChart(CompanyCubit cubit, CompanyState state) {
    final progressData = cubit.getProgressData(state.selectedYearForProgress);

    int maxValue = progressData.maxValue > 0 ? progressData.maxValue : 1;
    double chartHeight = 250; // Reduced height

    return SizedBox(
      height: chartHeight,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              maxY: (maxValue + 5).toDouble(),
              barGroups: progressData.bars,
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    int index = value.toInt();
                    return (index >= 0 && index < progressData.labels.length)
                        ? progressData.labels[index]
                        : '';
                  },
                  margin: 10,
                  reservedSize: 22,
                ),
                leftTitles: SideTitles(showTitles: false),
                topTitles: SideTitles(showTitles: false),
                rightTitles: SideTitles(showTitles: false),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),

          /// Adjusted the bar heights relatively
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(progressData.bars.length, (index) {
                  double barValue = progressData.bars[index].barRods[0].y;
                  return barValue > 0
                      ? Column(
                          children: [
                            Text(
                              barValue.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                              height: (chartHeight *
                                      (1 - (barValue / maxValue)))
                                  .clamp(5, chartHeight), // Relative adjustment
                            ),
                          ],
                        )
                      : const SizedBox(width: 20);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Comparison Chart (Line Chart)
  Widget _buildComparisonChart(
      CompanyCubit cubit, CompanyState state, context) {
    final comparisonData =
        cubit.getComparisonData(state.selectedPeriod1, state.selectedPeriod2);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDropdown(
              context,
              cubit,
              state.selectedPeriod1,
              cubit.getAvailablePeriods(),
              cubit.updateSelectedPeriod1,
            ),
            _buildDropdown(
              context,
              cubit,
              state.selectedPeriod2,
              cubit.getAvailablePeriods(),
              cubit.updateSelectedPeriod2,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(1,
                        comparisonData[AppKeys.period1Key]?.toDouble() ?? 0.0),
                    FlSpot(2,
                        comparisonData[AppKeys.period2Key]?.toDouble() ?? 0.0),
                  ],
                  isCurved: true,
                  barWidth: 4,
                  colors: [AppColors.blue],
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: _buildComparisonChartTitles(
                  state.selectedPeriod1, state.selectedPeriod2),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _buildComparisonChartTitles(String? period1, String? period2) {
    return FlTitlesData(
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (value) {
          if (value == 1) return period1 ?? '';
          if (value == 2) return period2 ?? '';
          return '';
        },
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTitles: (value) => value.toInt().toString(),
      ),
    );
  }

  /// No data message
  Widget _buildNoDataMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          AppLabels.noDataMessage,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
