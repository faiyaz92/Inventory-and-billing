import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/data/company.dart';

class CompanyState extends Equatable {
  final Company? company; // Use Company object for the form data
  final List<Company> companies; // List of companies for display
  final List<Company> originalCompanies; // Full list of companies for filtering
  final bool isSaving; // Tracks if a save operation is in progress
  final bool isLoading; // Tracks if data is loading
  final bool isSaved; // Tracks if the company was successfully saved
  final String? errorMessage; // Error messages if something goes wrong

  const CompanyState({
    this.company,
    this.companies = const [],
    this.originalCompanies = const [],
    this.isSaving = false,
    this.isLoading = false,
    this.isSaved = false,
    this.errorMessage,
  });

  // Initial state
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

  // Copy with method for updating state
  CompanyState copyWith({
    Company? company,
    List<Company>? companies,
    List<Company>? originalCompanies,
    bool? isSaving,
    bool? isLoading,
    bool? isSaved,
    String? errorMessage,
  }) {
    return CompanyState(
      company: company ?? this.company,
      companies: companies ?? this.companies,
      originalCompanies: originalCompanies ?? this.originalCompanies,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      errorMessage: errorMessage,
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
      ];
}
