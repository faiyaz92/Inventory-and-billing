import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';
import 'package:requirment_gathering_app/taxi/visitor_counter_service.dart';

class VisitorCounterCubit extends Cubit<VisitorCounterState> {
  final IVisitorCounterService _visitorCounterService;

  VisitorCounterCubit(this._visitorCounterService)
      : super(VisitorCounterInitial());

  Future<void> fetchVisitorCounts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(VisitorCounterLoading());
    try {
      final visitorCounts = <DateTime, VisitorCounter>{};
      final days = endDate.difference(startDate).inDays + 1;

      // Fetch visitor count for each day in the range
      for (var i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final counter = await _visitorCounterService.getVisitorCounter(dateKey);
        visitorCounts[DateTime(date.year, date.month, date.day)] = counter;
      }

      emit(VisitorCounterSuccess(
        visitorCounts: visitorCounts,
        startDate: startDate,
        endDate: endDate,
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      emit(VisitorCounterError('Failed to fetch visitor counts: ${e.toString()}'));
    }
  }
}

abstract class VisitorCounterState extends Equatable {
  const VisitorCounterState();

  @override
  List<Object> get props => [];
}

class VisitorCounterInitial extends VisitorCounterState {}

class VisitorCounterLoading extends VisitorCounterState {}

class VisitorCounterSuccess extends VisitorCounterState {
  final Map<DateTime, VisitorCounter> visitorCounts;
  final DateTime startDate;
  final DateTime endDate;
  final int timeStamp;

  const VisitorCounterSuccess({
    required this.visitorCounts,
    required this.startDate,
    required this.endDate,
    required this.timeStamp,
  });

  @override
  List<Object> get props => [
    visitorCounts,
    startDate,
    endDate,
    timeStamp,
  ];
}

class VisitorCounterError extends VisitorCounterState {
  final String message;

  const VisitorCounterError(this.message);

  @override
  List<Object> get props => [message];
}