import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';

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

  @override
  void initState() {
    super.initState();
    _taxiAdminCubit = sl<TaxiAdminCubit>();
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
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
            DropdownMenuItem(value: 'inprogress', child: Text('In Progress')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            DropdownMenuItem(value: 'declined', child: Text('Declined')),
          ],
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
              _fetchBookingDetails();
            },
            child: const Text('Update',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
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
                      final selectedDriver = state.drivers
                          .firstWhere((driver) => driver.userId == selectedDriverId);
                      _taxiAdminCubit.assignBooking(
                          booking.id, selectedDriver, booking.acceptedByDriverId);
                      Navigator.pop(context);
                      _fetchBookingDetails();
                    }
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

  Widget _buildBookingDetails(TaxiBooking booking) {
    final statusStyles = _taxiAdminCubit.getStatusColors(booking.tripStatus);
    final dateFormatter = DateFormat('MMM dd, yyyy');
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
                      icon: const Icon(Icons.person_add, color: AppColors.primary),
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
                'Trip Date: ${dateFormatter.format(booking.tripDate)}',
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
                  ),
                  _buildTableRow(
                    'Actual Start Time',
                    booking.actualStartTime != null
                        ? DateFormat('MMM dd, yyyy HH:mm')
                        .format(booking.actualStartTime!)
                        : 'N/A',
                  ),
                  _buildTableRow(
                    'Completed Time',
                    booking.completedTime != null
                        ? DateFormat('MMM dd, yyyy HH:mm')
                        .format(booking.completedTime!)
                        : 'N/A',
                  ),
                  _buildTableRow(
                    'Status',
                    booking.tripStatus,
                    valueColor: statusStyles['color'],
                    backgroundColor: statusStyles['backgroundColor'],
                    valueWeight: booking.tripStatus.toLowerCase() == 'pending' ||
                        booking.tripStatus.toLowerCase() == 'inprogress'
                        ? FontWeight.bold
                        : null,
                  ),
                  _buildTableRow(
                    'Trip Type',
                    booking.tripTypeId,
                  ),
                  _buildTableRow(
                    'Taxi Type',
                    booking.taxiTypeId,
                  ),
                  _buildTableRow(
                    'Service Type',
                    booking.serviceTypeId,
                  ),
                  _buildTableRow(
                    'Additional Info',
                    booking.additionalInfo.isEmpty
                        ? 'None'
                        : booking.additionalInfo,
                    maxLines: 3,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _taxiAdminCubit.updateBookingStatus(booking.id, 'declined');
                    _fetchBookingDetails();
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
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
              ],
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
        appBar: const CustomAppBar(title: 'Booking Details'),
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
                } else {
                  return SingleChildScrollView(
                    child: _buildBookingDetails(_booking!),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}