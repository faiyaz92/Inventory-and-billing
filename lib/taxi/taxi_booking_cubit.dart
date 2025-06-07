

// Updated TaxiBookingCubit to manage UI state
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service.dart';
import 'package:requirment_gathering_app/taxi/visitor_counter_service.dart';

class TaxiBookingCubit extends Cubit<TaxiBookingState> {
  final ITaxiBookingService _service;
  final IVisitorCounterService _iVisitorCounterService;

  TaxiBookingCubit(this._service, this._iVisitorCounterService)
      : super(TaxiBookingInitial());

  void updateTaxiTypeId(String? taxiTypeId) {
    emit(state.copyWith(taxiTypeId: taxiTypeId));
  }

  void updateTripTypeId(String? tripTypeId) {
    emit(state.copyWith(tripTypeId: tripTypeId));
  }

  void updateServiceTypeId(String? serviceTypeId) {
    emit(state.copyWith(serviceTypeId: serviceTypeId));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(tripDate: date));
  }

  void updateStartTime(String startTime) {
    emit(state.copyWith(tripStartTime: startTime));
  }

  void reset() {
    emit(TaxiBookingInitial());
  }

  Future<void> createBooking(TaxiBooking booking) async {
    emit(TaxiBookingLoading());
    try {
      await _service.createBooking(booking);
      await _iVisitorCounterService
          .updateVisitorCounter(DateTime.now().toIso8601String().split('T')[0]);
      emit(TaxiBookingSuccess());
    } catch (e) {
      emit(TaxiBookingError(e.toString()));
    }
  }
}

// Updated TaxiBookingState to hold UI state
class TaxiBookingState extends Equatable {
  final String? taxiTypeId;
  final String? tripTypeId;
  final String? serviceTypeId;
  final DateTime? tripDate;
  final String? tripStartTime;

  const TaxiBookingState({
    this.taxiTypeId,
    this.tripTypeId,
    this.serviceTypeId,
    this.tripDate,
    this.tripStartTime,
  });

  TaxiBookingState copyWith({
    String? taxiTypeId,
    String? tripTypeId,
    String? serviceTypeId,
    DateTime? tripDate,
    String? tripStartTime,
  }) {
    return TaxiBookingState(
      taxiTypeId: taxiTypeId ?? this.taxiTypeId,
      tripTypeId: tripTypeId ?? this.tripTypeId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      tripDate: tripDate ?? this.tripDate,
      tripStartTime: tripStartTime ?? this.tripStartTime,
    );
  }

  @override
  List<Object?> get props =>
      [taxiTypeId, tripTypeId, serviceTypeId, tripDate, tripStartTime];
}

class TaxiBookingInitial extends TaxiBookingState {}

class TaxiBookingLoading extends TaxiBookingState {}

class TaxiBookingSuccess extends TaxiBookingState {}

class TaxiBookingError extends TaxiBookingState {
  final String message;

  const TaxiBookingError(this.message);

  @override
  List<Object> get props => [message];
}