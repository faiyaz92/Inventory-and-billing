import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class TaxiBookingsAdminPage extends StatefulWidget {
  const TaxiBookingsAdminPage({super.key});

  @override
  State<TaxiBookingsAdminPage> createState() => _TaxiBookingsAdminPageState();
}

class _TaxiBookingsAdminPageState extends State<TaxiBookingsAdminPage> {
  String _selectedFilter = 'today';
  late final TaxiAdminCubit _taxiAdminCubit;
  late DateTime startDate;
  late DateTime endDate;
  final _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    _taxiAdminCubit = sl<TaxiAdminCubit>()..fetchSettings();
    _applyQuickFilter(_selectedFilter);
    super.initState();
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
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
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        endDate = now;
        break;
      default:
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
    }

    final state = _taxiAdminCubit.state;
    if (state is TaxiAdminSuccess) {
      _taxiAdminCubit.fetchBookings(
        startDate: startDate,
        endDate: endDate,
        status: state.status,
        taxiTypeId: state.taxiTypeId,
        serviceTypeId: state.serviceTypeId,
        tripTypeId: state.tripTypeId,
        acceptedByDriverId: state.acceptedByDriverId,
        minTotalFareAmount: state.minTotalFareAmount,
        maxTotalFareAmount: state.maxTotalFareAmount,
      );
    } else {
      _taxiAdminCubit.fetchBookings(
        startDate: startDate,
        endDate: endDate,
      );
    }
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
              'Quick Filter',
              style:
                  defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
      buildWhen: (previous, current) =>
          current is TaxiAdminLoading ||
          current is TaxiAdminSuccess ||
          current is TaxiAdminError,
      builder: (context, state) {
        if (state is TaxiAdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaxiAdminError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is TaxiAdminSuccess) {
          DateTime? bookingStartDate = state.startDate;
          DateTime? bookingEndDate = state.endDate;
          String? selectedStatus = state.status;
          String? selectedTaxiTypeId = state.taxiTypeId;
          String? selectedServiceTypeId = state.serviceTypeId;
          String? selectedTripTypeId = state.tripTypeId;
          String? selectedAcceptedByDriverId = state.acceptedByDriverId;
          double? minTotalFareAmount = state.minTotalFareAmount;
          double? maxTotalFareAmount = state.maxTotalFareAmount;
          List<UserInfo> drivers = state.drivers;

          final validAcceptedByDriverId = selectedAcceptedByDriverId != null &&
                  drivers.any(
                      (driver) => driver.userId == selectedAcceptedByDriverId)
              ? selectedAcceptedByDriverId
              : null;

          final driverDropdownItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Select')),
            ...drivers
                .where((driver) =>
                    driver.userId != null && driver.userId!.isNotEmpty)
                .map((driver) => DropdownMenuItem<String>(
                      value: driver.userId,
                      child: Text(driver.userName ?? 'Unknown'),
                    )),
          ];

          final taxiTypeDropdownItems = [
            const DropdownMenuItem<String>(
                value: null, child: Text('All Taxi Types')),
            ..._taxiAdminCubit
                .getSettings()
                .taxiTypes
                .map((type) => DropdownMenuItem<String>(
                      value: type.id,
                      child: Text(type.name),
                    )),
          ];

          final serviceTypeDropdownItems = [
            const DropdownMenuItem<String>(
                value: null, child: Text('All Service Types')),
            ..._taxiAdminCubit
                .getSettings()
                .serviceTypes
                .map((type) => DropdownMenuItem<String>(
                      value: type.id,
                      child: Text(type.name),
                    )),
          ];

          final tripTypeDropdownItems = [
            const DropdownMenuItem<String>(
                value: null, child: Text('All Trip Types')),
            ..._taxiAdminCubit
                .getSettings()
                .tripTypes
                .map((type) => DropdownMenuItem<String>(
                      value: type.id,
                      child: Text(type.name),
                    )),
          ];

          final statusDropdownItems = [
            const DropdownMenuItem<String>(
                value: null, child: Text('All Statuses')),
            ..._taxiAdminCubit
                .getSettings()
                .tripStatuses
                .map((status) => DropdownMenuItem<String>(
                      value: status.id,
                      child: Text(status.name),
                    )),
          ];

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final dateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: DateTimeRange(
                            start: bookingStartDate ?? DateTime.now(),
                            end: bookingEndDate ?? DateTime.now(),
                          ),
                        );
                        if (dateRange != null) {
                          _taxiAdminCubit.fetchBookings(
                            startDate: dateRange.start,
                            endDate: dateRange.end,
                            status: selectedStatus,
                            taxiTypeId: selectedTaxiTypeId,
                            serviceTypeId: selectedServiceTypeId,
                            tripTypeId: selectedTripTypeId,
                            acceptedByDriverId: validAcceptedByDriverId,
                            minTotalFareAmount: minTotalFareAmount,
                            maxTotalFareAmount: maxTotalFareAmount,
                          );
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
                        'Date Range: Booking',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildQuickFilterChips(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Status',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: selectedStatus,
                      hint: const Text(
                        'All Statuses',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: statusDropdownItems,
                      onChanged: (value) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: value,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _taxiAdminCubit.fetchBookings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Taxi Type',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: selectedTaxiTypeId,
                      hint: const Text(
                        'All Taxi Types',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: taxiTypeDropdownItems,
                      onChanged: (value) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: value,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Service Type',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: selectedServiceTypeId,
                      hint: const Text(
                        'All Service Types',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: serviceTypeDropdownItems,
                      onChanged: (value) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: value,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Trip Type',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: selectedTripTypeId,
                      hint: const Text(
                        'All Trip Types',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: tripTypeDropdownItems,
                      onChanged: (value) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: value,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Driver',
                        labelStyle:
                            const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: validAcceptedByDriverId,
                      hint: const Text(
                        'All Drivers',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: driverDropdownItems,
                      onChanged: (value) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: value,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Min Fare Amount',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: minTotalFareAmount?.toString() ?? '',
                      onFieldSubmitted: (value) {
                        final min = double.tryParse(value);
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: min,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Max Fare Amount',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: maxTotalFareAmount?.toString() ?? '',
                      onFieldSubmitted: (value) {
                        final max = double.tryParse(value);
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: max,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('25-35'),
                    selected:
                        minTotalFareAmount == 25 && maxTotalFareAmount == 35,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            minTotalFareAmount == 25 && maxTotalFareAmount == 35
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: 25,
                          maxTotalFareAmount: 35,
                        );
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('36-45'),
                    selected:
                        minTotalFareAmount == 36 && maxTotalFareAmount == 45,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            minTotalFareAmount == 36 && maxTotalFareAmount == 45
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: 36,
                          maxTotalFareAmount: 45,
                        );
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('46-55'),
                    selected:
                        minTotalFareAmount == 46 && maxTotalFareAmount == 55,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            minTotalFareAmount == 46 && maxTotalFareAmount == 55
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: 46,
                          maxTotalFareAmount: 55,
                        );
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('56-60'),
                    selected:
                        minTotalFareAmount == 56 && maxTotalFareAmount == 60,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color:
                            minTotalFareAmount == 56 && maxTotalFareAmount == 60
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: 56,
                          maxTotalFareAmount: 60,
                        );
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('>60'),
                    selected:
                        minTotalFareAmount == 60 && maxTotalFareAmount == null,
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: minTotalFareAmount == 60 &&
                                maxTotalFareAmount == null
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _taxiAdminCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          acceptedByDriverId: validAcceptedByDriverId,
                          minTotalFareAmount: 60,
                          maxTotalFareAmount: null,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
      buildWhen: (previous, current) =>
          current is TaxiAdminLoading ||
          current is TaxiAdminSuccess ||
          current is TaxiAdminError,
      builder: (context, state) {
        if (state is TaxiAdminLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is TaxiAdminError) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppLabels.error}: ${state.message}',
                style: const TextStyle(fontSize: 16, color: AppColors.red),
              ),
            ),
          );
        }
        if (state is TaxiAdminSuccess) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showStatsDialog(context, state),
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
                          'View',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: state.statistics.length * 2,
                    itemBuilder: (context, index) {
                      final statIndex = index ~/ 2;
                      final isLabel = index % 2 == 0;
                      final stat = state.statistics[statIndex];
                      return Container(
                        decoration: BoxDecoration(
                          color: stat['highlight'] == true
                              ? (stat['color'] as Color).withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Align(
                          alignment: isLabel
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Text(
                            isLabel ? stat['label'] : stat['value'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isLabel
                                  ? AppColors.textSecondary
                                  : stat['color'],
                              fontWeight: stat['highlight'] == true && !isLabel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showStatsDialog(BuildContext context, TaxiAdminSuccess state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Table(
                  border: TableBorder(
                    verticalInside: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      width: 1,
                    ),
                    horizontalInside: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(6),
                    1: FlexColumnWidth(2),
                  },
                  children: state.statistics.asMap().entries.map((entry) {
                    final stat = entry.value;
                    final isLast = entry.key == state.statistics.length - 1;
                    final isFirst = entry.key == 0;
                    return _buildTableRow(
                      stat['label'],
                      stat['value'],
                      valueColor: stat['color'],
                      valueWeight:
                          stat['highlight'] == true ? FontWeight.bold : null,
                      backgroundColor: stat['highlight'] == true
                          ? (stat['color'] as Color).withOpacity(0.1)
                          : null,
                      borderRadius: isFirst
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            )
                          : isLast
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                )
                              : null,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingList() {
    return BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
      buildWhen: (previous, current) =>
          current is TaxiAdminLoading ||
          current is TaxiAdminSuccess ||
          current is TaxiAdminError,
      builder: (context, state) {
        if (state is TaxiAdminSuccess) {
          final dates = state.groupedBookings.keys.toList()
            ..sort((a, b) => DateFormat('MMM dd, yyyy')
                .parse(b)
                .compareTo(DateFormat('MMM dd, yyyy').parse(a)));
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = dates[index];
                final bookings = state.groupedBookings[date]!;
                return StickyHeader(
                  header: Container(
                    width: double.infinity,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  content: Column(
                    children: bookings
                        .map((booking) =>
                            _buildBookingCard(context, booking, state))
                        .toList(),
                  ),
                );
              },
              childCount: dates.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildBookingCard(
      BuildContext context, TaxiBooking booking, TaxiAdminSuccess state) {
    final statusStyles = _taxiAdminCubit.getStatusColors(booking.tripStatus);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () async{
         final result = await sl<Coordinator>().navigateToBookingDetailsPage(bookingId: booking.id);
         // _taxiAdminCubit.fetchBookings();

         if(result){
           _taxiAdminCubit.fetchBookings();
         }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_taxi,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.firstName} ${booking.lastName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: booking.mobileNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Phone number copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                booking.mobileNumber ?? 'No phone',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy, size: 12, color: AppColors.textSecondary),
                            /*  IconButton(
                                icon: Icon(Icons.phone),
                                onPressed: () async {
                                  if (booking.mobileNumber != null) {
                                    final Uri phoneUri = Uri.parse('tel:${booking.mobileNumber}');
                                    if (await canLaunchUrl(phoneUri)) {
                                      await launchUrl(phoneUri);
                                    }
                                  }
                                },
                              ),*/
                            ],
                          ),
                        ),

                        Text(
                          'Driver: ${booking.acceptedByDriverName ?? "Unassigned"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => _showStatusDialog(booking),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add,
                            color: AppColors.primary),
                        onPressed: () => _showDriverAssignDialog(booking),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _taxiAdminCubit.formatBookingDate(booking.tripDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Table(
                    border: TableBorder(
                      verticalInside: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        width: 1,
                      ),
                      horizontalInside: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildTableRow(
                        'Pickup',
                        booking.pickupAddress,
                        maxLines: 2,
                      ),
                      _buildTableRow(
                        'Drop-off',
                        booking.dropAddress,
                        maxLines: 2,
                      ),
                      _buildTableRow(
                        'Status',
                        _taxiAdminCubit.getDisplayName(
                            id: booking.tripStatus, type: 'status'),
                        valueColor: statusStyles['color'],
                        backgroundColor: statusStyles['backgroundColor'],
                        valueWeight: booking.tripStatus.toLowerCase() ==
                                    'pending' ||
                                booking.tripStatus.toLowerCase() == 'inprogress'
                            ? FontWeight.bold
                            : null,
                      ),
                      _buildTableRow(
                        'Trip Type',
                        _taxiAdminCubit.getDisplayName(
                            id: booking.tripTypeId, type: 'tripType'),
                      ),
                      _buildTableRow(
                        'Time',
                        isBold: true,
                        valueColor: AppColors.red,
                        booking.tripStartTime,
                        backgroundColor: AppColors.highLightOrange
                      ),
                      _buildTableRow(
                        // backgroundColor: AppColors.secondaryLight,
                        valueColor: AppColors.red,
                        'Trip booking date',
                        isBold: true,
                          backgroundColor: AppColors.highLightOrange,

                       _taxiAdminCubit.formatTripDate(booking.tripDate),
                      ),
                      _buildTableRow(
                        'Fare',
                        '\$${booking.totalFareAmount.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: AppColors.textPrimary,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (booking.tripStatus.toLowerCase() ==
                      'Confirmed'.toLowerCase() ||
                  booking.tripStatus.toLowerCase() == 'Pending'.toLowerCase())
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _taxiAdminCubit.updateBookingStatus(
                            booking.id, 'Declined');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: () {
                        _taxiAdminCubit.acceptBooking(booking.id, null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                  ],
                )
              else if (booking.accepted &&
                  booking.tripStatus.toLowerCase() == 'accepted' &&
                  state.currentLoggedInUserId == booking.acceptedByDriverId)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _taxiAdminCubit.unAssignedBooking(
                          booking.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Not Assign',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _taxiAdminCubit.startTrip(
                          booking.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Start trip',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                  ],
                )
              else if (booking.accepted &&
                  booking.tripStatus.toLowerCase() == 'in-progress' &&
                  state.currentLoggedInUserId == booking.acceptedByDriverId)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _taxiAdminCubit.finishTrip(
                        booking.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Finish trip',
                      style: TextStyle(color: AppColors.white, fontSize: 12),
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
                fontWeight: valueWeight ??
                    (isBold ? FontWeight.bold : FontWeight.normal),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _taxiAdminCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Taxi booking admin"),
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
            child: BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
              builder: (context, state) {
                if (state is TaxiAdminLoading) {
                  return const CustomLoadingDialog(message: 'Loading...');
                } else if (state is TaxiAdminSuccess) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildFilters(context),
                            const SizedBox(height: 16),
                            _buildStatsCard(context),
                            const SizedBox(height: 16),
                          ]),
                        ),
                      ),
                      _buildBookingList(),
                    ],
                  );
                } else if (state is TaxiAdminError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

/*
  void _showStatusDialog(TaxiBooking booking) {
    final statusController = TextEditingController(text: booking.tripStatus);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Trip Status',
            border: OutlineInputBorder(),
          ),
          value: statusController.text,
          items: _taxiAdminCubit.settingsCubit.state.tripStatuses
              .map((status) => DropdownMenuItem<String>(
            value: status.id,
            child: Text(status.name),
          ))
              .toList(),
          onChanged: (value) => statusController.text = value ?? 'pending',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              _taxiAdminCubit.updateBookingStatus(booking.id, statusController.text);
              Navigator.pop(context);
            },
            child: const Text('Update',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
*/
  void _showStatusDialog(TaxiBooking booking) {
    // Log for debugging
    print('Booking tripStatus: ${booking.tripStatus}');
    print(
        'TripStatuses: ${_taxiAdminCubit.getSettings().tripStatuses.map((s) => "${s.id}: ${s.name}").toList()}');

    // Get unique trip statuses to avoid duplicates
    final tripStatuses = _taxiAdminCubit.getSettings().tripStatuses;
    final uniqueStatuses = <String, TripStatus>{};
    for (var status in tripStatuses) {
      uniqueStatuses[status.id] = status; // Keep last status for each id
    }
    final statusList = uniqueStatuses.values.toList();

    // Validate initial value
    String? initialStatus = booking.tripStatus;
    if (!statusList.any((status) => status.id == initialStatus)) {
      initialStatus = statusList.isNotEmpty ? statusList.first.id : null;
      print(
          'Warning: booking.tripStatus (${booking.tripStatus}) not found in tripStatuses, using $initialStatus');
    }

    // Use a stateful dialog to manage dropdown value
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Status'),
          content: statusList.isEmpty
              ? const Text('No trip statuses available')
              : DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Trip Status',
                    border: OutlineInputBorder(),
                  ),
                  value: initialStatus,
                  items: statusList
                      .map((status) => DropdownMenuItem<String>(
                            value: status.id,
                            child: Text(status.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        initialStatus = value;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select a status' : null,
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: initialStatus == null
                  ? null
                  : () {
                      _taxiAdminCubit.updateBookingStatus(
                          booking.id, initialStatus!);
                      Navigator.pop(context);
                    },
              child: const Text(
                'Update',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverAssignDialog(TaxiBooking booking) {
    String? selectedDriverId;
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
        bloc: _taxiAdminCubit,
        builder: (context, state) {
          if (state is TaxiAdminSuccess) {
            return AlertDialog(
              title: const Text('Assign Driver'),
              content: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Driver',
                  border: OutlineInputBorder(),
                ),
                value: selectedDriverId,
                items: state.drivers
                    .map((driver) => DropdownMenuItem(
                          value: driver.userId,
                          child: Text(driver.userName ?? 'Unknown'),
                        ))
                    .toList(),
                onChanged: (value) => selectedDriverId = value,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDriverId != null) {
                      final selectedDriver = state.drivers.firstWhere(
                          (driver) => driver.userId == selectedDriverId);
                      _taxiAdminCubit.assignBooking(booking.id, selectedDriver,
                          booking.acceptedByDriverId);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Assign',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
