import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_settings/compaby_setting_state.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class CompanySettingCubit extends Cubit<CompanySettingState> {
  final CustomerCompanyService _companyService;

  CompanySettingCubit(this._companyService) : super(CompanySettingState.initial());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _companyService.getSettings();
      result.fold(
        (error) {
          // Handle the error and update the UI state
          emit(state.copyWith(
            isLoading: false,
            errorMessage: "Failed to load settings: $error",
          ));
        },
        (settings) {
          // Handle the success case and update the state with the settings
          emit(state.copyWith(settings: settings, isLoading: false));
        },
      );
    } catch (e) {
      // General catch for any unexpected errors
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Unexpected error: $e",
      ));
    }
  }

  Future<void> addSource(String source, BuildContext context) async {
    if (state.settings.sources.contains(source)) {
      _showSnackbar(context, "Source '$source' already exists.");
      return;
    }
    final updatedSources = List<String>.from(state.settings.sources)
      ..add(source);
    await _updateSettings(state.settings.copyWith(sources: updatedSources));
  }

  Future<void> removeSource(String source) async {
    final updatedSources = List<String>.from(state.settings.sources)
      ..remove(source);
    await _updateSettings(state.settings.copyWith(sources: updatedSources));
  }

  Future<void> addPriority(String priority, BuildContext context) async {
    if (state.settings.priorities.contains(priority)) {
      _showSnackbar(context, "Priority '$priority' already exists.");
      return;
    }
    final updatedPriorities = List<String>.from(state.settings.priorities)
      ..add(priority);
    await _updateSettings(
        state.settings.copyWith(priorities: updatedPriorities));
  }

  Future<void> removePriority(String priority) async {
    final updatedPriorities = List<String>.from(state.settings.priorities)
      ..remove(priority);
    await _updateSettings(
        state.settings.copyWith(priorities: updatedPriorities));
  }

  Future<void> addVerifiedOn(String platform, BuildContext context) async {
    if (state.settings.verifiedOn.contains(platform)) {
      _showSnackbar(context, "Platform '$platform' already exists.");
      return;
    }
    final updatedVerifiedOn = List<String>.from(state.settings.verifiedOn)
      ..add(platform);
    await _updateSettings(
        state.settings.copyWith(verifiedOn: updatedVerifiedOn));
  }

  Future<void> removeVerifiedOn(String platform) async {
    final updatedVerifiedOn = List<String>.from(state.settings.verifiedOn)
      ..remove(platform);
    await _updateSettings(
        state.settings.copyWith(verifiedOn: updatedVerifiedOn));
  }

  Future<void> addCountry(String country, BuildContext context) async {
    if (state.settings.countryCityMap.containsKey(country)) {
      _showSnackbar(context, "Country '$country' already exists.");
      return;
    }
    final updatedMap =
        Map<String, List<String>>.from(state.settings.countryCityMap)
          ..putIfAbsent(country, () => []);
    await _updateSettings(state.settings.copyWith(countryCityMap: updatedMap));
  }

  Future<void> removeCountry(String country) async {
    final updatedMap =
        Map<String, List<String>>.from(state.settings.countryCityMap)
          ..remove(country);
    await _updateSettings(state.settings.copyWith(countryCityMap: updatedMap));
  }

  Future<void> editCountry(
      String oldCountry, String newCountry, BuildContext context) async {
    if (state.settings.countryCityMap.containsKey(newCountry)) {
      _showSnackbar(context, "Country '$newCountry' already exists.");
      return;
    }
    final updatedMap =
        Map<String, List<String>>.from(state.settings.countryCityMap);
    if (updatedMap.containsKey(oldCountry)) {
      updatedMap[newCountry] = updatedMap.remove(oldCountry)!;
    }
    await _updateSettings(state.settings.copyWith(countryCityMap: updatedMap));
  }

  Future<void> addCity(
      String country, String city, BuildContext context) async {
    if (state.settings.countryCityMap[country]?.contains(city) ?? false) {
      _showSnackbar(context, "City '$city' already exists in '$country'.");
      return;
    }
    final updatedMap =
        Map<String, List<String>>.from(state.settings.countryCityMap);
    updatedMap[country]?.add(city);
    await _updateSettings(state.settings.copyWith(countryCityMap: updatedMap));
  }

  Future<void> removeCity(String country, String city) async {
    final updatedMap =
        Map<String, List<String>>.from(state.settings.countryCityMap);
    updatedMap[country]?.remove(city);
    await _updateSettings(state.settings.copyWith(countryCityMap: updatedMap));
  }

  Future<void> _updateSettings(CompanySettingsUi updatedSettings) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _companyService.updateSettings(updatedSettings);
      emit(state.copyWith(settings: updatedSettings, isSaving: false));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: "Failed to update settings: $e",
      ));
    }
  }

// Add Business Type
  Future<void> addBusinessType(
      String businessType, BuildContext context) async {
    if (state.settings.businessTypes.contains(businessType)) {
      _showSnackbar(context, "Business Type '$businessType' already exists.");
      return;
    }
    final updatedBusinessTypes = List<String>.from(state.settings.businessTypes)
      ..add(businessType);
    await _updateSettings(
        state.settings.copyWith(businessTypes: updatedBusinessTypes));
  }

  // Remove Business Type
  Future<void> removeBusinessType(String businessType) async {
    final updatedBusinessTypes = List<String>.from(state.settings.businessTypes)
      ..remove(businessType);
    await _updateSettings(
        state.settings.copyWith(businessTypes: updatedBusinessTypes));
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  /// 🔹 Add Task Status
  Future<void> addTaskStatus(String status, BuildContext context) async {
    if (state.settings.taskStatuses.contains(status)) {
      _showSnackbar(context, "Task Status '$status' already exists.");
      return;
    }
    final updatedStatuses = List<String>.from(state.settings.taskStatuses)
      ..add(status);
    await _updateSettings(state.settings.copyWith(taskStatuses: updatedStatuses));
  }

  /// 🔹 Remove Task Status
  Future<void> removeTaskStatus(String status) async {
    final updatedStatuses = List<String>.from(state.settings.taskStatuses)
      ..remove(status);
    await _updateSettings(state.settings.copyWith(taskStatuses: updatedStatuses));
  }

}
