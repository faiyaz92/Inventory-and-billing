import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';

@RoutePage()
class TaxiBookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const TaxiBookingDetailsPage({super.key, required this.bookingId});

  @override
  State<TaxiBookingDetailsPage> createState() => _TaxiBookingDetailsPageState();
}

class _TaxiBookingDetailsPageState extends State<TaxiBookingDetailsPage> {
  late final TaxiAdminCubit _taxiAdminCubit;
  TaxiBooking? _booking;
  var _isNeedToUpdate =false;

  @override
  void initState() {
    super.initState();
    _taxiAdminCubit = sl<TaxiAdminCubit>()..fetchSettings();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final booking = await _taxiAdminCubit.fetchBookingById(widget.bookingId);
    if (mounted) {
      setState(() {
        _booking = booking;
      });
    }
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: statusList.isEmpty
              ? const Text('No trip statuses available')
              : DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Trip Status',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
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
                  : () async{
             await   _taxiAdminCubit.updateBookingStatus(
                    booking.id, initialStatus!);
                _isNeedToUpdate =true;
                Navigator.pop(context);
                _fetchBookingDetails();
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
        builder: (context, state) {
          if (state is TaxiAdminSuccess) {
            return AlertDialog(
              title: const Text('Assign Driver'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Driver',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedDriverId != null) {
                      final selectedDriver = state.drivers.firstWhere(
                              (driver) => driver.userId == selectedDriverId);
                      _taxiAdminCubit.assignBooking(
                          booking.id, selectedDriver, booking.acceptedByDriverId);
                      Navigator.pop(context);
                      _fetchBookingDetails();
                    }
                  },
                  child: const Text(
                    'Assign',
                    style: TextStyle(color: AppColors.primary),
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

  Widget _buildBookingDetails(TaxiBooking booking, TaxiAdminSuccess state) {
    final statusStyles = _taxiAdminCubit.getStatusColors(booking.tripStatus);
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final fullDateFormatter = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                          fontSize: 20,
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
                              '${booking.countryCode}${booking.mobileNumber}',
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
                          fontSize: 16,
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
            const SizedBox(height: 16),
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
                'Trip Date: ${_taxiAdminCubit.formatTripDate(booking.tripDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
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
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(4),
                },
                children: [
                  _buildTableRow(
                    'Booking ID',
                    booking.id,
                  ),
                  _buildTableRow(
                    'Passenger Count',
                    booking.passengerNumbers.toString(),
                  ),
                  _buildTableRow(
                    'Email',
                    booking.email,
                  ),
                  _buildTableRow(
                    'Phone',
                    '${booking.countryCode}${booking.mobileNumber}',
                  ),
                  _buildTableRow(
                    'Pickup Address',
                    booking.pickupAddress,
                    maxLines: 2,
                  ),
                  _buildTableRow(
                    'Drop-off Address',
                    booking.dropAddress,
                    maxLines: 2,
                  ),
                  _buildTableRow(
                    'Trip Start Time',
                    booking.tripStartTime,
                    backgroundColor: AppColors.highLightOrange,
                    valueColor: AppColors.red,
                    isBold: true,
                  ),
                  _buildTableRow(
                    'Actual Start Time',
                    booking.actualStartTime != null
                        ? fullDateFormatter.format(booking.actualStartTime!)
                        : 'N/A',
                  ),
                  _buildTableRow(
                    'Completed Time',
                    booking.completedTime != null
                        ? fullDateFormatter.format(booking.completedTime!)
                        : 'N/A',
                  ),
                  _buildTableRow(
                    'Created At',
                    fullDateFormatter.format(booking.createdAt),
                  ),
                  _buildTableRow(
                    'Last Updated At',
                    fullDateFormatter.format(booking.lastUpdatedAt),
                  ),
                  _buildTableRow(
                    'Status',
                    _taxiAdminCubit.getDisplayName(
                        id: booking.tripStatus, type: 'status'),
                    valueColor: statusStyles['color'],
                    backgroundColor: statusStyles['backgroundColor'],
                    valueWeight: booking.tripStatus.toLowerCase() == 'pending' ||
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
                    'Taxi Type',
                    _taxiAdminCubit.getDisplayName(
                        id: booking.taxiTypeId, type: 'taxiType'),
                  ),
                  _buildTableRow(
                    'Service Type',
                    _taxiAdminCubit.getDisplayName(
                        id: booking.serviceTypeId, type: 'serviceType'),
                  ),
                  _buildTableRow(
                    'Additional Info',
                    booking.additionalInfo.isEmpty
                        ? 'None'
                        : booking.additionalInfo,
                    maxLines: 3,
                  ),
                  _buildTableRow(
                    'Trip Booking Date',
                    _taxiAdminCubit.formatTripDate(booking.tripDate),
                    backgroundColor: AppColors.highLightOrange,
                    valueColor: AppColors.red,
                    isBold: true,
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
            const SizedBox(height: 16),
            if (booking.tripStatus.toLowerCase() == 'confirmed' ||
                booking.tripStatus.toLowerCase() == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _taxiAdminCubit.acceptBooking(booking.id, null);
                      _fetchBookingDetails();
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                    await  _taxiAdminCubit.updateBookingStatus(booking.id, 'Declined');
                      _isNeedToUpdate =true;

                      _fetchBookingDetails();
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
                      _fetchBookingDetails();
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
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _taxiAdminCubit.startTrip(booking.id);
                      _fetchBookingDetails();
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
                      'Start Trip',
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
                      _fetchBookingDetails();
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
                      'Finish Trip',
                      style: TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _taxiAdminCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Booking Details',),
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
                if (state is TaxiAdminLoading || _booking == null) {
                  return const CustomLoadingDialog(message: 'Loading Booking...');
                } else if (state is TaxiAdminError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is TaxiAdminSuccess) {
                  return SingleChildScrollView(
                    child: _buildBookingDetails(_booking!, state),
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
}