import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class TaxiBookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const TaxiBookingDetailsPage({super.key, required this.bookingId});

  @override
  State<TaxiBookingDetailsPage> createState() => _TaxiBookingDetailsPageState();
}

class _TaxiBookingDetailsPageState extends State<TaxiBookingDetailsPage> {
  final TaxiAdminCubit _taxiAdminCubit = sl<TaxiAdminCubit>();
  bool _isLoading = true;
  bool _isUpdated = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    await _taxiAdminCubit.fetchSettings();
    await _fetchBookingDetails();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBookingDetails() async {
    await _taxiAdminCubit.fetchBookingById(widget.bookingId);
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildBookingDetails(TaxiBooking booking, TaxiAdminState state) {
    final statusStyles = _taxiAdminCubit.getStatusColors(booking.tripStatus);
    final isAdminSuccess = state is TaxiAdminSuccess;
    final currentLoggedInUserId = isAdminSuccess
        ? state.currentLoggedInUserId
        : (state is TaxiAdminSingleBookingSuccess
            ? state.currentLoggedInUserId
            : '');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(width: 8),
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
                      Text(
                        'Email: ${booking.email.isNotEmpty ? booking.email : "N/A"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Passengers: ${booking.passengerNumbers}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Additional Info: ${booking.additionalInfo.isNotEmpty ? booking.additionalInfo : "None"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
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
                      'Time',
                      booking.tripStartTime,
                      isBold: true,
                      valueColor: AppColors.red,
                      backgroundColor: AppColors.highLightOrange,
                    ),
                    _buildTableRow(
                      'Trip Booking Date',
                      _taxiAdminCubit.formatTripDate(booking.tripDate),
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
            const SizedBox(height: 8),
            if (booking.tripStatus.toLowerCase() == 'confirmed' ||
                booking.tripStatus.toLowerCase() == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _taxiAdminCubit.updateBookingStatus(
                          booking.id, 'Declined');
                      setState(() {
                        _isUpdated = true;
                      });
                      await _fetchBookingDetails();
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
                    onPressed: () async {
                      await _taxiAdminCubit.acceptBookingFromPage(
                          booking.id, null);
                      setState(() {
                        _isUpdated = true;
                      });
                      await _fetchBookingDetails();
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
                currentLoggedInUserId == booking.acceptedByDriverId)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _taxiAdminCubit.unAssignedBooking(booking.id);
                      setState(() {
                        _isUpdated = true;
                      });
                      await _fetchBookingDetails();
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
                      setState(() {
                        _isUpdated = true;
                      });
                      await _fetchBookingDetails();
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
                currentLoggedInUserId == booking.acceptedByDriverId)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await _taxiAdminCubit.finishTrip(booking.id);
                    setState(() {
                      _isUpdated = true;
                    });
                    await _fetchBookingDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _showStatusDialog(TaxiBooking booking) {
    print('Booking tripStatus: ${booking.tripStatus}');
    print(
        'TripStatuses: ${_taxiAdminCubit.getSettings().tripStatuses.map((s) => "${s.id}: ${s.name}").toList()}');

    final tripStatuses = _taxiAdminCubit.getSettings().tripStatuses;
    final uniqueStatuses = <String, TripStatus>{};
    for (var status in tripStatuses) {
      uniqueStatuses[status.id] = status;
    }
    final statusList = uniqueStatuses.values.toList();

    String? initialStatus = booking.tripStatus;
    if (!statusList.any((status) => status.id == initialStatus)) {
      initialStatus = statusList.isNotEmpty ? statusList.first.id : null;
      print(
          'Warning: booking.tripStatus (${booking.tripStatus}) not found, using $initialStatus');
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
                  : () async {
                Navigator.pop(context);

                await _taxiAdminCubit.updateBookingStatus(
                          booking.id, initialStatus!);
                      if (mounted) {
                        setState(() {
                          _isUpdated = true;
                        });
                        await _fetchBookingDetails();
                      }

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
          if (state is TaxiAdminSingleBookingSuccess) {
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
                  onPressed: () async {
                    if (selectedDriverId != null) {
                      final selectedDriver = state.drivers.firstWhere(
                          (driver) => driver.userId == selectedDriverId);
                      await _taxiAdminCubit.assignBooking(booking.id,
                          selectedDriver, booking.acceptedByDriverId);
                      if (mounted) {
                        setState(() {
                          _isUpdated = true;
                        });
                        await _fetchBookingDetails();
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Assign',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            );
          }
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Unable to load drivers'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  int backCount = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () async {
      //   sl<Coordinator>().navigateBack(isUpdated : _isUpdated);
      //   return true;
      // },

      onWillPop: () async {
        // Close any open dialogs
        // if (Navigator.of(context).canPop()) {
        //   // sl<Coordinator>().navigateBack();
        // return true;
        // }

        if (backCount == 0) {
          backCount++;
          sl<Coordinator>().navigateBack(isUpdated: _isUpdated);
          return true;
        }
        // Perform lightweight navigation
        // Navigator.pop(context, _isUpdated); // Pass _isUpdated to previous screen
        return true;
      },
      child: BlocProvider.value(
        value: _taxiAdminCubit,
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Booking Details',
            // onBack: () {
            //   sl<Coordinator>().navigateBack(isUpdated: _isUpdated);
            // },
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
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
              child: BlocListener<TaxiAdminCubit, TaxiAdminState>(
                listener: (context, state) {
                  if (state is TaxiAdminError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.message}')),
                    );
                  }
                },
                child: BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
                  builder: (context, state) {
                    print('BlocBuilder state: $state');
                    if (_isLoading || state is TaxiAdminLoading) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: const CustomLoadingDialog(
                                  message: 'Loading...'),
                            ),
                          );
                        },
                      );
                    } else if (state is TaxiAdminError) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Error: ${state.message}',
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _initializeData,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is TaxiAdminSingleBookingSuccess) {
                      return SingleChildScrollView(
                        child: _buildBookingDetails(state.booking, state),
                      );
                    } else if (state is TaxiAdminSuccess) {
                      final booking = state.bookings.firstWhere(
                        (b) => b.id == widget.bookingId,
                        orElse: () => TaxiBooking(
                          id: '',
                          firstName: '',
                          lastName: '',
                          email: '',
                          countryCode: '',
                          mobileNumber: '',
                          pickupAddress: '',
                          dropAddress: '',
                          tripStartTime: '',
                          passengerNumbers: 0,
                          totalFareAmount: 0.0,
                          tripStatus: '',
                          tripTypeId: '',
                          taxiTypeId: '',
                          serviceTypeId: '',
                          additionalInfo: '',
                          tripDate: DateTime.now(),
                          createdAt: DateTime.now(),
                          lastUpdatedAt: DateTime.now(),
                          accepted: false,
                          lastUpdatedBy: '',
                        ),
                      );
                      if (booking.id.isNotEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight),
                                child: _buildBookingDetails(booking, state),
                              ),
                            );
                          },
                        );
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: const Center(
                                child: Text(
                                  'Booking not found',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: const Center(
                              child: Text(
                                'Unable to load booking details',
                                style: TextStyle(
                                    color: AppColors.textPrimary, fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
