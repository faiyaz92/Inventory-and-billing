import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/data/company_settings.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';
import 'package:requirment_gathering_app/utils/AppColor.dart';
import 'package:requirment_gathering_app/utils/AppKeys.dart';
import 'package:requirment_gathering_app/utils/AppLabels.dart';
import 'package:requirment_gathering_app/utils/date_time_utils.dart';
import 'package:requirment_gathering_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _repository;
  final CompanySettingRepository _settingRepository;
  final List<Company> originalCompanies =
      []; // Full list of companies for filtering
  late CompanySettingsUi companySettingsUi;
  String searchKeyword = '';

  CompanyCubit(this._repository, this._settingRepository)
      : super(CompanyState.initial());


  // Update company form data via the Company object
  Future<void> loadCompanySettings() async {
    try {
      final result = await _settingRepository.getSettings();
      result.fold(
            (error) {
          // If there’s an error, emit error state with the message
          emit(state.copyWith(errorMessage: "Failed to load settings: $error"));
        },
            (settings) {
          // If success, update the settings and company state
          companySettingsUi = settings;
          final companyWithSettings = state.company?.copyWith(settings: settings);
          emit(state.copyWith(company: companyWithSettings));
        },
      );
    } catch (e) {
      // General error catch if something unexpected happens
      emit(state.copyWith(errorMessage: "Unexpected error: $e"));
    }
  }


  void updateSource(String? source) {
    emit(state.copyWith(company: state.company?.copyWith(source: source)));
  }

  void updateBusinessType(String? businessType) {
    emit(state.copyWith(
        company: state.company?.copyWith(businessType: businessType)));
  }

  void updateEmailSent(bool? value) {
    emit(state.copyWith(
        company: state.company?.copyWith(emailSent: value ?? false)));
  }

  void updateInterestLevel(String? level) {
    emit(
        state.copyWith(company: state.company?.copyWith(interestLevel: level)));

    applyGeneralFilters();
  }

  void updateCity(String? city) {
    emit(state.copyWith(company: state.company?.copyWith(city: city)));
    applyGeneralFilters();
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
      emit(state.copyWith(errorMessage: "Company Name and Source are required."));
      return;
    }

    emit(state.copyWith(isSaving: true, errorMessage: null));

    try {
      if (state.company!.id.isEmpty) {
        // New company case
        final isUnique = await _repository.isCompanyNameUnique(state.company!.companyName);

        isUnique.fold(
              (error) {
            // If error occurred while checking uniqueness, emit error message
            emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
          },
              (isUnique) {
            // If company name is not unique
            if (!isUnique) {
              emit(state.copyWith(isSaving: false, errorMessage: "Company name already exists."));
              return;
            }

            // Add new company to repository
            _repository.addCompany(state.company!).then((_) {
              emit(CompanyState.initial());
            }).catchError((e) {
              emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
            });
          },
        );
      } else {
        // Existing company case
        await _repository.updateCompany(state.company!.id, state.company!);
        emit(CompanyState.initial());
      }
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  void updateCompany(Company updatedCompany) {
    // local populate
    emit(state.copyWith(company: updatedCompany));
  }

  Future<void> loadCompanies() async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await _repository.getAllCompanies(); // Returns Either<Exception, List<Company>>

      result.fold(
            (error) {
          // If it's a Left (error), handle it by emitting the error message
          emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
        },
            (companies) {
          // If it's a Right (success), proceed with the company data
          originalCompanies.addAll(companies);
          emit(state.copyWith(
            isLoading: false,
            companies: companies,
            originalCompanies: originalCompanies,
          ));
          sortCompaniesByDate(ascending: false);
        },
      );
    } catch (e) {
      // Catch any unhandled errors and emit them
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }


  // Sort companies by date
  void sortCompaniesByDate({required bool ascending}) {
    final sortedCompanies = List<Company>.from(state.companies);
    sortedCompanies.sort((a, b) {
      return ascending
          ? a.dateCreated.compareTo(b.dateCreated)
          : b.dateCreated.compareTo(a.dateCreated);
    });

    emit(state.copyWith(companies: sortedCompanies, isLoading: false));
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

  Color getInterestLevelColor(String? level) {
    if (level == null) return Colors.grey;

    final percentage = int.tryParse(level.replaceAll('%', '')) ?? 0;
    if (percentage >= 81) return Colors.green[900]!;
    if (percentage >= 61) return Colors.green[400]!;
    if (percentage >= 41) return Colors.orange;
    if (percentage >= 21) return Colors.red[300]!;
    return Colors.red[900]!;
  }

  Color getRepliedColor(bool replied) {
    return replied ? Colors.green[900]! : Colors.red[900]!;
  }

  Color getEmailSentColor(bool emailSent) {
    return emailSent ? Colors.blue : Colors.orange;
  }

  String validateValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLabels.notAvailable;
    }
    return value;
  }

  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      try {
        await launch(url);
      } catch (e) {
        emit(state.copyWith(errorMessage: "Failed to launch URL: $e"));
      }
    } else {
      emit(state.copyWith(errorMessage: "Cannot launch URL: $url"));
    }
  }

  void sortCompaniesByName() {
    final sorted = List.of(state.companies)
      ..sort((a, b) => a.companyName.compareTo(b.companyName));
    emit(state.copyWith(companies: sorted));
  }

  void sortCompaniesByCountry() {
    final sorted = List.of(state.companies)
      ..sort((a, b) => (a.country ?? '').compareTo(b.country ?? ''));
    emit(state.copyWith(companies: sorted));
  }

  void updateEmailReplied(bool? value) {
    emit(state.copyWith(
      company: state.company?.copyWith(theyReplied: value ?? false),
    ));
  }

  // Search companies
  void searchCompanies(String query) {
    searchKeyword = query;
    applyGeneralFilters();
  }

  void filterByCountry() {
    applyGeneralFilters();
  }

  void clearFilters() {
    state.companies.clear();
    state.companies.addAll(state.originalCompanies);
    searchKeyword = '';
    emit(CompanyState.initial());
    List<Company> initialCompanyList = List.from(originalCompanies);

    emit(state.copyWith(
        companies: initialCompanyList,
        originalCompanies: originalCompanies,
        company: state.company?.copyWith(settings: companySettingsUi)));
    sortCompaniesByDate(ascending: false);

    // emit(state.copyWith(
    //   companies: state.companies,
    //   originalCompanies: state.originalCompanies,
    //   company: state.company?.copyWith(
    //     country: null,
    //     city: null,
    //     interestLevel: null,
    //     priority: null,
    //     source: null,
    //     emailSent: false,
    //     theyReplied: false,
    //   ),
    // ));
  }

  Future<void> applyGeneralFilters() async {
    // Start with the original company list
    List<Company> filteredCompanies = List.from(originalCompanies);

    // Filter by search keyword
    if (searchKeyword.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.companyName
            .toLowerCase()
            .contains(searchKeyword.toLowerCase());
      }).toList();
    }

    // Filter by country
    if (state.company?.country != null && state.company!.country!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.country == state.company?.country;
      }).toList();
    }

    // Filter by city
    if (state.company?.city != null && state.company!.city!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.city == state.company?.city;
      }).toList();
    }

    if (state.company?.businessType != null &&
        state.company!.businessType!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.businessType == state.company?.businessType;
      }).toList();
    }

    // Filter by interest level
    if (state.company?.interestLevel != null &&
        state.company!.interestLevel!.isNotEmpty) {
      final range =
          state.company!.interestLevel!.split('-').map(int.parse).toList();
      final lowerBound = range[0];
      final upperBound = range[1];
      filteredCompanies = filteredCompanies.where((company) {
        final interestValue =
            int.tryParse(company.interestLevel?.replaceAll('%', '') ?? '0') ??
                0;
        return interestValue >= lowerBound && interestValue <= upperBound;
      }).toList();
    }

    // Filter by email sent
    if (state.company?.emailSent != null) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.emailSent == state.company?.emailSent;
      }).toList();
    }
    //
    // // Filter by replied status
    if (state.company?.theyReplied != null) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.theyReplied == state.company?.theyReplied;
      }).toList();
    }

    // Filter by priority
    if (state.company?.priority != null &&
        state.company!.priority!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.priority == state.company?.priority;
      }).toList();
    }

    // Filter by source
    if (state.company?.source != null && state.company!.source!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.source == state.company?.source;
      }).toList();
    }

    // Emit the filtered state
    emit(state.copyWith(companies: filteredCompanies));
  }

  void setSearchKeyword(String keyword) {
    searchKeyword = keyword;
    applyGeneralFilters();
  }

  void toggleFilterVisibility() {
    emit(state.copyWith(isFilterVisible: !state.isFilterVisible));
  }

  // Sort companies by different types
  void sortCompaniesBy(String? sortTypeString) {
    List<Company> sortedCompanies = List.from(state.companies);

    // Handle null input by defaulting to SortType.latest
    SortType sortType = (sortTypeString != null)
        ? SortType.values.firstWhere(
            (e) => e.toString() == 'SortType.' + sortTypeString,
            orElse: () => SortType.latest, // Default if no match
          )
        : SortType.latest;

    // Perform sorting based on the enum value
    switch (sortType) {
      case SortType.latest:
        sortedCompanies.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
      case SortType.oldest:
        sortedCompanies.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      case SortType.highToLowInterest:
        sortedCompanies.sort((a, b) {
          final interestA =
              int.tryParse(a.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          final interestB =
              int.tryParse(b.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          return interestB.compareTo(interestA);
        });
        break;
      case SortType.lowToHighInterest:
        sortedCompanies.sort((a, b) {
          final interestA =
              int.tryParse(a.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          final interestB =
              int.tryParse(b.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          return interestA.compareTo(interestB);
        });
        break;
    }

    emit(state.copyWith(companies: sortedCompanies));
  }

  Color getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.green[900]!;
      case 'medium':
        return Colors.green[300]!;
      case 'low':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  ///for report page methods

  ///---------------------------------------------------------------
// Fetch follow-up data for the selected year
  Map<String, int> getFollowUpDataForYear(String? year) {
    return {
      AppKeys.totalKey: state.companies
          .where((c) => getYearFromDate(c.dateCreated.toString()) == year)
          .length,
      AppKeys.sentKey: state.companies
          .where((c) =>
              getYearFromDate(c.dateCreated.toString()) == year && c.emailSent)
          .length,
      AppKeys.notSentKey: state.companies
          .where((c) =>
              getYearFromDate(c.dateCreated.toString()) == year && !c.emailSent)
          .length,
    };
  }

// Fetch progress data for the selected year
  ProgressChartData getProgressData(String? selectedYearForProgress) {
    final companies = state.companies
        .where((c) =>
            getYearFromDate(c.dateCreated.toString()) ==
            selectedYearForProgress)
        .toList();

    List<int> data = List.generate(12, (index) {
      return companies.where((c) => c.dateCreated.month == index + 1).length;
    });

    return ProgressChartData(
      bars: List.generate(data.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              y: data[index].toDouble(),
              colors: [
                data[index] > 0 ? AppColors.blue : AppColors.transparent
              ],
              width: 20,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        );
      }),
      labels: AppKeys.monthLabels, // List of month names stored in AppKeys
      maxValue: data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 1,
    );
  }

// Fetch comparison data between two selected periods
  Map<String, int> getComparisonData(String? period1, String? period2) {
    return {
      AppKeys.period1Key: _getCompanyCountForPeriod(period1),
      AppKeys.period2Key: _getCompanyCountForPeriod(period2),
    };
  }

// Get available years from companies' data
  List<String> getAvailableYears() {
    return state.companies
        .map((company) => getYearFromDate(company.dateCreated.toString()))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

// Get available periods (years, months, and quarters)
  List<String> getAvailablePeriods() {
    Set<String> periods = {};
    for (var company in state.companies) {
      periods.add(getYearFromDate(company.dateCreated.toString()));
      periods.add(getMonthYearFromDate(company.dateCreated.toString()));
      periods.add(getQuarterFromDate(company.dateCreated.toString()));
    }
    return periods.toList()..sort((a, b) => b.compareTo(a));
  }

// Update selected year for follow-up
  void updateSelectedYearForFollowUp(String year) {
    emit(state.copyWith(selectedYearForFollowUp: year));
  }

// Update selected year for progress
  void updateSelectedYearForProgress(String year) {
    emit(state.copyWith(selectedYearForProgress: year));
  }

// Update selected period 1 for comparison
  void updateSelectedPeriod1(String period) {
    emit(state.copyWith(selectedPeriod1: period));
  }

// Update selected period 2 for comparison
  void updateSelectedPeriod2(String period) {
    emit(state.copyWith(selectedPeriod2: period));
  }

// Private helper method to get company count for a given period
  int _getCompanyCountForPeriod(String? period) {
    if (period == null || period.isEmpty) return 0;
    return state.companies.where((company) {
      return getYearFromDate(company.dateCreated.toString()) == period ||
          getMonthYearFromDate(company.dateCreated.toString()) == period ||
          getQuarterFromDate(company.dateCreated.toString()) == period;
    }).length;
  }
}

class ProgressChartData {
  final List<BarChartGroupData> bars;
  final List<String> labels;
  final int maxValue;

  ProgressChartData({
    required this.bars,
    required this.labels,
    required this.maxValue,
  });
}
