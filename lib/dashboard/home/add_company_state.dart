import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/data/company.dart';

class CompanyState extends Equatable {
  final Company? company;
  final List<Company> companies;
  final List<Company> originalCompanies;
  final bool isSaving;
  final bool isLoading;
  final bool isSaved;
  final String? errorMessage;
  final bool isFilterVisible; // Add filter visibility state here
  final String? selectedYear; // ✅ Added this field to track selected year
  final String? selectedPeriod1;
  final String? selectedPeriod2;
  final String? selectedYearForFollowUp;
  final String? selectedYearForProgress;

  const CompanyState({
    this.company,
    this.companies = const [],
    this.originalCompanies = const [],
    this.isSaving = false,
    this.isLoading = false,
    this.isSaved = false,
    this.errorMessage,
    this.isFilterVisible = false, // Default to hidden
    this.selectedYear, // Default to hidden
    this.selectedPeriod1,
    this.selectedYearForFollowUp,
    this.selectedYearForProgress,
    this.selectedPeriod2,
  });

  factory CompanyState.initial() {
    List<String> defaultPeriods = [
      DateFormat('MMM yyyy').format(DateTime.now()),
      // Current month-year (e.g., "Jan 2025")
      "Q1 ${DateFormat('yyyy').format(DateTime.now())}",
      // Current quarter (e.g., "Q1 2025")
      DateFormat('yyyy').format(DateTime.now()),
      // Current year (e.g., "2025")
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
      ),
      selectedYear: DateFormat('yyyy').format(DateTime.now()),
      selectedPeriod1: defaultPeriods[0],
      // ✅ Always selects a valid default period
      selectedPeriod2: defaultPeriods[1],
      selectedYearForFollowUp: DateFormat('yyyy').format(DateTime.now()),
      selectedYearForProgress: DateFormat('yyyy').format(DateTime.now()),
    );
  }

  CompanyState copyWith({
    Company? company,
    List<Company>? companies,
    List<Company>? originalCompanies,
    bool? isSaving,
    bool? isLoading,
    bool? isSaved,
    String? errorMessage,
    bool? isFilterVisible, // Add visibility to copyWith
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
        isSaving,
        isLoading,
        isSaved,
        errorMessage,
        isFilterVisible, // Include in props
        selectedYearForFollowUp,
        selectedYearForProgress,
      ];
}
