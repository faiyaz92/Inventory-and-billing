import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';

class TaxiAdminCubit extends Cubit<TaxiAdminState> {
  final ITaxiBookingService _service;
  final UserServices _userServices;
  final TaxiSettingsCubit settingsCubit;
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _fullDateFormatter = DateFormat('yyyy-MM-dd HH:mm');
  final AccountRepository _accountRepository;

  TaxiAdminCubit(this._service, this._userServices, this.settingsCubit,
      this._accountRepository)
      : super(TaxiAdminInitial()) {
    // fetchBookings();
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Bookings';
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return 'Booked on ${_dateFormatter.format(start)}';
    }
    return 'Booked between ${_dateFormatter.format(start)} and ${_dateFormatter.format(end)}';
  }

  String formatBookingDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  bool _shouldShowTodayStats(DateTime? start, DateTime? end) {
    if (start == null || end == null) return true;
    final today = DateTime.now();
    return start.year == today.year &&
        start.month == today.month &&
        start.day == today.day &&
        end.year == today.year &&
        end.month == today.month &&
        end.day == today.day;
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

  List<Map<String, dynamic>> _computeStatistics(
      List<TaxiBooking> bookings, bool showTodayStats) {
    final totalBookings = bookings.length;
    final totalFare = bookings.fold<double>(
        0.0, (sum, booking) => sum + booking.totalFareAmount);
    final newBookings =
        bookings.where((booking) => _isToday(booking.createdAt)).length;
    final settingsState = settingsCubit.state;
    final statusCounts = <String, int>{};
    for (var status in settingsState.tripStatuses) {
      statusCounts[status.id] = bookings
          .where((booking) =>
              booking.tripStatus.toLowerCase() == status.id.toLowerCase())
          .length;
    }
    final todayTripCount =
        bookings.where((booking) => _isToday(booking.tripDate)).length;
    final todayCompletedTripCount = bookings
        .where((booking) =>
            booking.tripStatus.toLowerCase() == 'completed' &&
            _isToday(booking.completedTime))
        .length;

    final statistics = [
      {
        'label': 'Total Bookings',
        'value': totalBookings.toString(),
        'color': AppColors.textPrimary,
        'highlight': true
      },
      {
        'label': 'Total Fare',
        'value': '\$${totalFare.toStringAsFixed(2)}',
        'color': AppColors.textPrimary,
        'highlight': true
      },
      ...settingsState.tripStatuses.map((status) {
        final count = statusCounts[status.id] ?? 0;
        return {
          'label': status.name,
          'value': count.toString(),
          'color': getStatusColors(status.id)['color'],
          'highlight': status.id.toLowerCase() == 'pending' ||
              status.id.toLowerCase() == 'inprogress'
        };
      }).toList(),
      if (showTodayStats)
        {
          'label': "Today's Bookings",
          'value': newBookings.toString(),
          'color': Colors.green,
          'highlight': true
        },
      {
        'label': "Today's Trips",
        'value': todayTripCount.toString(),
        'color': AppColors.textSecondary,
        'highlight': false
      },
      {
        'label': "Today's Completed",
        'value': todayCompletedTripCount.toString(),
        'color': AppColors.textSecondary,
        'highlight': true
      },
    ];

    return statistics;
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

  String? getDriverNameById(String? driverId, List<UserInfo> drivers) {
    if (driverId == null || driverId.isEmpty) return null;
    return drivers
            .firstWhere(
              (driver) => driver.userId == driverId,
              orElse: () => UserInfo(userId: driverId, userName: 'Unknown'),
            )
            .userName ??
        'Unknown';
  }

  String getDisplayName({
    required String? id,
    required String type, // 'taxiType', 'serviceType', 'tripType', or 'status'
  }) {
    final settingsState = settingsCubit.state;
    if (id == null) return 'Unknown';

    switch (type) {
      case 'taxiType':
        return settingsState.taxiTypes
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
        return settingsState.serviceTypes
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
        return settingsState.tripTypes
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
        return settingsState.tripStatuses
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

  Future<void> fetchBookings({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? taxiTypeId,
    String? serviceTypeId,
    String? tripTypeId,
    String? acceptedByDriverId,
    double? minTotalFareAmount,
    double? maxTotalFareAmount,
  }) async {
    emit(TaxiAdminLoading());
    try {
      final bookings = await _service.getBookings(
        status: status,
        startDate: startDate,
        endDate: endDate,
        taxiTypeId: taxiTypeId,
        serviceTypeId: serviceTypeId,
        tripTypeId: tripTypeId,
        acceptedByDriverId: acceptedByDriverId,
        minTotalFareAmount: minTotalFareAmount,
        maxTotalFareAmount: maxTotalFareAmount,
      );
      final drivers = await _userServices.getUsersFromTenantCompany();
      final today = DateTime.now();
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final visitorCounter = await _service.getVisitorCounter(todayKey);

      // Fetch type lists from TaxiSettingsCubit
      final settingsState = settingsCubit.state;
      final taxiTypes =
          settingsState.taxiTypes.map((type) => type.name).toList();
      final serviceTypes =
          settingsState.serviceTypes.map((type) => type.name).toList();
      final tripTypes =
          settingsState.tripTypes.map((type) => type.name).toList();
      final statuses =
          settingsState.tripStatuses.map((status) => status.name).toList();

      // bookings.sort((a, b) => b.tripDate.compareTo(a.tripDate));
      List<TaxiBooking> filteredBookings = bookings;

      if (startDate != null && endDate != null) {
        filteredBookings = filteredBookings.where((booking) {
          return booking.createdAt
                  .isAfter(startDate /*.subtract(const Duration(days: 1))*/) &&
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

      if (acceptedByDriverId != null) {
        filteredBookings = filteredBookings
            .where(
                (booking) => booking.acceptedByDriverId == acceptedByDriverId)
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

      final showTodayStats = _shouldShowTodayStats(startDate, endDate);
      // emit(TaxiAdminInitial());
      final userInfo = await _accountRepository.getUserInfo();
      emit(TaxiAdminSuccess(
          bookings: filteredBookings,
          drivers: drivers,
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
          acceptedByDriverId: acceptedByDriverId,
          minTotalFareAmount: minTotalFareAmount,
          maxTotalFareAmount: maxTotalFareAmount,
          todayVisitorCount: visitorCounter.count,
          groupedBookings: _groupBookingsByDate(filteredBookings),
          dateRangeLabel: _formatDateRange(startDate, endDate),
          statistics: _computeStatistics(filteredBookings, showTodayStats),
          showTodayStats: showTodayStats,
          currentLoggedInUserId: userInfo?.userId ?? '',
          timeStamp: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      emit(TaxiAdminError('Failed to fetch bookings: ${e.toString()}'));
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (state is TaxiAdminSuccess) {
      emit(TaxiAdminLoading());
      try {
        await _service.updateBookingStatus(bookingId, status);
        if (status.toLowerCase() == 'pending' ||
            status.toLowerCase() == 'confirmed') {
          await _service.unAssignBooking(bookingId);
        }
        await fetchBookings(); // Refresh bookings
      } catch (e) {
        emit(
            TaxiAdminError('Failed to update booking status: ${e.toString()}'));
      }
    }
  }

  Future<void> acceptBooking(String bookingId, UserInfo? driver) async {
    if (state is TaxiAdminSuccess) {
      emit(TaxiAdminLoading());
      try {
        await _service.acceptBooking(bookingId, driver);
        await fetchBookings(); // Refresh bookings
      } catch (e) {
        emit(TaxiAdminError('Failed to accept booking: ${e.toString()}'));
      }
    }
  }

  Future<void> assignBooking(String bookingId, UserInfo driver,
      String? currentAcceptedByDriverId) async {
    if (state is TaxiAdminSuccess) {
      emit(TaxiAdminLoading());
      try {
        await _service.assignBooking(
            bookingId, driver, currentAcceptedByDriverId);
        await fetchBookings(); // Refresh bookings
      } catch (e) {
        emit(TaxiAdminError('Failed to assign booking: ${e.toString()}'));
      }
    }
  }

  Future<TaxiBooking?> fetchBookingById(String bookingId) async {
    try {
      final bookings = await _service.getBookings(bookingId: bookingId);
      if (bookings.isNotEmpty) {
        return bookings.first;
      }
      return null;
    } catch (e) {
      emit(TaxiAdminError('Failed to fetch booking: ${e.toString()}'));
      return null;
    }
  }

  Future<void> unAssignedBooking(String id) async {
    emit(TaxiAdminLoading());
    await _service.unAssignBooking(id);
    fetchBookings();
  }

  Future<void> startTrip(String id) async {
    emit(TaxiAdminLoading());
    await _service.updateBookingStatus(id, 'In-progress');
    await _service.updateBookingStartTime(id);
    fetchBookings();
  }

  Future<void> finishTrip(String id) async {
    emit(TaxiAdminLoading());
    await _service.updateBookingStatus(id, 'Completed');
    await _service.updateBookingCompletedTime(id);
    fetchBookings();
  }
}

abstract class TaxiAdminState extends Equatable {
  const TaxiAdminState();

  @override
  List<Object> get props => [];
}

class TaxiAdminInitial extends TaxiAdminState {}

class TaxiAdminLoading extends TaxiAdminState {}

class TaxiAdminSuccess extends TaxiAdminState {
  final List<TaxiBooking> bookings;
  final List<UserInfo> drivers;
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
  final String? acceptedByDriverId;
  final double? minTotalFareAmount;
  final double? maxTotalFareAmount;
  final int todayVisitorCount;
  final Map<String, List<TaxiBooking>> groupedBookings;
  final String dateRangeLabel;
  final List<Map<String, dynamic>> statistics;
  final bool showTodayStats;
  final int timeStamp;
  final String currentLoggedInUserId;

  const TaxiAdminSuccess({
    required this.bookings,
    required this.drivers,
    required this.taxiTypes,
    required this.serviceTypes,
    required this.tripTypes,
    required this.statuses,
    this.timeStamp = 0,
    this.startDate,
    this.endDate,
    this.status,
    this.taxiTypeId,
    this.serviceTypeId,
    this.tripTypeId,
    this.acceptedByDriverId,
    this.minTotalFareAmount,
    this.maxTotalFareAmount,
    required this.todayVisitorCount,
    required this.groupedBookings,
    required this.dateRangeLabel,
    required this.statistics,
    required this.showTodayStats,
    required this.currentLoggedInUserId,
  });

  @override
  List<Object> get props => [
        bookings,
        drivers,
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
        acceptedByDriverId ?? '',
        minTotalFareAmount ?? 0.0,
        maxTotalFareAmount ?? double.infinity,
        todayVisitorCount,
        groupedBookings,
        dateRangeLabel,
        statistics,
        showTodayStats,
        timeStamp,
        currentLoggedInUserId
      ];
}

class TaxiAdminError extends TaxiAdminState {
  final String message;

  const TaxiAdminError(this.message);

  @override
  List<Object> get props => [message];
}
