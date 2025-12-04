import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/data/company_response_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/repositories/ai_company_repository.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/data/partner_dto.dart';
import 'package:requirment_gathering_app/user_module/repo/customer_company_repository.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository.dart';

abstract class AiCompanyListState extends Equatable {}

class CompanyListInitial extends AiCompanyListState {
  @override
  List<Object?> get props => [];
}

class CompanyListLoading extends AiCompanyListState {
  @override
  List<Object?> get props => [];
}

class CompanyListLoadedWithSettings extends AiCompanyListState {
  final List<String> businessTypes;
  final List<String> countries;
  final List<String> cities;

  CompanyListLoadedWithSettings({
    required this.businessTypes,
    required this.countries,
    required this.cities,
  });

  @override
  List<Object?> get props => [businessTypes, countries, cities];
}

class CompanyListLoaded extends AiCompanyListState {
  final List<Partner> companies;

  CompanyListLoaded(this.companies);

  @override
  List<Object?> get props => [companies];
}

class CompanyListSaving extends AiCompanyListState {
  @override
  List<Object?> get props => [];
}

class CompanyListSaved extends AiCompanyListState {
  @override
  List<Object?> get props => [];
}

class CompanyListError extends AiCompanyListState {
  final String message;

  CompanyListError(this.message);

  @override
  List<Object?> get props => [message];
}

class CountrySelected extends AiCompanyListState {
  final String selectedCountry;
  final List<String> countries; // Include the list of countries

  CountrySelected(this.selectedCountry, this.countries);

  @override
  List<Object?> get props => [selectedCountry, countries];
}

class CitySelected extends AiCompanyListState {
  final String selectedCity;
  final List<String> cities;

  CitySelected(this.selectedCity, this.cities);

  @override
  List<Object?> get props => [selectedCity, cities];
}

class BusinessTypeSelected extends AiCompanyListState {
  final String selectedBusinessType;
  final List<String> businessTypes;

  BusinessTypeSelected(this.selectedBusinessType, this.businessTypes);

  @override
  List<Object?> get props => [selectedBusinessType, businessTypes];
}

class CitiesUpdated extends AiCompanyListState {
  final List<String> cities;

  CitiesUpdated(this.cities);

  @override
  List<Object?> get props => [cities];
}

class AiCompanyListCubit extends Cubit<AiCompanyListState> {
  final AiCompanyListRepository _repository;
  final CompanySettingRepository _settingRepository;
  final CustomerCompanyRepository _companyRepository;
  late final List<String> businessTypes;

  Map<String, List<String>> countryCityMap = {}; // Country -> Cities Map
  String selectedCountry = '';
  String selectedCity = '';
  String selectedBusinessType = '';

  AiCompanyListCubit(
    this._repository,
    this._settingRepository,
    this._companyRepository,
  ) : super(CompanyListInitial());

  Future<void> loadCompanySettings() async {
    try {
      emit(CompanyListLoading()); // Emit loading state

      final result = await _settingRepository.getSettings();

      result.fold(
            (error) {
          emit(CompanyListError("Failed to load settings: $error"));
        },
            (settings) {
          countryCityMap = settings.countryCityMap;
          businessTypes = settings.businessTypes;

          emit(CompanyListLoadedWithSettings(
            businessTypes: settings.businessTypes,
            countries: countryCityMap.keys.toList(),
            cities: countryCityMap[selectedCountry] ?? [],
          ));
        },
      );
    } catch (e) {
      emit(CompanyListError("Unexpected error: $e"));
    }
  }

  void updateCountry(String country) {
    selectedCountry = country;
    emit(CountrySelected(selectedCountry,
        countryCityMap.keys.toList())); // Emit updated country state
    emit(CitiesUpdated(countryCityMap[selectedCountry] ??
        [])); // Update cities based on selected country
  }

  void updateCity(String? city) {
    selectedCity = city ?? ''; // If city is null, reset it
    emit(CitySelected(selectedCity,
        countryCityMap[selectedCountry] ?? [])); // Emit updated city state
  }

  void updateBusinessType(String businessType) {
    selectedBusinessType = businessType;
    emit(BusinessTypeSelected(selectedBusinessType,
        businessTypes)); // Emit updated business type state
  }

  Future<void> fetchCompanyList(String search) async {
    emit(CompanyListLoading());

    try {
      Either<Exception, List<PartnerDto>> existingCompaniesResponse =
      await _companyRepository.getFilteredCompanies(
        selectedCountry,
        selectedCity,
        selectedBusinessType,
      );

      existingCompaniesResponse.fold(
            (error) {
          emit(CompanyListError("Error fetching companies from Firestore: ${error.toString()}"));
        },
            (existingCompanies) async {

          List<String> existingCompanyNames =
          existingCompanies.map((c) => c.companyName).toList();

          Either<Exception, List<AiCompanyDto>> newCompaniesResponse =
              await _repository.fetchCompanyListFromAPI(
            selectedCountry,
            selectedCity,
            selectedBusinessType,
            existingCompanyNames,
            search,
          );

          newCompaniesResponse.fold(
                (error) {
              emit(CompanyListError("Error fetching companies from API: ${error.toString()}"));
            },
                (newCompanies) {

            },
          );

            },
      );
    } catch (e) {
      emit(CompanyListError("Error fetching companies: $e"));
    }
  }


  Future<void> checkAndAddSourceAI() async {
      final settingsResult = await _settingRepository.getSettings();

       settingsResult.fold(
            (error) {
          return Left(Exception("Failed to load settings: $error"));
        },
            (settings) {
          if (!settings.sources.contains('AI')) {
            final updatedSettings = settings.copyWith(
              sources: [...settings.sources, 'AI'],
            );

            _settingRepository.updateSettings(updatedSettings);
          }
        },
      );

  }

  Future<void> saveCompanies(List<Partner> companies) async {
    try {
    } catch (e) {
      print("Unexpected error: $e");
      emit(CompanyListError("Unexpected error: ${e.toString()}"));
    }
  }

}
