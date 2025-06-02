import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_service.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';

class TaxiSettingsCubit extends Cubit<TaxiSettingsState> {
  final ITaxiSettingsService _service;

  TaxiSettingsCubit(this._service) : super(TaxiSettingsInitial()) {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    emit(TaxiSettingsLoading());
    try {
      // final taxiTypes = await _service.getTaxiTypes();
      final settings = await _service.getSettings();
      emit(TaxiSettingsSuccess(settings: settings));
    } catch (e) {
      emit(TaxiSettingsError(e.toString()));
    }
  }

  Future<void> addTaxiType(TaxiType type) async {
    try {
      await _service.addTaxiType(type);
      fetchSettings();
    } catch (e) {
      emit(TaxiSettingsError(e.toString()));
    }
  }

  Future<void> deleteTaxiType(String typeId) async {
    try {
      await _service.deleteTaxiType(typeId);
      fetchSettings();
    } catch (e) {
      emit(TaxiSettingsError(e.toString()));
    }
  }

  Future<void> updateSettings(TaxiSettings settings) async {
    try {
      await _service.updateSettings(settings);
      fetchSettings();
    } catch (e) {
      emit(TaxiSettingsError(e.toString()));
    }
  }
}

abstract class TaxiSettingsState extends Equatable {
  const TaxiSettingsState();

  @override
  List<Object> get props => [];
}

class TaxiSettingsInitial extends TaxiSettingsState {}

class TaxiSettingsLoading extends TaxiSettingsState {}

class TaxiSettingsSuccess extends TaxiSettingsState {
  final TaxiSettings settings;

  const TaxiSettingsSuccess({ required this.settings});

  @override
  List<Object> get props => [settings];
}

class TaxiSettingsError extends TaxiSettingsState {
  final String message;

  const TaxiSettingsError(this.message);

  @override
  List<Object> get props => [message];
}