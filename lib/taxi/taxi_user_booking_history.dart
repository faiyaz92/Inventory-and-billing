import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_user_cubit.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class TaxiBookingsUserPage extends StatefulWidget {
  const TaxiBookingsUserPage({super.key});

  @override
  State<TaxiBookingsUserPage> createState() => _TaxiBookingsUserPageState();
}

class _TaxiBookingsUserPageState extends State<TaxiBookingsUserPage> {
  String _selectedFilter = 'today';
  late final TaxiUserCubit _taxiUserCubit;
  late DateTime startDate;
  late DateTime endDate;
  final _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    _taxiUserCubit = sl<TaxiUserCubit>()..fetchSettings();
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

    final state = _taxiUserCubit.state;
    if (state is TaxiUserSuccess) {
      _taxiUserCubit.fetchBookings(
        startDate: startDate,
        endDate: endDate,
        status: state.status,
        taxiTypeId: state.taxiTypeId,
        serviceTypeId: state.serviceTypeId,
        tripTypeId: state.tripTypeId,
        minTotalFareAmount: state.minTotalFareAmount,
        maxTotalFareAmount: state.maxTotalFareAmount,
      );
    } else {
      _taxiUserCubit.fetchBookings(
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
    return BlocBuilder<TaxiUserCubit, TaxiUserState>(
      buildWhen: (previous, current) =>
      current is TaxiUserLoading ||
          current is TaxiUserSuccess ||
          current is TaxiUserError,
      builder: (context, state) {
        if (state is TaxiUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TaxiUserError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is TaxiUserSuccess) {
          DateTime? bookingStartDate = state.startDate;
          DateTime? bookingEndDate = state.endDate;
          String? selectedStatus = state.status;
          String? selectedTaxiTypeId = state.taxiTypeId;
          String? selectedServiceTypeId = state.serviceTypeId;
          String? selectedTripTypeId = state.tripTypeId;
          double? minTotalFareAmount = state.minTotalFareAmount;
          double? maxTotalFareAmount = state.maxTotalFareAmount;

          final taxiTypeDropdownItems = [
            const DropdownMenuItem<String>(
                value: null, child: Text('All Taxi Types')),
            ..._taxiUserCubit
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
            ..._taxiUserCubit
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
            ..._taxiUserCubit
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
            ..._taxiUserCubit
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
                          _taxiUserCubit.fetchBookings(
                            startDate: dateRange.start,
                            endDate: dateRange.end,
                            status: selectedStatus,
                            taxiTypeId: selectedTaxiTypeId,
                            serviceTypeId: selectedServiceTypeId,
                            tripTypeId: selectedTripTypeId,
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
                        _taxiUserCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: value,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: maxTotalFareAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _taxiUserCubit.fetchBookings(),
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
              // const SizedBox(height: 12),
             /* Row(
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
                        _taxiUserCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: value,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
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
                        _taxiUserCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: value,
                          tripTypeId: selectedTripTypeId,
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
                        _taxiUserCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: value,
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
                        _taxiUserCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
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
                        _taxiUserCubit.fetchBookings(
                          startDate: bookingStartDate,
                          endDate: bookingEndDate,
                          status: selectedStatus,
                          taxiTypeId: selectedTaxiTypeId,
                          serviceTypeId: selectedServiceTypeId,
                          tripTypeId: selectedTripTypeId,
                          minTotalFareAmount: minTotalFareAmount,
                          maxTotalFareAmount: max,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),*/
              // Wrap(
              //   spacing: 8.0,
              //   runSpacing: 8.0,
              //   children: [
              //     ChoiceChip(
              //       label: const Text('25-35'),
              //       selected:
              //       minTotalFareAmount == 25 && maxTotalFareAmount == 35,
              //       selectedColor: AppColors.primary,
              //       backgroundColor: Colors.transparent,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //         side: BorderSide(
              //           color:
              //           minTotalFareAmount == 25 && maxTotalFareAmount == 35
              //               ? AppColors.primary
              //               : AppColors.textSecondary.withOpacity(0.5),
              //         ),
              //       ),
              //       onSelected: (selected) {
              //         if (selected) {
              //           _taxiUserCubit.fetchBookings(
              //             startDate: bookingStartDate,
              //             endDate: bookingEndDate,
              //             status: selectedStatus,
              //             taxiTypeId: selectedTaxiTypeId,
              //             serviceTypeId: selectedServiceTypeId,
              //             tripTypeId: selectedTripTypeId,
              //             minTotalFareAmount: 25,
              //             maxTotalFareAmount: 35,
              //           );
              //         }
              //       },
              //     ),
              //     ChoiceChip(
              //       label: const Text('36-45'),
              //       selected:
              //       minTotalFareAmount == 36 && maxTotalFareAmount == 45,
              //       selectedColor: AppColors.primary,
              //       backgroundColor: Colors.transparent,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //         side: BorderSide(
              //           color:
              //           minTotalFareAmount == 36 && maxTotalFareAmount == 45
              //               ? AppColors.primary
              //               : AppColors.textSecondary.withOpacity(0.5),
              //         ),
              //       ),
              //       onSelected: (selected) {
              //         if (selected) {
              //           _taxiUserCubit.fetchBookings(
              //             startDate: bookingStartDate,
              //             endDate: bookingEndDate,
              //             status: selectedStatus,
              //             taxiTypeId: selectedTaxiTypeId,
              //             serviceTypeId: selectedServiceTypeId,
              //             tripTypeId: selectedTripTypeId,
              //             minTotalFareAmount: 36,
              //             maxTotalFareAmount: 45,
              //           );
              //         }
              //       },
              //     ),
              //     ChoiceChip(
              //       label: const Text('46-55'),
              //       selected:
              //       minTotalFareAmount == 46 && maxTotalFareAmount == 55,
              //       selectedColor: AppColors.primary,
              //       backgroundColor: Colors.transparent,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //         side: BorderSide(
              //           color:
              //           minTotalFareAmount == 46 && maxTotalFareAmount == 55
              //               ? AppColors.primary
              //               : AppColors.textSecondary.withOpacity(0.5),
              //         ),
              //       ),
              //       onSelected: (selected) {
              //         if (selected) {
              //           _taxiUserCubit.fetchBookings(
              //             startDate: bookingStartDate,
              //             endDate: bookingEndDate,
              //             status: selectedStatus,
              //             taxiTypeId: selectedTaxiTypeId,
              //             serviceTypeId: selectedServiceTypeId,
              //             tripTypeId: selectedTripTypeId,
              //             minTotalFareAmount: 46,
              //             maxTotalFareAmount: 55,
              //           );
              //         }
              //       },
              //     ),
              //     ChoiceChip(
              //       label: const Text('56-60'),
              //       selected:
              //       minTotalFareAmount == 56 && maxTotalFareAmount == 60,
              //       selectedColor: AppColors.primary,
              //       backgroundColor: Colors.transparent,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //         side: BorderSide(
              //           color:
              //           minTotalFareAmount == 56 && maxTotalFareAmount == 60
              //               ? AppColors.primary
              //               : AppColors.textSecondary.withOpacity(0.5),
              //         ),
              //       ),
              //       onSelected: (selected) {
              //         if (selected) {
              //           _taxiUserCubit.fetchBookings(
              //             startDate: bookingStartDate,
              //             endDate: bookingEndDate,
              //             status: selectedStatus,
              //             taxiTypeId: selectedTaxiTypeId,
              //             serviceTypeId: selectedServiceTypeId,
              //             tripTypeId: selectedTripTypeId,
              //             minTotalFareAmount: 56,
              //             maxTotalFareAmount: 60,
              //           );
              //         }
              //       },
              //     ),
              //     ChoiceChip(
              //       label: const Text('>60'),
              //       selected:
              //       minTotalFareAmount == 60 && maxTotalFareAmount == null,
              //       selectedColor: AppColors.primary,
              //       backgroundColor: Colors.transparent,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //         side: BorderSide(
              //           color: minTotalFareAmount == 60 &&
              //               maxTotalFareAmount == null
              //               ? AppColors.primary
              //               : AppColors.textSecondary.withOpacity(0.5),
              //         ),
              //       ),
              //       onSelected: (selected) {
              //         if (selected) {
              //           _taxiUserCubit.fetchBookings(
              //             startDate: bookingStartDate,
              //             endDate: bookingEndDate,
              //             status: selectedStatus,
              //             taxiTypeId: selectedTaxiTypeId,
              //             serviceTypeId: selectedServiceTypeId,
              //             tripTypeId: selectedTripTypeId,
              //             minTotalFareAmount: 60,
              //             maxTotalFareAmount: null,
              //           );
              //         }
              //       },
              //     ),
              //   ],
              // ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBookingList() {
    return BlocBuilder<TaxiUserCubit, TaxiUserState>(
      buildWhen: (previous, current) =>
      current is TaxiUserLoading ||
          current is TaxiUserSuccess ||
          current is TaxiUserError,
      builder: (context, state) {
        if (state is TaxiUserSuccess) {
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
                        .map((booking) => _buildBookingCard(context, booking))
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

  Widget _buildBookingCard(BuildContext context, TaxiBooking booking) {
    final statusStyles = _taxiUserCubit.getStatusColors(booking.tripStatus);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
                          Clipboard.setData(
                              ClipboardData(text: booking.mobileNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number copied!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              booking.mobileNumber ?? 'No phone',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy,
                                size: 12, color: AppColors.textSecondary),
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
                _taxiUserCubit.formatTripDate(booking.tripDate),
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
                      _taxiUserCubit.getDisplayName(
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
                      _taxiUserCubit.getDisplayName(
                          id: booking.tripTypeId, type: 'tripType'),
                    ),
                    _buildTableRow(
                      'Time',
                      booking.tripStartTime,
                      isBold: true,
                      valueColor: AppColors.red,
                      backgroundColor: AppColors.highLightOrange,
                    ),
                    _buildTableRow(
                      'Trip booking date',
                      _taxiUserCubit.formatTripDate(booking.tripDate),
                      isBold: true,
                      valueColor: AppColors.red,
                      backgroundColor: AppColors.highLightOrange,
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
          ],
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
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _taxiUserCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'My Taxi Bookings'),
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
            child: BlocBuilder<TaxiUserCubit, TaxiUserState>(
              builder: (context, state) {
                if (state is TaxiUserLoading) {
                  return const CustomLoadingDialog(message: 'Loading...');
                } else if (state is TaxiUserSuccess) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildFilters(context),
                            const SizedBox(height: 16),
                          ]),
                        ),
                      ),
                      _buildBookingList(),
                    ],
                  );
                } else if (state is TaxiUserError) {
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
}