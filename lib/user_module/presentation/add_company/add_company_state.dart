import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';

class CompanyState extends Equatable {
  final Company? company;
  final List<Company> companies;
  final List<Company> originalCompanies;
  final List<String?>? users; // ✅ Added users list for dropdown
  final bool isSaving;
  final bool isLoading;
  final bool isSaved;
  final String? errorMessage;
  final bool isFilterVisible;
  final String? selectedYear;
  final String? selectedPeriod1;
  final String? selectedPeriod2;
  final String? selectedYearForFollowUp;
  final String? selectedYearForProgress;

  const CompanyState({
    this.company,
    this.companies = const [],
    this.originalCompanies = const [],
    this.users = const [], // ✅ Default empty list
    this.isSaving = false,
    this.isLoading = false,
    this.isSaved = false,
    this.errorMessage,
    this.isFilterVisible = false,
    this.selectedYear,
    this.selectedPeriod1,
    this.selectedPeriod2,
    this.selectedYearForFollowUp,
    this.selectedYearForProgress,
  });

  factory CompanyState.initial() {
    List<String> defaultPeriods = [
      DateFormat('MMM yyyy').format(DateTime.now()), // Current month-year
      "Q1 ${DateFormat('yyyy').format(DateTime.now())}", // Current quarter
      DateFormat('yyyy').format(DateTime.now()), // Current year
    ];
    return CompanyState(
      company: Company(
        id: '',
        companyName: '',
        source: null,
        address: null,
        email: null,
        contactNumber: null,
        contactPersons: [],
        emailSent: false,
        theyReplied: false,
        interestLevel: null,
        country: null,
        city: null,
        priority: null,
        assignedTo: null,
        verifiedOn: [],
        dateCreated: DateTime.now(),
        createdBy: '',
        lastUpdatedBy: '',
        businessType: null,
      ),
      selectedYear: DateFormat('yyyy').format(DateTime.now()),
      selectedPeriod1: defaultPeriods[0],
      selectedPeriod2: defaultPeriods[1],
      selectedYearForFollowUp: DateFormat('yyyy').format(DateTime.now()),
      selectedYearForProgress: DateFormat('yyyy').format(DateTime.now()),
    );
  }

  CompanyState copyWith({
    Company? company,
    List<Company>? companies,
    List<Company>? originalCompanies,
    List<String?>? users, // ✅ Added in copyWith
    bool? isSaving,
    bool? isLoading,
    bool? isSaved,
    String? errorMessage,
    bool? isFilterVisible,
    String? selectedYear,
    String? selectedPeriod1,
    String? selectedPeriod2,
    String? selectedYearForFollowUp,
    String? selectedYearForProgress,
  }) {
    return CompanyState(
      company: company ?? this.company,
      companies: companies ?? this.companies,
      originalCompanies: originalCompanies ?? this.originalCompanies,
      users: users ?? this.users, // ✅ Include users list
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: errorMessage ?? this.errorMessage,
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
    companies,
    originalCompanies,
    users, // ✅ Include in props for state comparison
    isSaving,
    isLoading,
    isSaved,
    errorMessage,
    isFilterVisible,
    selectedYearForFollowUp,
    selectedYearForProgress,
    selectedPeriod1,
    selectedPeriod2,
  ];
}
