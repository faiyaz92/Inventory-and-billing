// import 'package:equatable/equatable.dart';
//
// abstract class AiCompanyListState extends Equatable {}
//
// class CompanyListInitial extends AiCompanyListState {
//   @override
//   List<Object?> get props => [];
// }
//
// class CompanyListLoading extends AiCompanyListState {
//   @override
//   List<Object?> get props => [];
// }
//
// class CompanyListLoadedWithSettings extends AiCompanyListState {
//   final List<String> businessTypes;
//   final List<String> countries;
//   final List<String> cities;
//
//   CompanyListLoadedWithSettings({
//     required this.businessTypes,
//     required this.countries,
//     required this.cities,
//   });
//
//   @override
//   List<Object?> get props => [businessTypes, countries, cities];
// }
//
// class CompanyListLoaded extends AiCompanyListState {
//   final List<AiCompanyDto> companies;
//
//   CompanyListLoaded(this.companies);
//
//   @override
//   List<Object?> get props => [companies];
// }
//
// class CompanyListSaving extends AiCompanyListState {
//   @override
//   List<Object?> get props => [];
// }
//
// class CompanyListSaved extends AiCompanyListState {
//   @override
//   List<Object?> get props => [];
// }
//
// class CompanyListError extends AiCompanyListState {
//   final String message;
//
//   CompanyListError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
//
// class CountrySelected extends AiCompanyListState {
//   final String selectedCountry;
//
//   CountrySelected(this.selectedCountry);
//
//   @override
//   List<Object?> get props => [selectedCountry];
// }
//
// class CitySelected extends AiCompanyListState {
//   final String selectedCity;
//
//   CitySelected(this.selectedCity);
//
//   @override
//   List<Object?> get props => [selectedCity];
// }
