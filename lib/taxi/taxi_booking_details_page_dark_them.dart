import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';

@RoutePage()
class TaxiBookingDetailsDarkPage extends StatefulWidget {
  final String bookingId;

  const TaxiBookingDetailsDarkPage({super.key, required this.bookingId});

  @override
  State<TaxiBookingDetailsDarkPage> createState() => _TaxiBookingDetailsDarkPageState();
}

class _TaxiBookingDetailsDarkPageState extends State<TaxiBookingDetailsDarkPage> {
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
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Column(
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
                        Text(
                          'Email: ${booking.email.isNotEmpty ? booking.email : "N/A"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'Passengers: ${booking.passengerNumbers}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'Additional Info: ${booking.additionalInfo.isNotEmpty ? booking.additionalInfo : "None"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    valueWeight:
                        booking.tripStatus.toLowerCase() == 'pending' ||
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
                    onPressed: () async {
                      await _taxiAdminCubit.updateBookingStatus(
                          booking.id, 'Declined');
                      setState(() {
                        _isUpdated = true;
                      });
                      await _fetchBookingDetails();
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await _taxiAdminCubit.startTrip(booking.id);
                      setState(() {
                        _isUpdated = true;
                      });
                      await _fetchBookingDetails();
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Update Status',
            style: TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: statusList.isEmpty
              ? const Text(
                  'No trip statuses available',
                  style: TextStyle(color: Color(0xFF6B7280)),
                )
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
                            child: Text(
                              status.name,
                              style: const TextStyle(color: Color(0xFF333333)),
                            ),
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
                  : () async {
                      await _taxiAdminCubit.updateBookingStatus(
                          booking.id, initialStatus!);
                      if (mounted) {
                        setState(() {
                          _isUpdated = true;
                        });
                        await _fetchBookingDetails();
                      }
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
          if (state is TaxiAdminSingleBookingSuccess ||
              state is TaxiAdminSuccess) {
            final drivers = state is TaxiAdminSingleBookingSuccess
                ? state.drivers
                : (state as TaxiAdminSuccess).drivers;
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Assign Driver',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
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
                items: drivers
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
                  onPressed: () async {
                    if (selectedDriverId != null) {
                      final selectedDriver = drivers.firstWhere(
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
                  child: const Text(
                    'Assign',
                    style: TextStyle(color: Color(0xFF007BFF)),
                  ),
                ),
              ],
            );
          }
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              'Error',
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Unable to load drivers',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
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
      onWillPop: () async {
        if (backCount == 0) {
          backCount++;
          sl<Coordinator>().navigateBack(isUpdated: _isUpdated);
          return false;
        }
        return true;
      },
      child: BlocProvider.value(
        value: _taxiAdminCubit,
        child: Scaffold(
          appBar: const CustomAppBar(
            title: 'Booking Details',
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFFF5F7FA),
            child: SafeArea(
              child: BlocListener<TaxiAdminCubit, TaxiAdminState>(
                listener: (context, state) {
                  if (state is TaxiAdminError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: const Color(0xFFDC3545),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                child: BlocBuilder<TaxiAdminCubit, TaxiAdminState>(
                  builder: (context, state) {
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
                                        color: Color(0xFF6B7280),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _initializeData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF007BFF),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
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
                                      color: Color(0xFF6B7280), fontSize: 16),
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
                                    color: Color(0xFF6B7280), fontSize: 16),
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
