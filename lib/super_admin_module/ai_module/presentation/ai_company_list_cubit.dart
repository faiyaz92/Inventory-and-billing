import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/data/company_response_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/repositories/ai_company_repository.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';
import 'package:requirment_gathering_app/user_module/repo/company_repository.dart';
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
  final List<Company> companies;

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

// Define all states for country, city, and other dropdowns
class AiCompanyListCubit extends Cubit<AiCompanyListState> {
  final AiCompanyListRepository _repository;
  final CompanySettingRepository _settingRepository;
  final CompanyRepository _companyRepository;
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

  // Load company settings (including country-city map)
  Future<void> loadCompanySettings() async {
    try {
      emit(CompanyListLoading()); // Emit loading state

      // Get settings using repository that returns Either<Exception, Settings>
      final result = await _settingRepository.getSettings();

      // Handle success and error cases using fold
      result.fold(
            (error) {
          // Handle error case (Left)
          emit(CompanyListError("Failed to load settings: $error"));
        },
            (settings) {
          // Handle success case (Right)
          countryCityMap = settings.countryCityMap;
          businessTypes = settings.businessTypes;

          // Emit loaded settings state
          emit(CompanyListLoadedWithSettings(
            businessTypes: settings.businessTypes,
            countries: countryCityMap.keys.toList(),
            cities: countryCityMap[selectedCountry] ?? [],
          ));
        },
      );
    } catch (e) {
      // Handle any other errors (unexpected)
      emit(CompanyListError("Unexpected error: $e"));
    }
  }

  // Update selected country
  void updateCountry(String country) {
    selectedCountry = country;
    emit(CountrySelected(selectedCountry,
        countryCityMap.keys.toList())); // Emit updated country state
    emit(CitiesUpdated(countryCityMap[selectedCountry] ??
        [])); // Update cities based on selected country
  }

  // Update selected city
  void updateCity(String? city) {
    selectedCity = city ?? ''; // If city is null, reset it
    emit(CitySelected(selectedCity,
        countryCityMap[selectedCountry] ?? [])); // Emit updated city state
  }

  // Handle business type selection
  void updateBusinessType(String businessType) {
    selectedBusinessType = businessType;
    emit(BusinessTypeSelected(selectedBusinessType,
        businessTypes)); // Emit updated business type state
  }

  // Fetch companies based on selected filters
  // Future<void> fetchCompanyList(String search) async {
  //   // await  checkAndAddSourceAI();
  //   emit(CompanyListLoading());
  //
  //   try {
  //     // Fetch existing companies from Firestore
  //     List<Company> existingCompanies =
  //         await _companyRepository.getFilteredCompanies(
  //       selectedCountry,
  //       selectedCity,
  //       selectedBusinessType,
  //     );
  //     existingCompanies = existingCompanies.map((company) {
  //       // For each company, create a new instance with the source set to 'AI'
  //       return company.copyWith(source: 'AI');
  //     }).toList();
  //     List<String> existingCompanyNames =
  //         existingCompanies.map((c) => c.companyName).toList();
  //
  //     // Fetch new companies from API
  //     Either<Exception, List<AiCompanyDto>> newCompanies =
  //         await _repository.fetchCompanyListFromAPI(selectedCountry,
  //             selectedCity, selectedBusinessType, existingCompanyNames, "");
  //
  //     emit(CompanyListLoaded(existingCompanies));
  //   } catch (e) {
  //     emit(CompanyListError("Error fetching companies: $e"));
  //   }
  // }
  Future<void> fetchCompanyList(String search) async {
    emit(CompanyListLoading());

    try {
      // Fetch existing companies from Firestore using the updated repository method
      Either<Exception, List<Company>> existingCompaniesResponse =
      await _companyRepository.getFilteredCompanies(
        selectedCountry,
        selectedCity,
        selectedBusinessType,
      );

      // Handle the response from the repository call
      existingCompaniesResponse.fold(
            (error) {
          // In case of error, emit error state
          emit(CompanyListError("Error fetching companies from Firestore: ${error.toString()}"));
        },
            (existingCompanies) async {
          // For each company, create a new instance with the source set to 'AI'
          existingCompanies = existingCompanies.map((company) {
            return company.copyWith(source: 'AI');
          }).toList();

          List<String> existingCompanyNames =
          existingCompanies.map((c) => c.companyName).toList();

          // Fetch new companies from API
          Either<Exception, List<AiCompanyDto>> newCompaniesResponse =
              await _repository.fetchCompanyListFromAPI(
            selectedCountry,
            selectedCity,
            selectedBusinessType,
            existingCompanyNames,
            search,
          );

          // Handle the response from API call
          newCompaniesResponse.fold(
                (error) {
              // In case of error, emit error state
              emit(CompanyListError("Error fetching companies from API: ${error.toString()}"));
            },
                (newCompanies) {
              // Handle success, map API response to UI models if necessary
              // List<Company> newCompanyList = newCompanies.map((aiCompanyDto) {
              //   return aiCompanyDto.toCompany(); // Assuming you have a method like this
              // }).toList();

              // Emit the final loaded state with both existing and new companies
              emit(CompanyListLoaded(existingCompanies));
            },
          );
          emit(CompanyListLoaded(existingCompanies));

            },
      );
    } catch (e) {
      emit(CompanyListError("Error fetching companies: $e"));
    }
  }

  // Assuming you have an instance of CompanySettingRepository as _settingRepository

  Future<void> checkAndAddSourceAI() async {
      // Step 1: Fetch current settings
      final settingsResult = await _settingRepository.getSettings();

      // Check if settings fetching is successful
       settingsResult.fold(
            (error) {
          // If an error occurs while fetching settings
          return Left(Exception("Failed to load settings: $error"));
        },
            (settings) {
          // Step 2: Check if "AI" is in the sources list
          if (!settings.sources.contains('AI')) {
            // Step 3: Add "AI" to the sources list
            final updatedSettings = settings.copyWith(
              sources: [...settings.sources, 'AI'],
            );

            // Step 4: Update settings with the modified list
            _settingRepository.updateSettings(updatedSettings);
          }
          // Return success
        },
      );

  }

  Future<void> saveCompanies(List<Company> companies) async {
    try {
      final result = await _companyRepository.saveCompaniesBulk(companies);

      result.fold(
            (error) {
          // In case of an error, emit an error state or handle it accordingly
          print("Error saving companies: $error");
          emit(CompanyListError("Error saving companies: ${error.toString()}"));
        },
            (failedToSave) {
          // If saving is successful, emit the loaded state with the failed companies
          emit(CompanyListLoaded(failedToSave));
        },
      );
    } catch (e) {
      print("Unexpected error: $e");
      emit(CompanyListError("Unexpected error: ${e.toString()}"));
    }
  }

}
