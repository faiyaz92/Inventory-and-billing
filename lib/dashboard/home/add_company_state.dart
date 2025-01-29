import 'package:equatable/equatable.dart';
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

  const CompanyState({
    this.company,
    this.companies = const [],
    this.originalCompanies = const [],
    this.isSaving = false,
    this.isLoading = false,
    this.isSaved = false,
    this.errorMessage,
    this.isFilterVisible = false, // Default to hidden
  });

  factory CompanyState.initial() {
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
  ];
}

