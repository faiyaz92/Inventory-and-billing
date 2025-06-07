import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:flutter/services.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class TodaysTaxiBookingsPage extends StatefulWidget {
  const TodaysTaxiBookingsPage({super.key});

  @override
  State<TodaysTaxiBookingsPage> createState() => _TodaysTaxiBookingsPageState();
}

class _TodaysTaxiBookingsPageState extends State<TodaysTaxiBookingsPage> {
  late final TaxiAdminCubit _taxiAdminCubit;
  final _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    _taxiAdminCubit = sl<TaxiAdminCubit>()..fetchSettings();
    _fetchTodaysBookings();
    super.initState();
  }

  void _fetchTodaysBookings() {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);
    final endDate = startDate;
    _taxiAdminCubit.fetchBookings(startDate: startDate, endDate: endDate);
  }

  Widget _buildBookingCard(BuildContext context, TaxiBooking booking, TaxiAdminSuccess state) {
    final statusStyles = _taxiAdminCubit.getStatusColors(booking.tripStatus);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () async {
          final result = await sl<Coordinator>().navigateToBookingDetailsPage(bookingId: booking.id);
          if (result) {
            _fetchTodaysBookings();
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
                        icon: const Icon(Icons.person_add, color: AppColors.primary),
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
                        _taxiAdminCubit.getDisplayName(id: booking.tripStatus, type: 'status'),
                        valueColor: statusStyles['color'],
                        backgroundColor: statusStyles['backgroundColor'],
                        valueWeight: booking.tripStatus.toLowerCase() == 'pending' ||
                            booking.tripStatus.toLowerCase() == 'inprogress'
                            ? FontWeight.bold
                            : null,
                      ),
                      _buildTableRow(
                        'Trip Type',
                        _taxiAdminCubit.getDisplayName(id: booking.tripTypeId, type: 'tripType'),
                      ),
                      _buildTableRow(
                        'Time',
                        isBold: true,
                        valueColor: AppColors.red,
                        booking.tripStartTime,
                        backgroundColor: AppColors.highLightOrange,
                      ),
                      _buildTableRow(
                        'Trip booking date',
                        isBold: true,
                        valueColor: AppColors.red,
                        _taxiAdminCubit.formatTripDate(booking.tripDate),
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
              const SizedBox(height: 8),
              if (booking.tripStatus.toLowerCase() == 'confirmed' ||
                  booking.tripStatus.toLowerCase() == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _taxiAdminCubit.updateBookingStatus(booking.id, 'Declined');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        await _taxiAdminCubit.unAssignedBooking(booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        'Not Assign',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await _taxiAdminCubit.startTrip(booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        await _taxiAdminCubit.finishTrip(booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _showStatusDialog(TaxiBooking booking) {
    String? initialStatus = booking.tripStatus;
    final tripStatuses = _taxiAdminCubit.getSettings().tripStatuses;
    final uniqueStatuses = <String, TripStatus>{};
    for (var status in tripStatuses) {
      uniqueStatuses[status.id] = status;
    }
    final statusList = uniqueStatuses.values.toList();

    if (!statusList.any((status) => status.id == initialStatus)) {
      initialStatus = statusList.isNotEmpty ? statusList.first.id : null;
    }

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
            validator: (value) => value == null ? 'Please select a status' : null,
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
                _taxiAdminCubit.updateBookingStatus(booking.id, initialStatus!);
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDriverId != null) {
                      final selectedDriver = state.drivers.firstWhere(
                              (driver) => driver.userId == selectedDriverId);
                      _taxiAdminCubit.assignBooking(booking.id, selectedDriver, booking.acceptedByDriverId);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Assign', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _taxiAdminCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Today's Booking"),
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
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaxiAdminSuccess) {
                  final today = _dateFormatter.format(DateTime.now());
                  final bookings = state.groupedBookings[today] ?? [];
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Total Bookings: ${bookings.length}',
                            style: defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      bookings.isEmpty
                          ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No bookings found for today',
                              style: defaultTextStyle(fontSize: 16, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      )
                          : SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return StickyHeader(
                              header: Container(
                                width: double.infinity,
                                color: Theme.of(context).scaffoldBackgroundColor,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Text(
                                  today,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              content: _buildBookingCard(context, bookings[index], state),
                            );
                          },
                          childCount: bookings.length,
                        ),
                      ),
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
}