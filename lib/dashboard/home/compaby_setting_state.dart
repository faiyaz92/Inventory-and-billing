import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/data/company_settings.dart';

class CompanySettingState extends Equatable {
  final CompanySettingsUi settings; // Business model
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const CompanySettingState({
    required this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  // Factory for initial state
  factory CompanySettingState.initial() {
    return CompanySettingState(
      settings: CompanySettingsUi.initial(),
      isLoading: false,
      isSaving: false,
      errorMessage: null,
    );
  }

  // CopyWith method for immutability
  CompanySettingState copyWith({
    CompanySettingsUi? settings,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CompanySettingState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, isSaving, errorMessage];
}
