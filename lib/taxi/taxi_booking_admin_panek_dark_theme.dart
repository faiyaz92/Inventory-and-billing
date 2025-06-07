import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class TaxiBookingsAdminDarkPage extends StatefulWidget {
  const TaxiBookingsAdminDarkPage({super.key});

  @override
  State<TaxiBookingsAdminDarkPage> createState() => _TaxiBookingsAdminPageDarkState();
}

class _TaxiBookingsAdminPageDarkState extends State<TaxiBookingsAdminDarkPage> {
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
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Filters',
              style: defaultTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: filters.map((filter) {
                final isSelected = _selectedFilter == filter['value'];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: ChoiceChip(
                    label: Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF007BFF),
                    backgroundColor: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF007BFF)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        _applyQuickFilter(filter['value'] as String);
                      }
                    },
                  ),
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
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          );
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
              drivers.any((driver) => driver.userId == selectedAcceptedByDriverId)
              ? selectedAcceptedByDriverId
              : null;

          final driverDropdownItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Select')),
            ...drivers
                .where((driver) => driver.userId != null && driver.userId!.isNotEmpty)
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

          return Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.05),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
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
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF007BFF),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Color(0xFF333333),
                                  ),
                                  dialogBackgroundColor: Colors.white,
                                ),
                                child: child!,
                              );
                            },
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
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Select Date Range',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickFilterChips(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Status',
                          value: selectedStatus,
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
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _taxiAdminCubit.fetchBookings(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Taxi Type',
                          value: selectedTaxiTypeId,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Service Type',
                          value: selectedServiceTypeId,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Trip Type',
                          value: selectedTripTypeId,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Driver',
                          value: validAcceptedByDriverId,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Min Fare',
                          initialValue: minTotalFareAmount?.toString() ?? '',
                          onSubmitted: (value) {
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Max Fare',
                          initialValue: maxTotalFareAmount?.toString() ?? '',
                          onSubmitted: (value) {
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildFareChip(
                        label: '25-35',
                        min: 25,
                        max: 35,
                        isSelected: minTotalFareAmount == 25 && maxTotalFareAmount == 35,
                        onSelected: () {
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
                        },
                      ),
                      _buildFareChip(
                        label: '36-45',
                        min: 36,
                        max: 45,
                        isSelected: minTotalFareAmount == 36 && maxTotalFareAmount == 45,
                        onSelected: () {
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
                        },
                      ),
                      _buildFareChip(
                        label: '46-55',
                        min: 46,
                        max: 55,
                        isSelected: minTotalFareAmount == 46 && maxTotalFareAmount == 55,
                        onSelected: () {
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
                        },
                      ),
                      _buildFareChip(
                        label: '56-60',
                        min: 56,
                        max: 60,
                        isSelected: minTotalFareAmount == 56 && maxTotalFareAmount == 60,
                        onSelected: () {
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
                        },
                      ),
                      _buildFareChip(
                        label: '>60',
                        min: 60,
                        max: null,
                        isSelected: minTotalFareAmount == 60 && maxTotalFareAmount == null,
                        onSelected: () {
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
                        },
                      ),
                    ],
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Color(0xFF333333)),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: TextInputType.number,
        initialValue: initialValue,
        style: const TextStyle(color: Color(0xFF333333)),
        onFieldSubmitted: onSubmitted,
      ),
    );
  }

  Widget _buildFareChip({
    required String label,
    required double min,
    required double? max,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF007BFF),
        backgroundColor: const Color(0xFFF1F5F9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? const Color(0xFF007BFF) : const Color(0xFFE5E7EB),
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            onSelected();
          }
        },
      ),
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
            child: CircularProgressIndicator(color: Color(0xFF007BFF)),
          );
        }
        if (state is TaxiAdminError) {
          return Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.05),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppLabels.error}: ${state.message}',
                style: const TextStyle(fontSize: 16, color: Color(0xFFDC3545)),
              ),
            ),
          );
        }
        if (state is TaxiAdminSuccess) {
          return Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.05),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
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
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showStatsDialog(context, state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
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
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
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
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Align(
                          alignment: isLabel
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Text(
                            isLabel ? stat['label'] : stat['value'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isLabel
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF333333),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Table(
                  border: const TableBorder(
                    verticalInside: BorderSide(color: Color(0xFFE5E7EB)),
                    horizontalInside: BorderSide(color: Color(0xFFE5E7EB)),
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
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      )
                          : isLast
                          ? const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      )
                          : null,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  content: Column(
                    children: bookings
                        .asMap()
                        .entries
                        .map((entry) => _buildBookingCard(
                        context, entry.value, state, entry.key))
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

  Widget _buildBookingCard(BuildContext context, TaxiBooking booking,
      TaxiAdminSuccess state, int index) {
    final statusStyles = _taxiAdminCubit.getStatusColors(booking.tripStatus);
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: InkWell(
          onTap: () async {
            final result = await sl<Coordinator>()
                .navigateToBookingDetailsDarkPage(bookingId: booking.id);
            if (result) {
              _taxiAdminCubit.fetchBookings();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: Color(0xFF007BFF),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${booking.firstName} ${booking.lastName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: booking.mobileNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Phone number copied!'),
                                  backgroundColor: const Color(0xFF007BFF),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.phone,
                                    size: 16, color: Color(0xFF007BFF)),
                                const SizedBox(width: 6),
                                Text(
                                  booking.mobileNumber ?? 'No phone',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF007BFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy,
                                    size: 14, color: Color(0xFF6B7280)),
                              ],
                            ),
                          ),
                          Text(
                            'Driver: ${booking.acceptedByDriverName ?? "Unassigned"}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF007BFF)),
                          onPressed: () => _showStatusDialog(booking),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add,
                              color: Color(0xFF007BFF)),
                          onPressed: () => _showDriverAssignDialog(booking),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    _taxiAdminCubit.formatBookingDate(booking.tripDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Table(
                    border: const TableBorder(
                      verticalInside: BorderSide(color: Color(0xFFE5E7EB)),
                      horizontalInside: BorderSide(color: Color(0xFFE5E7EB)),
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
                        booking.tripStartTime,
                        isBold: true,
                        valueColor: const Color(0xFFDC3545),
                        backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                      ),
                      _buildTableRow(
                        'Trip Booking Date',
                        _taxiAdminCubit.formatTripDate(booking.tripDate),
                        isBold: true,
                        valueColor: const Color(0xFFDC3545),
                        backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                      ),
                      _buildTableRow(
                        'Fare',
                        '\$${booking.totalFareAmount.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: const Color(0xFF333333),
                        backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (booking.tripStatus.toLowerCase() == 'confirmed' ||
                    booking.tripStatus.toLowerCase() == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _taxiAdminCubit.updateBookingStatus(
                              booking.id, 'Declined');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          _taxiAdminCubit.acceptBooking(booking.id, null);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28A745),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                          await _taxiAdminCubit.unAssignedBooking(booking.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'Unassign',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await _taxiAdminCubit.startTrip(booking.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28A745),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'Start Trip',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                          await _taxiAdminCubit.finishTrip(booking.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF28A745),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'Finish Trip',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
              ],
            ),
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
        Color? valueColor = const Color(0xFF6B7280),
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
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
        appBar: const CustomAppBar(
          title: 'Taxi Booking Admin',

        ),
        body: Container(
          color: const Color(0xFFF5F7FA),
          child: SafeArea(
            child: BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
              builder: (context, state) {
                if (state is TaxiAdminLoading) {
                  return const CustomLoadingDialog(message: 'Loading...');
                } else if (state is TaxiAdminSuccess) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(12.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildFilters(context),
                            const SizedBox(height: 24),
                            _buildStatsCard(context),
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
                      _buildBookingList(),
                    ],
                  );
                } else if (state is TaxiAdminError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(TaxiBooking booking) {
    final tripStatuses = _taxiAdminCubit.getSettings().tripStatuses;
    final uniqueStatuses = <String, TripStatus>{};
    for (var status in tripStatuses) {
      uniqueStatuses[status.id] = status;
    }
    final statusList = uniqueStatuses.values.toList();

    String? initialStatus = booking.tripStatus;
    if (!statusList.any((status) => status.id == initialStatus)) {
      initialStatus = statusList.isNotEmpty ? statusList.first.id : null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Update Status',
            style: TextStyle(
                color: Color(0xFF333333), fontWeight: FontWeight.w600),
          ),
          content: statusList.isEmpty
              ? const Text('No trip statuses available',
              style: TextStyle(color: Color(0xFF6B7280)))
              : DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Trip Status',
              labelStyle: const TextStyle(color: Color(0xFF6B7280)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            value: initialStatus,
            items: statusList
                .map((status) => DropdownMenuItem<String>(
              value: status.id,
              child: Text(status.name,
                  style: const TextStyle(color: Color(0xFF333333))),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  initialStatus = value;
                });
              }
            },
            dropdownColor: Colors.white,
            style: const TextStyle(color: Color(0xFF333333)),
            validator: (value) =>
            value == null ? 'Please select a status' : null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B7280)),
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
                style: TextStyle(color: Color(0xFF007BFF)),
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Assign Driver',
                style: TextStyle(
                    color: Color(0xFF333333), fontWeight: FontWeight.w600),
              ),
              content: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Driver',
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                value: selectedDriverId,
                items: state.drivers
                    .map((driver) => DropdownMenuItem(
                  value: driver.userId,
                  child: Text(
                    driver.userName ?? 'Unknown',
                    style: const TextStyle(color: Color(0xFF333333)),
                  ),
                ))
                    .toList(),
                onChanged: (value) => selectedDriverId = value,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Color(0xFF333333)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDriverId != null) {
                      final selectedDriver = state.drivers.firstWhere(
                              (driver) => driver.userId == selectedDriverId);
                      _taxiAdminCubit.assignBooking(
                          booking.id, selectedDriver, booking.acceptedByDriverId);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Assign',
                    style: TextStyle(color: Color(0xFF007BFF)),
                  ),
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