import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_service.dart';
import 'package:requirment_gathering_app/taxi/visitor_counter_service.dart';

class TaxiBookingCubit extends Cubit<TaxiBookingState> {
  final ITaxiBookingService _service;
  final IVisitorCounterService _iVisitorCounterService;

  TaxiBookingCubit(this._service, this._iVisitorCounterService)
      : super(TaxiBookingInitial());

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

abstract class TaxiBookingState extends Equatable {
  const TaxiBookingState();

  @override
  List<Object> get props => [];
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
