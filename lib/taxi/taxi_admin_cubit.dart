import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service.dart';

class TaxiAdminCubit extends Cubit<TaxiAdminState> {
  final ITaxiBookingService _service;

  TaxiAdminCubit(this._service) : super(TaxiAdminInitial()) {
    fetchBookings();
  }

  Future<void> fetchBookings({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(TaxiAdminLoading());
    try {
      final bookings = await _service.getBookings(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final visitorCounter = await _service.getVisitorCounter(todayKey);
      emit(TaxiAdminSuccess(
        bookings: bookings,
        todayVisitorCount: visitorCounter.count,
      ));
    } catch (e) {
      emit(TaxiAdminError(e.toString()));
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (state is TaxiAdminSuccess) {
      emit(TaxiAdminLoading());
      try {
        await _service.updateBookingStatus(bookingId, status);
        await fetchBookings(); // Refresh bookings
      } catch (e) {
        emit(TaxiAdminError(e.toString()));
      }
    }
  }

  Future<void> acceptBooking(String bookingId, UserInfo driver) async {
    if (state is TaxiAdminSuccess) {
      emit(TaxiAdminLoading());
      try {
        await _service.acceptBooking(bookingId, driver);
        await fetchBookings(); // Refresh bookings
      } catch (e) {
        emit(TaxiAdminError(e.toString()));
      }
    }
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
  final int todayVisitorCount;

  const TaxiAdminSuccess({
    required this.bookings,
    required this.todayVisitorCount,
  });

  @override
  List<Object> get props => [bookings, todayVisitorCount];
}

class TaxiAdminError extends TaxiAdminState {
  final String message;

  const TaxiAdminError(this.message);

  @override
  List<Object> get props => [message];
}