import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectedView = "Monthly"; // Options: Monthly, Quarterly

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
                  // Follow-Up Chart (Pie Chart)
                  _buildSection(
                    title: "Follow-Up Chart",
                    child: Column(
                      children: [
                        _buildYearDropdownForFollowUp(cubit,state),
                        _buildFollowUpChart(cubit,state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress Chart (Bar Chart)
                  _buildSection(
                    title: "Progress Chart",
                    child: Column(
                      children: [
                        _buildYearDropdownForProgress(cubit,state),
                        _buildProgressChart(cubit,state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Comparison Chart (Line Chart)
                  _buildSection(
                    title: "Comparison Chart",
                    child: _buildComparisonChart(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Wraps each chart section inside a rounded corner container
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 2,
          )
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

  /// Follow-Up Chart (Pie Chart)
  Widget _buildFollowUpChart(CompanyCubit cubit,state) {
    final data = cubit.getFollowUpDataForYear(state.selectedYearForFollowUp);
    bool hasData = data["total"]! > 0;

    return Column(
      children: [
        // Show No Data Message if No Companies Exist for Selected Year
        if (!hasData)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "No data available for this year",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: data["sent"]!.toDouble(),
                    title: "${data["sent"]}",
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: data["notSent"]!.toDouble(),
                    title: "${data["notSent"]}",
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Email Sent & Not Sent Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green, "Email Sent: ${data["sent"]}"),
            const SizedBox(width: 20),
            _buildLegendItem(Colors.orange, "Email Not Sent: ${data["notSent"]}"),
          ],
        ),
      ],
    );
  }

  /// ✅ Helper Widget to Show Legends Below the Pie Chart
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

  /// Year Selection Dropdown for Follow-Up Chart
  Widget _buildYearDropdownForFollowUp(CompanyCubit cubit,state) {
    return DropdownButton<String>(
      value: state.selectedYearForFollowUp,
      items: cubit.getAvailableYears().map((year) {
        return DropdownMenuItem(value: year, child: Text(year));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          cubit.updateSelectedYearForFollowUp(value);
        }
      },
    );
  }

  /// Year Selection Dropdown for Progress Chart
  Widget _buildYearDropdownForProgress(CompanyCubit cubit,state) {
    return DropdownButton<String>(
      value: state.selectedYearForProgress,
      items: cubit.getAvailableYears().map((year) {
        return DropdownMenuItem(value: year, child: Text(year));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          cubit.updateSelectedYearForProgress(value);
        }
      },
    );
  }

  /// Progress Chart (Bar Chart)
  Widget _buildProgressChart(CompanyCubit cubit,state) {
    String selectedYearForProgress = state.selectedYearForProgress ?? DateFormat('yyyy').format(DateTime.now());

    final companies = cubit.state.companies.where((c) {
      return c.dateCreated.year.toString() == selectedYearForProgress;
    }).toList();

    List<int> data;
    List<String> labels;

    if (selectedView == "Monthly") {
      data = List.generate(12, (index) {
        return companies.where((c) => c.dateCreated.month == index + 1).length;
      });
      labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    } else {
      data = [
        companies.where((c) => c.dateCreated.month >= 1 && c.dateCreated.month <= 3).length,  // Q1
        companies.where((c) => c.dateCreated.month >= 4 && c.dateCreated.month <= 6).length,  // Q2
        companies.where((c) => c.dateCreated.month >= 7 && c.dateCreated.month <= 9).length,  // Q3
        companies.where((c) => c.dateCreated.month >= 10 && c.dateCreated.month <= 12).length, // Q4
      ];
      labels = ["Q1", "Q2", "Q3", "Q4"];
    }

    int maxValue = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 1;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              maxY: (maxValue + 5).toDouble(),
              barGroups: List.generate(data.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      y: data[index] > 0 ? data[index].toDouble() : 0.1,
                      colors: [data[index] > 0 ? Colors.blue : Colors.transparent],
                      width: 20,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    int index = value.toInt();
                    if (index >= 0 && index < labels.length) {
                      return labels[index];
                    }
                    return '';
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
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (index) {
                  return data[index] > 0
                      ? Column(
                    children: [
                      Text(
                        data[index].toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: (250 * (1 - (data[index] / maxValue)))
                            .clamp(5, 250),
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

  /// Comparison Chart Dropdowns
  Widget _buildComparisonDropdowns() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final cubit = context.read<CompanyCubit>();
        List<String> availablePeriods = cubit.getAvailablePeriods();

        if (availablePeriods.isEmpty) return Container();

        String selectedPeriod1 = state.selectedPeriod1 != null && availablePeriods.contains(state.selectedPeriod1)
            ? state.selectedPeriod1!
            : availablePeriods.first;

        String selectedPeriod2 = state.selectedPeriod2 != null && availablePeriods.contains(state.selectedPeriod2)
            ? state.selectedPeriod2!
            : availablePeriods.length > 1
            ? availablePeriods[1]
            : availablePeriods.first;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: selectedPeriod1,
              items: availablePeriods.map((p) {
                return DropdownMenuItem(value: p, child: Text(p));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  cubit.updateSelectedPeriod1(value);
                }
              },
            ),
            DropdownButton<String>(
              value: selectedPeriod2,
              items: availablePeriods.map((p) {
                return DropdownMenuItem(value: p, child: Text(p));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  cubit.updateSelectedPeriod2(value);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildComparisonChart() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final cubit = context.read<CompanyCubit>();
        List<String> availablePeriods = cubit.getAvailablePeriods();

        // If there are no periods, show an empty container.
        if (availablePeriods.isEmpty) return Container();

        // Default selection for periods (you can customize this)
        String selectedPeriod1 = state.selectedPeriod1 != null && availablePeriods.contains(state.selectedPeriod1)
            ? state.selectedPeriod1!
            : availablePeriods.first;

        String selectedPeriod2 = state.selectedPeriod2 != null && availablePeriods.contains(state.selectedPeriod2)
            ? state.selectedPeriod2!
            : availablePeriods.length > 1
            ? availablePeriods[1] // Default to second option if available
            : availablePeriods.first;

        // Fetch the comparison data for the selected periods
        Map<String, int> data = cubit.getComparisonData(selectedPeriod1, selectedPeriod2);

        return Column(
          children: [
            // Year/Period Selection for Comparison
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown for the first period
                DropdownButton<String>(
                  value: selectedPeriod1,
                  items: availablePeriods.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      cubit.updateSelectedPeriod1(value); // Update selectedPeriod1
                    }
                  },
                ),
                // Dropdown for the second period
                DropdownButton<String>(
                  value: selectedPeriod2,
                  items: availablePeriods.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      cubit.updateSelectedPeriod2(value); // Update selectedPeriod2
                    }
                  },
                ),
              ],
            ),

            // Chart rendering based on selected periods
            const SizedBox(height: 16), // Space between dropdown and chart
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(1, data["period1"]?.toDouble() ?? 0.0),
                        FlSpot(2, data["period2"]?.toDouble() ?? 0.0),
                      ],
                      isCurved: true,
                      barWidth: 4,
                      colors: [Colors.blue],
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        if (value == 1) return selectedPeriod1;
                        if (value == 2) return selectedPeriod2;
                        return '';
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) => value.toInt().toString(),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
