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
  String selectedYear = DateFormat('yyyy').format(DateTime.now());
  String selectedView = "Monthly"; // Options: Monthly, Quarterly
  String selectedPeriod1 = "Jan 2023";
  String selectedPeriod2 = "Jun 2023";

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompanyCubit>()..loadCompanies(),
      child: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          final cubit = context.read<CompanyCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text("Report")),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Follow-Up Chart (Pie Chart)
                  _buildSection(
                    title: "Follow-Up Chart",
                    child: _buildFollowUpChart(),
                  ),

                  const SizedBox(height: 16),

                  // Progress Chart (Bar Chart)
                  _buildSection(
                    title: "Progress Chart",
                    child: Column(
                      children: [
                        _buildDropdownSelection(),
                        _buildProgressChart(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comparison Chart (Line Chart)
                  _buildSection(
                    title: "Comparison Chart",
                    child: Column(
                      children: [
                        _buildComparisonDropdowns(),
                        _buildComparisonChart(),
                      ],
                    ),
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
  Widget _buildFollowUpChart() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final cubit = context.read<CompanyCubit>();

        // Get available years
        List<String> availableYears = cubit.getAvailableYears();

        // Ensure selected year is valid
        String? selectedYear = availableYears.contains(state.selectedYear)
            ? state.selectedYear
            : availableYears.first;

        // Fetch data for the selected year
        Map<String, int> data = cubit.getFollowUpDataForYear(selectedYear);
        bool hasData = data["total"]! > 0;

        return Column(
          children: [
            // Year Selection Dropdown
            DropdownButton<String>(
              value: selectedYear,
              items: availableYears.map((year) {
                return DropdownMenuItem(value: year, child: Text(year));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  cubit.updateSelectedYear(value);
                }
              },
            ),
            const SizedBox(height: 16),

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
              Column(
                children: [
                  // Pie Chart
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
                            titleStyle: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: data["notSent"]!.toDouble(),
                            title: "${data["notSent"]}",
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 14, color: Colors.white),
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
                      _buildLegendItem(
                          Colors.green, "Email Sent: ${data["sent"]}"),
                      const SizedBox(width: 20),
                      _buildLegendItem(
                          Colors.orange, "Email Not Sent: ${data["notSent"]}"),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
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

  /// Year & View Type Dropdown for Progress Chart
  Widget _buildDropdownSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: selectedYear,
          items: List.generate(
            10,
            (index) {
              String year = (DateTime.now().year - index).toString();
              return DropdownMenuItem(value: year, child: Text(year));
            },
          ),
          onChanged: (value) {
            setState(() {
              selectedYear = value!;
            });
          },
        ),
        DropdownButton<String>(
          value: selectedView,
          items: ["Monthly", "Quarterly"]
              .map((view) => DropdownMenuItem(value: view, child: Text(view)))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedView = value!;
            });
          },
        ),
      ],
    );
  }

  /// Progress Chart (Bar Chart)
  Widget _buildProgressChart() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final companies = state.companies.where((c) {
          return c.dateCreated.year.toString() == selectedYear;
        }).toList();

        List<int> data = List.generate(12, (index) {
          return companies.where((c) => c.dateCreated.month == index + 1).length;
        });

        List<String> labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

        // ✅ Get max value for proper scaling
        int maxValue = data.reduce((a, b) => a > b ? a : b);

        return SizedBox(
          height: 320, // ✅ Slightly increased height for better spacing
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
                          y: data[index] > 0 ? data[index].toDouble() : 0.1, // ✅ Keep space for empty bars
                          colors: [data[index] > 0 ? Colors.blue : Colors.transparent], // ✅ Hide bar if 0
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
              // ✅ Correct placement of count ABOVE the bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end, // ✅ Aligns counts properly
                    children: List.generate(data.length, (index) {
                      return data[index] > 0
                          ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(3,0,0,0),
                            child: Text(
                              data[index].toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left, // ✅ Align properly above the bar
                            ),
                          ),
                          SizedBox(height: (250 * (1 - (data[index] / maxValue))).clamp(5, 250)), // ✅ Correct spacing ABOVE the bar
                        ],
                      )
                          : const SizedBox(width: 20); // ✅ Maintain spacing for hidden values
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Comparison Chart Dropdowns
  Widget _buildComparisonDropdowns() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final cubit = context.read<CompanyCubit>();
        List<String> availablePeriods = cubit.getAvailablePeriods();

        if (availablePeriods.isEmpty) return Container(); // ✅ Prevents empty dropdown crash

        String selectedPeriod1 = state.selectedPeriod1 != null && availablePeriods.contains(state.selectedPeriod1)
            ? state.selectedPeriod1!
            : availablePeriods.first;

        String selectedPeriod2 = state.selectedPeriod2 != null && availablePeriods.contains(state.selectedPeriod2)
            ? state.selectedPeriod2!
            : availablePeriods.length > 1
            ? availablePeriods[1] // ✅ Selects second option if available
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

  /// Comparison Chart (Line Chart)
  Widget _buildComparisonChart() {
    return BlocBuilder<CompanyCubit, CompanyState>(
      builder: (context, state) {
        final cubit = context.read<CompanyCubit>();

        // Fetch data for the selected periods
        Map<String, int> data = cubit.getComparisonData(state.selectedPeriod1, state.selectedPeriod2);

        return SizedBox(
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
                    if (value == 1) return state.selectedPeriod1 ?? 'N/A';
                    if (value == 2) return state.selectedPeriod2 ?? 'N/A';
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
        );
      },
    );
  }
}
