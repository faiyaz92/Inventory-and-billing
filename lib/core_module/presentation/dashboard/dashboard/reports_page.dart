// import 'package:auto_route/annotations.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
// import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
// import 'package:requirment_gathering_app/core_module/utils/AppKeys.dart';
// import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
// import 'package:requirment_gathering_app/user_module/data/partner.dart';
// import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_state.dart';
// import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';
//
// @RoutePage()
// class ReportPage extends StatefulWidget {
//   const ReportPage({Key? key}) : super(key: key);
//
//   @override
//   _ReportPageState createState() => _ReportPageState();
// }
//
// class _ReportPageState extends State<ReportPage> {
//   String? selectedYearForFollowUp;
//   String? selectedYearForProgress;
//   String? selectedPeriod1;
//   String? selectedPeriod2;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => sl<PartnerCubit>()..loadCompanies(),
//       child: BlocBuilder<PartnerCubit, CompanyState>(
//         builder: (context, state) {
//           final cubit = context.read<PartnerCubit>();
//           List<Partner> companies = [];
//           List<Partner> originalCompanies = [];
//
//           // Individual state checks (like CompanyListPage)
//           if (state is CompaniesLoadedState) {
//             companies = state.companies ?? [];
//             originalCompanies = state.originalCompanies ?? [];
//           } else if (state is CompaniesFilteredState) {
//             companies = state.companies ?? [];
//             originalCompanies = state.originalCompanies ?? [];
//           } else if (state is CompaniesSortedState) {
//             companies = state.companies ?? [];
//             originalCompanies = state.originalCompanies ?? [];
//           } else if (state is CompanyDeletedState) {
//             companies = state.companies ?? [];
//             originalCompanies = state.originalCompanies ?? [];
//           } else if (state is FilterToggledState) {
//             companies = state.companies ?? [];
//             originalCompanies = state.originalCompanies ?? [];
//           }
//
//           return Scaffold(
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildSection(
//                     title: AppLabels.followUpChartTitle,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         _buildDropdown(
//                           context,
//                           cubit,
//                           selectedYearForFollowUp,
//                           cubit.getAvailableYears(),
//                           (value) =>
//                               setState(() => selectedYearForFollowUp = value),
//                         ),
//                         _buildFollowUpChart(cubit, selectedYearForFollowUp),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildSection(
//                     title: AppLabels.progressChartTitle,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         _buildDropdown(
//                           context,
//                           cubit,
//                           selectedYearForProgress,
//                           cubit.getAvailableYears(),
//                           (value) =>
//                               setState(() => selectedYearForProgress = value),
//                         ),
//                         _buildProgressChart(cubit, selectedYearForProgress),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildSection(
//                     title: AppLabels.comparisonChartTitle,
//                     child: _buildComparisonChart(
//                         cubit, selectedPeriod1, selectedPeriod2, context),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSection({required String title, required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.borderGrey),
//         boxShadow: const [
//           BoxShadow(
//             color: AppColors.shadowGrey,
//             blurRadius: 4,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdown(
//     BuildContext context,
//     PartnerCubit cubit,
//     String? selectedValue,
//     List<String> options,
//     Function(String) onChanged,
//   ) {
//     final uniqueOptions = options.toSet().toList();
//     if (selectedValue != null && !uniqueOptions.contains(selectedValue)) {
//       selectedValue = null;
//     }
//     return DropdownButton<String>(
//       value: selectedValue,
//       items: uniqueOptions.map((year) {
//         return DropdownMenuItem(value: year, child: Text(year));
//       }).toList(),
//       onChanged: (value) {
//         if (value != null) onChanged(value);
//       },
//     );
//   }
//
//   Widget _buildFollowUpChart(PartnerCubit cubit, String? selectedYear) {
//     final data = cubit.getFollowUpDataForYear(selectedYear);
//     bool hasData = data[AppKeys.totalKey]! > 0;
//
//     return Column(
//       children: [
//         hasData
//             ? SizedBox(
//                 height: 250,
//                 child: PieChart(
//                   PieChartData(
//                     sections: [
//                       PieChartSectionData(
//                         color: AppColors.green,
//                         value: data[AppKeys.sentKey]!.toDouble(),
//                         title: "${data[AppKeys.sentKey]}",
//                         radius: 60,
//                         titleStyle:
//                             const TextStyle(fontSize: 14, color: Colors.white),
//                       ),
//                       PieChartSectionData(
//                         color: AppColors.orange,
//                         value: data[AppKeys.notSentKey]!.toDouble(),
//                         title: "${data[AppKeys.notSentKey]}",
//                         radius: 60,
//                         titleStyle:
//                             const TextStyle(fontSize: 14, color: Colors.white),
//                       ),
//                     ],
//                     sectionsSpace: 2,
//                     centerSpaceRadius: 40,
//                   ),
//                 ),
//               )
//             : _buildNoDataMessage(),
//         if (hasData)
//           Padding(
//             padding: const EdgeInsets.only(top: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildLegendItem(AppColors.green,
//                     "${AppLabels.emailSentLabel}: ${data[AppKeys.sentKey]}"),
//                 const SizedBox(width: 20),
//                 _buildLegendItem(AppColors.orange,
//                     "${AppLabels.emailNotSentLabel}: ${data[AppKeys.notSentKey]}"),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildLegendItem(Color color, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(text, style: const TextStyle(fontSize: 14)),
//       ],
//     );
//   }
//
//   Widget _buildProgressChart(PartnerCubit cubit, String? selectedYear) {
//     final progressData = cubit.getProgressData(selectedYear);
//
//     int maxValue = progressData.maxValue > 0 ? progressData.maxValue : 1;
//     double chartHeight = 250;
//
//     return SizedBox(
//       height: chartHeight,
//       child: Stack(
//         children: [
//           BarChart(
//             BarChartData(
//               maxY: (maxValue + 5).toDouble(),
//               barGroups: progressData.bars,
//               titlesData: FlTitlesData(
//                 bottomTitles: SideTitles(
//                   showTitles: true,
//                   getTitles: (value) {
//                     int index = value.toInt();
//                     return (index >= 0 && index < progressData.labels.length)
//                         ? progressData.labels[index]
//                         : '';
//                   },
//                   margin: 10,
//                   reservedSize: 22,
//                 ),
//                 leftTitles: SideTitles(showTitles: false),
//                 topTitles: SideTitles(showTitles: false),
//                 rightTitles: SideTitles(showTitles: false),
//               ),
//               borderData: FlBorderData(show: false),
//               gridData: FlGridData(show: false),
//             ),
//           ),
//           Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: List.generate(progressData.bars.length, (index) {
//                   double barValue = progressData.bars[index].barRods[0].y;
//                   return barValue > 0
//                       ? Column(
//                           children: [
//                             Text(
//                               barValue.toInt().toString(),
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                               textAlign: TextAlign.left,
//                             ),
//                             SizedBox(
//                               height:
//                                   (chartHeight * (1 - (barValue / maxValue)))
//                                       .clamp(5, chartHeight),
//                             ),
//                           ],
//                         )
//                       : const SizedBox(width: 20);
//                 }),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildComparisonChart(PartnerCubit cubit, String? selectedPeriod1,
//       String? selectedPeriod2, BuildContext context) {
//     final comparisonData =
//         cubit.getComparisonData(selectedPeriod1, selectedPeriod2);
//
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildDropdown(
//               context,
//               cubit,
//               selectedPeriod1,
//               cubit.getAvailablePeriods(),
//               (value) => setState(() => selectedPeriod1 = value),
//             ),
//             _buildDropdown(
//               context,
//               cubit,
//               selectedPeriod2,
//               cubit.getAvailablePeriods(),
//               (value) => setState(() => selectedPeriod2 = value),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 250,
//           child: LineChart(
//             LineChartData(
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: [
//                     FlSpot(1,
//                         comparisonData[AppKeys.period1Key]?.toDouble() ?? 0.0),
//                     FlSpot(2,
//                         comparisonData[AppKeys.period2Key]?.toDouble() ?? 0.0),
//                   ],
//                   isCurved: true,
//                   barWidth: 4,
//                   colors: [AppColors.blue],
//                   isStrokeCapRound: true,
//                   belowBarData: BarAreaData(show: false),
//                 ),
//               ],
//               titlesData:
//                   _buildComparisonChartTitles(selectedPeriod1, selectedPeriod2),
//               gridData: FlGridData(show: false),
//               borderData: FlBorderData(show: false),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   FlTitlesData _buildComparisonChartTitles(String? period1, String? period2) {
//     return FlTitlesData(
//       bottomTitles: SideTitles(
//         showTitles: true,
//         getTitles: (value) {
//           if (value == 1) return period1 ?? '';
//           if (value == 2) return period2 ?? '';
//           return '';
//         },
//       ),
//       leftTitles: SideTitles(
//         showTitles: true,
//         getTitles: (value) => value.toInt().toString(),
//       ),
//     );
//   }
//
//   Widget _buildNoDataMessage() {
//     return const Center(
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Text(
//           AppLabels.noDataMessage,
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
