import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:requirment_gathering_app/company_admin_module/presentation/accounts/invoice_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/over_all_stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/purchase/purchase_order_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';

@RoutePage()
class DashboardStaticsPage extends StatefulWidget {
  const DashboardStaticsPage({super.key});

  @override
  State<DashboardStaticsPage> createState() => _DashboardStaticsPageState();
}

class _DashboardStaticsPageState extends State<DashboardStaticsPage> {
  String _selectedFilter = '3months';
  late final AdminInvoiceCubit _adminInvoiceCubit;
  late final AdminPurchaseCubit _adminPurchaseCubit;
  late final OverallStockCubit _overallStockCubit;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    _adminInvoiceCubit = sl<AdminInvoiceCubit>();
    _adminPurchaseCubit = sl<AdminPurchaseCubit>();
    _overallStockCubit = OverallStockCubit(stockService: sl<StockService>())
      ..loadOverallStock();
    _applyQuickFilter(_selectedFilter);
    super.initState();
  }

  @override
  void dispose() {
    _overallStockCubit.close();
    super.dispose();
  }

  void _applyQuickFilter(String filter) {
    _selectedFilter = filter;
    final now = DateTime.now();
    switch (filter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate;
        break;
      case 'yesterday':
        startDate = now.subtract(const Duration(days: 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate;
        break;
      case 'daybefore':
        startDate = now.subtract(const Duration(days: 2));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate;
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        endDate = now;
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case '3months':
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
      case '6months':
        startDate = now.subtract(const Duration(days: 180));
        endDate = now;
        break;
      default:
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
    }

    _adminInvoiceCubit.fetchInvoices(
      startDate: startDate,
      endDate: endDate,
      computePrevious: true,
    );
    _adminPurchaseCubit.fetchPurchaseOrders(
      startDate: startDate,
      endDate: endDate,
    );
    _overallStockCubit.loadOverallStock();
  }

  Widget _buildQuickFilterChips() {
    final filters = [
      {'label': 'Today', 'value': 'today'},
      {'label': 'Yesterday', 'value': 'yesterday'},
      {'label': 'Day Before', 'value': 'daybefore'},
      {'label': 'Week', 'value': 'week'},
      {'label': 'Month', 'value': 'month'},
      {'label': 'Last 3 Months', 'value': '3months'},
      {'label': 'Last 6 Months', 'value': '6months'},
      {'label': 'Last 1 Year', 'value': 'year'},
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick filter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight
                          .normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.secondary,
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _adminInvoiceCubit),
        BlocProvider.value(value: _adminPurchaseCubit),
        BlocProvider.value(value: _overallStockCubit),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Dashboard'),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme
                    .of(context)
                    .primaryColor
                    .withOpacity(0.1),
                Theme
                    .of(context)
                    .primaryColor
                    .withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AdminInvoiceCubit, AdminInvoiceState>(
              builder: (context, invoiceState) {
                if (invoiceState is AdminInvoiceListFetchLoading) {
                  return const CustomLoadingDialog(message: 'Loading...');
                } else if (invoiceState is AdminInvoiceListFetchSuccess) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildDateRangeButton(context, invoiceState),
                            const SizedBox(height: 16),
                            _buildQuickFilterChips(),
                            const SizedBox(height: 16),
                            _buildStatsCard(context, invoiceState),
                          ]),
                        ),
                      ),
                    ],
                  );
                } else if (invoiceState is AdminInvoiceListFetchError) {
                  return Center(child: Text('Error: ${invoiceState.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(BuildContext context,
      AdminInvoiceListFetchSuccess state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final dateRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: state.startDate ?? DateTime.now(),
                  end: state.endDate ?? DateTime.now(),
                ),
              );
              if (dateRange != null) {
                _adminInvoiceCubit.fetchInvoices(
                  startDate: dateRange.start,
                  endDate: dateRange.end,
                  computePrevious: true,
                );
                _adminPurchaseCubit.fetchPurchaseOrders(
                  startDate: dateRange.start,
                  endDate: dateRange.end,
                );
                _overallStockCubit.loadOverallStock();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Select Date Range',
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context,
      AdminInvoiceListFetchSuccess invoiceState) {
    const crossAxisCount = kIsWeb ? 7 : 2;
    return BlocBuilder<AdminPurchaseCubit, AdminPurchaseState>(
      builder: (context, purchaseState) {
        List<Map<String, dynamic>> purchaseStatistics = [];
        if (purchaseState is AdminPurchaseListFetchSuccess) {
          purchaseStatistics = purchaseState.statistics;
          print('Purchase Statistics: $purchaseStatistics');
        }
        return BlocBuilder<OverallStockCubit, OverallStockState>(
          builder: (context, stockState) {
            double totalStockValue = 0.0;
            if (stockState is OverallStockSuccess) {
              totalStockValue = stockState.totalStockValue;
            }
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Stock Value Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stock Value',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final pdf = await _generateStatsPdf(
                              invoiceState,
                              purchaseState is AdminPurchaseListFetchSuccess
                                  ? purchaseState
                                  : null,
                              stockState is OverallStockSuccess
                                  ? stockState
                                  : null,
                              section: 'stock',
                            );
                            sl<Coordinator>().navigateToBillPdfPage(
                              pdf: pdf,
                              billNumber: 'Stock_Stats_${DateTime
                                  .now()
                                  .millisecondsSinceEpoch}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            minimumSize: const Size(40, 40),
                          ),
                          child: const Text(
                            'Export as PDF',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: kIsWeb ? 1.0 : 1.2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory,
                                color: AppColors.primary,
                                size: kIsWeb ? 28 : 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Stock Value',
                                style: TextStyle(
                                  fontSize: kIsWeb ? 16 : 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${totalStockValue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: kIsWeb ? 16 : 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Sales Statistics Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sales Statistics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final pdf = await _generateStatsPdf(
                              invoiceState,
                              purchaseState is AdminPurchaseListFetchSuccess
                                  ? purchaseState
                                  : null,
                              stockState is OverallStockSuccess
                                  ? stockState
                                  : null,
                              section: 'sales',
                            );
                            sl<Coordinator>().navigateToBillPdfPage(
                              pdf: pdf,
                              billNumber: 'Sales_Stats_${DateTime
                                  .now()
                                  .millisecondsSinceEpoch}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            minimumSize: const Size(40, 40),
                          ),
                          child: const Text(
                            'Export as PDF',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: kIsWeb ? 1.0 : 1.2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: invoiceState.statistics.length,
                      itemBuilder: (context, index) {
                        final stat = invoiceState.statistics[index];
                        final prevStat = invoiceState.previousStatistics
                            .firstWhere(
                              (p) => p['label'] == stat['label'],
                          orElse: () => <String, dynamic>{},
                        );
                        num change = 0;
                        Color trendColor = Colors.grey;
                        IconData trendIcon = Icons.arrow_forward;
                        String trendText = '0%';
                        if (prevStat.isNotEmpty) {
                          final currentValue = stat['rawValue'] as num? ?? 0;
                          final prevValue = prevStat['rawValue'] as num? ?? 0;
                          if (prevValue != 0) {
                            change =
                                (currentValue - prevValue) / prevValue * 100;
                          } else {
                            change = currentValue > 0 ? double.infinity : 0;
                          }
                          if (change > 0) {
                            trendColor = Colors.green;
                            trendIcon = Icons.arrow_upward;
                          } else if (change < 0) {
                            trendColor = Colors.red;
                            trendIcon = Icons.arrow_downward;
                          } else {
                            trendColor = Colors.grey;
                            trendIcon = Icons.arrow_forward;
                          }
                          trendText = change.isInfinite
                              ? '+∞%'
                              : '${change.abs().toStringAsFixed(1)}%';
                        }
                        num totalAmount = invoiceState.statistics.firstWhere(
                              (s) => s['label'] == 'Total Amount',
                          orElse: () => {'rawValue': 0},
                        )['rawValue'] as num;
                        String valueText = stat['value']?.toString() ?? 'N/A';
                        if (totalAmount > 0 && [
                          'Cash Sales',
                          'Credit Sales',
                          'Total Collected Amount',
                          'Pending Collection Amount'
                        ].contains(stat['label']) && stat['rawValue'] != null) {
                          double perc = ((stat['rawValue'] as num) /
                              totalAmount) * 100;
                          valueText += ' (${perc.toStringAsFixed(1)}%)';
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: stat['highlight'] == true
                                ? (stat['color'] as Color?)?.withOpacity(0.1) ??
                                Colors.transparent
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconForStat(
                                    stat['label']?.toString() ?? 'Unknown'),
                                color: stat['color'] as Color? ??
                                    AppColors.primary,
                                size: kIsWeb ? 28 : 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stat['label']?.toString() ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: kIsWeb ? 16 : 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                valueText,
                                style: TextStyle(
                                  fontSize: kIsWeb ? 16 : 14,
                                  color: stat['color'] as Color? ??
                                      AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (prevStat.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      trendIcon,
                                      color: trendColor,
                                      size: 16,
                                    ),
                                    Text(
                                      trendText,
                                      style: TextStyle(
                                        color: trendColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Purchase Statistics Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Purchase Statistics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final pdf = await _generateStatsPdf(
                              invoiceState,
                              purchaseState is AdminPurchaseListFetchSuccess
                                  ? purchaseState
                                  : null,
                              stockState is OverallStockSuccess
                                  ? stockState
                                  : null,
                              section: 'purchase',
                            );
                            sl<Coordinator>().navigateToBillPdfPage(
                              pdf: pdf,
                              billNumber: 'Purchase_Stats_${DateTime
                                  .now()
                                  .millisecondsSinceEpoch}',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            minimumSize: const Size(40, 40),
                          ),
                          child: const Text(
                            'Export as PDF',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: kIsWeb ? 1.0 : 1.2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: purchaseStatistics.length,
                      itemBuilder: (context, index) {
                        final stat = purchaseStatistics[index];
                        num totalAmount = purchaseStatistics.firstWhere(
                              (s) => s['label'] == 'Total Amount',
                          orElse: () => {'rawValue': 0},
                        )['rawValue'] as num? ?? 0;
                        String valueText = stat['value']?.toString() ?? 'N/A';
                        if (totalAmount > 0 &&
                            stat['rawValue'] != null &&
                            [
                              'Cash Purchases',
                              'Credit Purchases',
                              'Total Paid Amount',
                              'Total Not Paid Amount'
                            ].contains(stat['label'] ?? '')) {
                          double perc = ((stat['rawValue'] as num) /
                              totalAmount) * 100;
                          valueText += ' (${perc.toStringAsFixed(1)}%)';
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: stat['highlight'] == true
                                ? (stat['color'] as Color?)?.withOpacity(0.1) ??
                                Colors.transparent
                                : Colors.transparent,
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconForPurchaseStat(
                                    stat['label']?.toString() ?? 'Unknown'),
                                color: stat['color'] as Color? ??
                                    AppColors.primary,
                                size: kIsWeb ? 28 : 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stat['label']?.toString() ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: kIsWeb ? 16 : 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                valueText,
                                style: TextStyle(
                                  fontSize: kIsWeb ? 16 : 14,
                                  color: stat['color'] as Color? ??
                                      AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final pdf = await _generateStatsPdf(
                          invoiceState,
                          purchaseState is AdminPurchaseListFetchSuccess
                              ? purchaseState
                              : null,
                          stockState is OverallStockSuccess ? stockState : null,
                        );
                        sl<Coordinator>().navigateToBillPdfPage(
                          pdf: pdf,
                          billNumber: 'Dashboard_Stats_${DateTime
                              .now()
                              .millisecondsSinceEpoch}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 8),
                      ),
                      child: const Text(
                        'Export All as PDF',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<pw.Document> _generateStatsPdf(
      AdminInvoiceListFetchSuccess invoiceState,
      AdminPurchaseListFetchSuccess? purchaseState,
      OverallStockSuccess? stockState, {
        String? section,
      }) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();

    String companyName = 'Abc Pvt. Ltd.';
    String issuerName = 'Unknown Issuer';
    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
      issuerName = userInfo?.name ?? userInfo?.userName ?? issuerName;
    } catch (e) {
      print('Error fetching company or issuer name: $e');
    }

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    const greyColor = PdfColors.grey300;

    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) =>
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 3, color: primaryColor)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(
                            font: boldFont, fontSize: 22, color: primaryColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '123 Business Street, City, Country',
                        style: pw.TextStyle(font: regularFont,
                            fontSize: 12,
                            color: textSecondaryColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        section == null ? 'DASHBOARD STATISTICS' : '${section
                            .toUpperCase()} STATISTICS',
                        style: pw.TextStyle(
                            font: boldFont, fontSize: 28, color: primaryColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Date: ${DateTime.now().toString().substring(0, 10)}',
                        style: pw.TextStyle(font: regularFont, fontSize: 14),
                      ),
                      pw.Text(
                        'Issuer: $issuerName',
                        style: pw.TextStyle(font: regularFont, fontSize: 14),
                      ),
                      pw.Text(
                        'Period: ${invoiceState.startDate?.toString().substring(
                            0, 10) ?? 'N/A'} to ${invoiceState.endDate
                            ?.toString().substring(0, 10) ?? 'N/A'}',
                        style: pw.TextStyle(font: regularFont, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        build: (context) {
          final List<pw.Widget> content = [];

          if (section == null || section == 'stock') {
            content.addAll([
              pw.SizedBox(height: 24),
              pw.Text(
                'Stock Value',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: greyColor, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(6),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Label',
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Value ', // Added  for clarity
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (stockState != null)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                              'Total Stock Value', style: pw.TextStyle(
                              font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            '${stockState.totalStockValue.toStringAsFixed(2)}', // Replaced ₹ with 
                            style: pw.TextStyle(font: regularFont,
                                fontSize: 12),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ]);
          }

          if (section == null || section == 'sales') {
            content.addAll([
              pw.SizedBox(height: 24),
              pw.Text(
                'Sales Statistics',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: greyColor, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(6),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Label',
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Value', // Added  for clarity
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Change',
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                    ],
                  ),
                  ...invoiceState.statistics
                      .asMap()
                      .entries
                      .map((entry) {
                    final stat = entry.value;
                    final prevStat = invoiceState.previousStatistics.firstWhere(
                          (p) => p['label'] == stat['label'],
                      orElse: () => <String, dynamic>{},
                    );
                    num change = 0;
                    String trendText = '- 0%';
                    if (prevStat.isNotEmpty) {
                      final currentValue = stat['rawValue'] as num? ?? 0;
                      final prevValue = prevStat['rawValue'] as num? ?? 0;
                      if (prevValue != 0) {
                        change = (currentValue - prevValue) / prevValue * 100;
                      } else {
                        change = currentValue > 0 ? double.infinity : 0;
                      }
                      trendText = change.isInfinite
                          ? '↑ ∞%'
                          : change > 0
                          ? '↑ ${change.abs().toStringAsFixed(1)}%'
                          : change < 0
                          ? '↓ ${change.abs().toStringAsFixed(1)}%'
                          : '- 0%';
                    }
                    num totalAmount = invoiceState.statistics.firstWhere(
                          (s) => s['label'] == 'Total Amount',
                      orElse: () => {'rawValue': 0},
                    )['rawValue'] as num? ?? 0;
                    String valueText = stat['value']?.toString() ?? 'N/A';
                    if (totalAmount > 0 && [
                      'Cash Sales',
                      'Credit Sales',
                      'Total Collected Amount',
                      'Pending Collection Amount'
                    ].contains(stat['label'] ?? '') &&
                        stat['rawValue'] != null) {
                      double perc = ((stat['rawValue'] as num) / totalAmount) *
                          100;
                      valueText = '${stat['rawValue'].toStringAsFixed(2)} (${perc.toStringAsFixed(1)}%)'; // Added 
                    }
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(stat['label']?.toString() ?? 'Unknown',
                              style: pw.TextStyle(
                                  font: regularFont, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            valueText,
                            style: pw.TextStyle(
                                font: regularFont, fontSize: 12),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Text(
                            trendText,
                            style: pw.TextStyle(
                                font: regularFont, fontSize: 12),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ]);
          }

          if (section == null || section == 'purchase') {
            content.addAll([
              pw.SizedBox(height: 24),
              pw.Text(
                'Purchase Statistics',
                style: pw.TextStyle(font: boldFont, fontSize: 18),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: greyColor, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(6),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Label',
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text('Value', // Added  for clarity
                            style: pw.TextStyle(font: boldFont, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (purchaseState != null)
                    ...purchaseState.statistics
                        .asMap()
                        .entries
                        .map((entry) {
                      final stat = entry.value;
                      num totalAmount = purchaseState.statistics.firstWhere(
                            (s) => s['label'] == 'Total Amount',
                        orElse: () => {'rawValue': 0},
                      )['rawValue'] as num? ?? 0;
                      String valueText = stat['value']?.toString() ?? 'N/A';
                      if (totalAmount > 0 && [
                        'Cash Purchases',
                        'Credit Purchases',
                        'Total Paid Amount',
                        'Total Not Paid Amount'
                      ].contains(stat['label'] ?? '') &&
                          stat['rawValue'] != null) {
                        double perc = ((stat['rawValue'] as num) /
                            totalAmount) * 100;
                        valueText = '${stat['rawValue'].toStringAsFixed(2)}  (${perc.toStringAsFixed(1)}%)'; // Added 
                      }
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text(
                                stat['label']?.toString() ?? 'Unknown',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 12)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text(
                              valueText,
                              style: pw.TextStyle(
                                  font: regularFont, fontSize: 12),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ]);
          }

          return content;
        },
        footer: (context) =>
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(top: 12),
              child: pw.Text(
                'Generated by $companyName | Page ${context
                    .pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                    font: regularFont, fontSize: 10, color: textSecondaryColor),
              ),
            ),
      ),
    );

    return pdf;
  }

  IconData _getIconForStat(String label) {
    switch (label) {
      case 'Total Invoices':
        return Icons.receipt_long;
      case 'Total Amount':
        return Icons.account_balance_wallet;
      case 'Cash Sales':
        return Icons.money;
      case 'Credit Sales':
        return Icons.credit_card;
      case 'No of Cash Invoices':
        return Icons.attach_money;
      case 'Paid':
        return Icons.check_circle;
      case 'Partial Paid':
        return Icons.hourglass_top;
      case 'Not Paid':
        return Icons.cancel;
      case "Today's Invoices":
        return Icons.today;
      case 'Total Collected Amount':
        return Icons.payments;
      case 'Pending Collection Amount':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  IconData _getIconForPurchaseStat(String label) {
    switch (label) {
      case 'Total Purchase Orders':
        return Icons.receipt_long;
      case 'Total Amount':
        return Icons.account_balance_wallet;
      case 'Cash Purchases':
        return Icons.money;
      case 'Credit Purchases':
        return Icons.credit_card;
      case 'Paid':
        return Icons.check_circle;
      case 'Partial Paid':
        return Icons.hourglass_top;
      case 'Not Paid':
        return Icons.cancel;
      case "Today's Purchase Orders":
        return Icons.today;
      case 'Total Paid Amount':
        return Icons.payments;
      case 'Total Not Paid Amount':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}