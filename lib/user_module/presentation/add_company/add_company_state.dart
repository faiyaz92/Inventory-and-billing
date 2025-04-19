import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyDataState extends CompanyState {
  final Partner? company;
  final CompanySettingsUi? settings;
  final List<UserInfo> users;
  final bool isFilterVisible;
  final String? selectedYear;
  final String? selectedPeriod1;
  final String? selectedPeriod2;
  final String? selectedYearForFollowUp;
  final String? selectedYearForProgress;

  const CompanyDataState({
    this.company,
    this.settings,
    this.users = const [],
    this.isFilterVisible = false,
    this.selectedYear,
    this.selectedPeriod1,
    this.selectedPeriod2,
    this.selectedYearForFollowUp,
    this.selectedYearForProgress,
  });

  factory CompanyDataState.initial({Partner? company}) => CompanyDataState(
        company: company ??
            Partner(
              companyName: '',
              companyType: 'Site',
              dateCreated: DateTime.now(),
              contactPersons: [],
              verifiedOn: [],
              id: '',
              createdBy: '',
              lastUpdatedBy: '',
            ),
        settings: null,
        users: const [],
      );

  CompanyDataState copyWith({
    Partner? company,
    CompanySettingsUi? settings,
    List<UserInfo>? users,
    bool? isFilterVisible,
    String? selectedYear,
    String? selectedPeriod1,
    String? selectedPeriod2,
    String? selectedYearForFollowUp,
    String? selectedYearForProgress,
  }) {
    return CompanyDataState(
      company: company ?? this.company,
      settings: settings ?? this.settings,
      users: users ?? this.users,
      isFilterVisible: isFilterVisible ?? this.isFilterVisible,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedPeriod1: selectedPeriod1 ?? this.selectedPeriod1,
      selectedPeriod2: selectedPeriod2 ?? this.selectedPeriod2,
      selectedYearForFollowUp:
          selectedYearForFollowUp ?? this.selectedYearForFollowUp,
      selectedYearForProgress:
          selectedYearForProgress ?? this.selectedYearForProgress,
    );
  }

  @override
  List<Object?> get props => [
        company,
        settings,
        users,
        isFilterVisible,
        selectedYear,
        selectedPeriod1,
        selectedPeriod2,
        selectedYearForFollowUp,
        selectedYearForProgress,
      ];
}

class LoadingState extends CompanyState {}

class SavingState extends CompanyState {}

class SavedState extends CompanyState {}

class ErrorState extends CompanyState {
  final String message;

  const ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class CompaniesLoadedState extends CompanyState {
  final List<Partner> companies;
  final List<Partner> originalCompanies;

  const CompaniesLoadedState({
    required this.companies,
    required this.originalCompanies,
  });

  @override
  List<Object?> get props => [companies, originalCompanies];
}

class CompaniesFilteredState extends CompanyState {
  final List<Partner> companies;
  final List<Partner> originalCompanies;

  const CompaniesFilteredState({
    required this.companies,
    required this.originalCompanies,
  });

  @override
  List<Object?> get props => [companies, originalCompanies];
}

class CompaniesSortedState extends CompanyState {
  final List<Partner> companies;
  final List<Partner> originalCompanies;

  const CompaniesSortedState({
    required this.companies,
    required this.originalCompanies,
  });

  @override
  List<Object?> get props => [companies, originalCompanies];
}

class CompanyDeletedState extends CompanyState {
  final List<Partner> companies;
  final List<Partner> originalCompanies;

  const CompanyDeletedState({
    required this.companies,
    required this.originalCompanies,
  });

  @override
  List<Object?> get props => [companies, originalCompanies];
}

class FilterToggledState extends CompanyState {
  final bool isFilterVisible;
  final List<Partner> companies;
  final List<Partner> originalCompanies;

  const FilterToggledState({
    required this.isFilterVisible,
    required this.companies,
    required this.originalCompanies,
  });

  @override
  List<Object?> get props => [isFilterVisible, companies, originalCompanies];
}

class FollowUpDataLoadedState extends CompanyState {
  final Map<String, int> followUpData;

  const FollowUpDataLoadedState(this.followUpData);

  @override
  List<Object?> get props => [followUpData];
}

class ProgressDataLoadedState extends CompanyState {
  final ProgressChartData progressData;

  const ProgressDataLoadedState(this.progressData);

  @override
  List<Object?> get props => [progressData];
}

class ComparisonDataLoadedState extends CompanyState {
  final Map<String, int> comparisonData;

  const ComparisonDataLoadedState(this.comparisonData);

  @override
  List<Object?> get props => [comparisonData];
}

class AvailableYearsLoadedState extends CompanyState {
  final List<String> years;

  const AvailableYearsLoadedState(this.years);

  @override
  List<Object?> get props => [years];
}

class AvailablePeriodsLoadedState extends CompanyState {
  final List<String> periods;

  const AvailablePeriodsLoadedState(this.periods);

  @override
  List<Object?> get props => [periods];
}
