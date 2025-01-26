import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repository;
  final CompanySettingRepository _settingRepository;

  CompanyCubit(this._repository, this._settingRepository)
      : super(CompanyState.initial());

  // Update company form data via the Company object
  Future<void> loadCompanySettings() async {
    try {
      final settings = await _settingRepository.getSettings();
      final companyWithSettings = state.company?.copyWith(
        settings: settings,
      );
      emit(state.copyWith(company: companyWithSettings));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to load settings: $e"));
    }
  }

  void updateSource(String? source) {
    emit(state.copyWith(company: state.company?.copyWith(source: source)));
  }

  void updateEmailSent(bool? value) {
    emit(state.copyWith(
        company: state.company?.copyWith(emailSent: value ?? false)));
  }

  void updateInterestLevel(String? level) {
    emit(
        state.copyWith(company: state.company?.copyWith(interestLevel: level)));
  }

  void updateCity(String? city) {
    emit(state.copyWith(company: state.company?.copyWith(city: city)));
  }

  void updatePriority(String? priority) {
    emit(state.copyWith(company: state.company?.copyWith(priority: priority)));
  }

  void updateAssignedTo(String? assignedTo) {
    emit(state.copyWith(
        company: state.company?.copyWith(assignedTo: assignedTo)));
  }

  void updateRepliedTo(bool? value) {
    emit(state.copyWith(
        company: state.company?.copyWith(theyReplied: value ?? false)));
  }

  void updateVerification(String platform, bool isChecked) {
    final updatedVerification =
    List<String>.from(state.company?.verifiedOn ?? []);
    if (isChecked) {
      if (!updatedVerification.contains(platform)) {
        updatedVerification.add(platform);
      }
    } else {
      updatedVerification.remove(platform);
    }
    emit(state.copyWith(
        company: state.company?.copyWith(verifiedOn: updatedVerification)));
  }

  // Contact Persons Management
  void addContactPerson() {
    final updatedContacts =
    List<ContactPerson>.from(state.company?.contactPersons ?? [])
      ..add(ContactPerson(name: '', email: '', phoneNumber: ''));
    emit(state.copyWith(
        company: state.company?.copyWith(contactPersons: updatedContacts)));
  }

  void updateContactPerson(int index, ContactPerson updatedPerson) {
    final updatedContacts =
    List<ContactPerson>.from(state.company?.contactPersons ?? []);
    updatedContacts[index] = updatedPerson;
    emit(state.copyWith(
        company: state.company?.copyWith(contactPersons: updatedContacts)));
  }

  void removeContactPerson(int index) {
    final updatedContacts =
    List<ContactPerson>.from(state.company?.contactPersons ?? [])
      ..removeAt(index);
    emit(state.copyWith(
        company: state.company?.copyWith(contactPersons: updatedContacts)));
  }

  Future<void> saveCompany() async {
    if (state.company == null ||
        state.company!.companyName.isEmpty ||
        state.company!.source == null) {
      emit(state.copyWith(
          errorMessage: "Company Name and Source are required."));
      return;
    }

    emit(state.copyWith(isSaving: true, errorMessage: null));

    try {
      final isUnique =
      await _repository.isCompanyNameUnique(state.company!.companyName);
      if (!isUnique) {
        emit(state.copyWith(
            isSaving: false, errorMessage: "Company name already exists."));
        return;
      }

      await _repository
          .addCompany(state.company!); // Pass Company object directly
      emit(CompanyState.initial());
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  void updateCompany(Company updatedCompany) {
    emit(state.copyWith(company: updatedCompany));
  }

  Future<void> loadCompanies() async {
    emit(state.copyWith(isLoading: true));
    try {
      final companies =
      await _repository.getAllCompanies(); // Now returns List<Company>
      emit(state.copyWith(
        isLoading: false,
        companies: companies,
        originalCompanies: companies,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // Search companies
  void searchCompanies(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(companies: state.originalCompanies));
      return;
    }

    final filteredCompanies = state.originalCompanies.where((company) {
      return company.companyName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(companies: filteredCompanies));
  }

  // Sort companies by date
  void sortCompaniesByDate({required bool ascending}) {
    final sortedCompanies = List<Company>.from(state.companies);
    sortedCompanies.sort((a, b) {
      return ascending
          ? a.dateCreated.compareTo(b.dateCreated)
          : b.dateCreated.compareTo(a.dateCreated);
    });

    emit(state.copyWith(companies: sortedCompanies));
  }

  Future<void> deleteCompany(String id) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.deleteCompany(id);
      final updatedCompanies =
      state.companies.where((company) => company.id != id).toList();
      emit(state.copyWith(isSaving: false, companies: updatedCompanies));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  void updateCountry(String? country) {
    if (country != null) {
      emit(state.copyWith(
        company: state.company?.copyWith(
            country: country, city: null), // Reset city when country changes
      ));
    }
  }

  List<String> getCitiesForCountry(String? country) {
    final countryCityMap = state.company?.settings?.countryCityMap ?? {};
    return countryCityMap[country] ?? [];
  }
}