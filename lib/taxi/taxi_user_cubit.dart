import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_service.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';

class TaxiUserCubit extends Cubit<TaxiUserState> {
  final ITaxiBookingService _bookingService;
  final ITaxiSettingsService _settingsService;
  final AccountRepository _accountRepository;
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  late TaxiSettings _settings;

  TaxiUserCubit(
    this._bookingService,
    this._settingsService,
    this._accountRepository,
  ) : super(TaxiUserInitial());

  // Getter for settings
  TaxiSettings get settings => _settings;

  Future<void> fetchSettings() async {
    try {
      _settings = await _settingsService.getSettings();
      emit(TaxiUserInitialSettings(_settings));
    } catch (e) {
      emit(TaxiUserError('Failed to fetch settings: ${e.toString()}'));
    }
  }

  TaxiSettings getSettings() {
    return _settings;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All My Bookings';
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return 'Booked on ${_dateFormatter.format(start)}';
    }
    return 'Booked between ${_dateFormatter.format(start)} and ${_dateFormatter.format(end)}';
  }

  Map<String, List<TaxiBooking>> _groupBookingsByDate(
      List<TaxiBooking> bookings) {
    final grouped = <String, List<TaxiBooking>>{};
    for (var booking in bookings) {
      final dateKey = _dateFormatter.format(booking.tripDate);
      grouped.putIfAbsent(dateKey, () => []).add(booking);
    }
    return grouped;
  }

  String getDisplayName({
    required String? id,
    required String type,
  }) {
    if (id == null) return 'Unknown';
    switch (type) {
      case 'taxiType':
        return _settings.taxiTypes
            .firstWhere(
              (type) => type.id == id,
              orElse: () => TaxiType(
                id: '',
                name: 'Unknown',
                createdAt: DateTime.now(),
                createdBy: '',
              ),
            )
            .name;
      case 'serviceType':
        return _settings.serviceTypes
            .firstWhere(
              (type) => type.id == id,
              orElse: () => ServiceType(
                id: '',
                name: 'Unknown',
                createdAt: DateTime.now(),
                createdBy: '',
              ),
            )
            .name;
      case 'tripType':
        return _settings.tripTypes
            .firstWhere(
              (type) => type.id == id,
              orElse: () => TripType(
                id: '',
                name: 'Unknown',
                createdAt: DateTime.now(),
                createdBy: '',
              ),
            )
            .name;
      case 'status':
        return _settings.tripStatuses
            .firstWhere(
              (status) => status.id == id,
              orElse: () => TripStatus(
                id: '',
                name: 'Unknown',
                createdAt: DateTime.now(),
                createdBy: '',
              ),
            )
            .name;
      default:
        return id;
    }
  }

  Map<String, Color> getStatusColors(String status) {
    final normalizedStatus = status.toLowerCase();
    return {
      'color': normalizedStatus == 'pending'
          ? Colors.orange
          : normalizedStatus == 'inprogress'
              ? Colors.blue
              : normalizedStatus == 'confirmed'
                  ? Colors.green
                  : AppColors.textSecondary,
      'backgroundColor': normalizedStatus == 'pending'
          ? Colors.orange.withOpacity(0.1)
          : normalizedStatus == 'inprogress'
              ? Colors.blue.withOpacity(0.1)
              : normalizedStatus == 'confirmed'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.transparent,
    };
  }

  Future<void> fetchBookings({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? taxiTypeId,
    String? serviceTypeId,
    String? tripTypeId,
    double? minTotalFareAmount,
    double? maxTotalFareAmount,
  }) async {
    emit(TaxiUserLoading());
    try {
      _settings = await _settingsService.getSettings();
      final userInfo = await _accountRepository.getUserInfo();
      final userId = userInfo?.userId;
      if (userId == null) {
        emit(const TaxiUserError('User not logged in'));
        return;
      }
    final _userInfo =  await  _accountRepository.getUserInfo();
      final bookings = await _bookingService.getBookings(
        userId: _userInfo?.userId??'',
        status: status,
        startDate: startDate,
        endDate: endDate,
        taxiTypeId: taxiTypeId,
        serviceTypeId: serviceTypeId,
        tripTypeId: tripTypeId,
        minTotalFareAmount: minTotalFareAmount,
        maxTotalFareAmount: maxTotalFareAmount,
      );

      final taxiTypes = _settings.taxiTypes.map((type) => type.name).toList();
      final serviceTypes =
          _settings.serviceTypes.map((type) => type.name).toList();
      final tripTypes = _settings.tripTypes.map((type) => type.name).toList();
      final statuses =
          _settings.tripStatuses.map((status) => status.name).toList();

      List<TaxiBooking> filteredBookings = bookings;

      if (startDate != null && endDate != null) {
        filteredBookings = filteredBookings.where((booking) {
          return booking.createdAt.isAfter(startDate) &&
              booking.createdAt.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }

      if (status != null) {
        filteredBookings = filteredBookings
            .where((booking) =>
                booking.tripStatus.toLowerCase() == status.toLowerCase())
            .toList();
      }

      if (taxiTypeId != null) {
        filteredBookings = filteredBookings
            .where((booking) => booking.taxiTypeId == taxiTypeId)
            .toList();
      }

      if (serviceTypeId != null) {
        filteredBookings = filteredBookings
            .where((booking) => booking.serviceTypeId == serviceTypeId)
            .toList();
      }

      if (tripTypeId != null) {
        filteredBookings = filteredBookings
            .where((booking) => booking.tripTypeId == tripTypeId)
            .toList();
      }

      if (minTotalFareAmount != null && maxTotalFareAmount != null) {
        filteredBookings = filteredBookings
            .where((booking) =>
                booking.totalFareAmount >= minTotalFareAmount &&
                booking.totalFareAmount <= maxTotalFareAmount)
            .toList();
      } else if (minTotalFareAmount != null) {
        filteredBookings = filteredBookings
            .where((booking) => booking.totalFareAmount >= minTotalFareAmount)
            .toList();
      }

      filteredBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(TaxiUserSuccess(
        bookings: filteredBookings,
        taxiTypes: taxiTypes,
        serviceTypes: serviceTypes,
        tripTypes: tripTypes,
        statuses: statuses,
        startDate: startDate,
        endDate: endDate,
        status: status,
        taxiTypeId: taxiTypeId,
        serviceTypeId: serviceTypeId,
        tripTypeId: tripTypeId,
        minTotalFareAmount: minTotalFareAmount,
        maxTotalFareAmount: maxTotalFareAmount,
        groupedBookings: _groupBookingsByDate(filteredBookings),
        dateRangeLabel: _formatDateRange(startDate, endDate),
        currentLoggedInUserId: userId,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      emit(TaxiUserError('Failed to fetch bookings: ${e.toString()}'));
    }
  }

  String formatTripDate(DateTime tripDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    String day = tripDate.day.toString().padLeft(2, '0');
    String month = tripDate.month.toString().padLeft(2, '0');
    String year = tripDate.year.toString();
    String formattedDate = '$day-$month-$year';

    if (tripDate.year == today.year &&
        tripDate.month == today.month &&
        tripDate.day == today.day) {
      return "Today, $formattedDate";
    } else if (tripDate.year == tomorrow.year &&
        tripDate.month == tomorrow.month &&
        tripDate.day == tomorrow.day) {
      return "Tomorrow, $formattedDate";
    } else {
      return formattedDate;
    }
  }
}

abstract class TaxiUserState extends Equatable {
  const TaxiUserState();

  @override
  List<Object> get props => [];
}

class TaxiUserInitial extends TaxiUserState {}

class TaxiUserInitialSettings extends TaxiUserState {
  final TaxiSettings settings;

  const TaxiUserInitialSettings(this.settings);

  @override
  List<Object> get props => [settings];
}

class TaxiUserLoading extends TaxiUserState {}

class TaxiUserSuccess extends TaxiUserState {
  final List<TaxiBooking> bookings;
  final List<String> taxiTypes;
  final List<String> serviceTypes;
  final List<String> tripTypes;
  final List<String> statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? taxiTypeId;
  final String? serviceTypeId;
  final String? tripTypeId;
  final double? minTotalFareAmount;
  final double? maxTotalFareAmount;
  final Map<String, List<TaxiBooking>> groupedBookings;
  final String dateRangeLabel;
  final String currentLoggedInUserId;
  final int timeStamp;

  const TaxiUserSuccess({
    required this.bookings,
    required this.taxiTypes,
    required this.serviceTypes,
    required this.tripTypes,
    required this.statuses,
    this.startDate,
    this.endDate,
    this.status,
    this.taxiTypeId,
    this.serviceTypeId,
    this.tripTypeId,
    this.minTotalFareAmount,
    this.maxTotalFareAmount,
    required this.groupedBookings,
    required this.dateRangeLabel,
    required this.currentLoggedInUserId,
    required this.timeStamp,
  });

  @override
  List<Object> get props => [
        bookings,
        taxiTypes,
        serviceTypes,
        tripTypes,
        statuses,
        startDate ?? Object(),
        endDate ?? Object(),
        status ?? '',
        taxiTypeId ?? '',
        serviceTypeId ?? '',
        tripTypeId ?? '',
        minTotalFareAmount ?? 0.0,
        maxTotalFareAmount ?? double.infinity,
        groupedBookings,
        dateRangeLabel,
        currentLoggedInUserId,
        timeStamp,
      ];
}

class TaxiUserError extends TaxiUserState {
  final String message;

  const TaxiUserError(this.message);

  @override
  List<Object> get props => [message];
}
