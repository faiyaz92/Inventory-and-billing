import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppKeys.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/date_time_utils.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_state.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerCubit extends Cubit<CompanyState> {
  final CustomerCompanyService _companyService;
  final IAccountLedgerService _accountLedgerService;
  final UserServices _userServices;
  final List<Partner> originalCompanies = [];
  String searchKeyword = '';
  Partner? currentCompany;

  PartnerCubit(this._companyService, this._userServices, this._accountLedgerService)
      : super(CompanyDataState.initial());

  // AddCompanyPage Methods
  Future<void> initializeWithCompany(Partner? company) async {
    if (company != null) {
      currentCompany = company.copyWith(companyType: company.companyType ?? 'Site');
      emit(CompanyDataState(company: currentCompany));
    } else {
      currentCompany = CompanyDataState.initial().company;
      emit(CompanyDataState.initial());
    }
  }

  Future<void> loadCompanySettings() async {
    try {
      final result = await _companyService.getSettings();
      result.fold(
            (error) => emit(ErrorState("Failed to load settings: $error")),
            (settings) => emit(CompanyDataState(
          company: currentCompany,
          settings: settings,
          users: state is CompanyDataState ? (state as CompanyDataState).users : [],
        )),
      );
    } catch (e) {
      emit(ErrorState("Unexpected error: $e"));
    }
  }

  Future<void> loadUsers() async {
    try {
      final result = await _userServices.getUsersFromTenantCompany();
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: result,
      ));
    } catch (e) {
      emit(ErrorState("Failed to load users: $e"));
    }
  }

  void updateCompanyName(String name) {
    currentCompany = currentCompany?.copyWith(companyName: name);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateCompanyType(String? type) {
    currentCompany = currentCompany?.copyWith(companyType: type);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateAddress(String? address) {
    currentCompany = currentCompany?.copyWith(address: address);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateEmail(String? email) {
    currentCompany = currentCompany?.copyWith(email: email);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateContactNumber(String? number) {
    currentCompany = currentCompany?.copyWith(contactNumber: number);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateWebsiteLink(String? link) {
    currentCompany = currentCompany?.copyWith(websiteLink: link);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateLinkedInLink(String? link) {
    currentCompany = currentCompany?.copyWith(linkedInLink: link);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateClutchLink(String? link) {
    currentCompany = currentCompany?.copyWith(clutchLink: link);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateGoodFirmLink(String? link) {
    currentCompany = currentCompany?.copyWith(goodFirmLink: link);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateDescription(String? description) {
    currentCompany = currentCompany?.copyWith(description: description);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateSource(String? source) {
    currentCompany = currentCompany?.copyWith(source: source);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateBusinessType(String? businessType) {
    currentCompany = currentCompany?.copyWith(businessType: businessType);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateEmailSent(bool? value) {
    currentCompany = currentCompany?.copyWith(emailSent: value ?? false);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateRepliedTo(bool? value) {
    currentCompany = currentCompany?.copyWith(theyReplied: value ?? false);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateInterestLevel(String? level) {
    currentCompany = currentCompany?.copyWith(interestLevel: level);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updatePriority(String? priority) {
    currentCompany = currentCompany?.copyWith(priority: priority);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateAssignedTo(String? assignedTo) {
    currentCompany = currentCompany?.copyWith(assignedTo: assignedTo);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateCountry(String? country) {
    currentCompany = currentCompany?.copyWith(country: country, city: null);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateCity(String? city) {
    currentCompany = currentCompany?.copyWith(city: city);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateVerification(String platform, bool isChecked) {
    final updatedVerification = List<String>.from(currentCompany?.verifiedOn ?? []);
    if (isChecked) {
      if (!updatedVerification.contains(platform)) {
        updatedVerification.add(platform);
      }
    } else {
      updatedVerification.remove(platform);
    }
    currentCompany = currentCompany?.copyWith(verifiedOn: updatedVerification);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void addContactPerson(String name, String email, String phoneNumber) {
    final updatedContacts = List<ContactPerson>.from(currentCompany?.contactPersons ?? [])
      ..add(ContactPerson(name: name, email: email, phoneNumber: phoneNumber));
    currentCompany = currentCompany?.copyWith(contactPersons: updatedContacts);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void updateContactPerson(int index, String name, String email, String phoneNumber) {
    final updatedContacts = List<ContactPerson>.from(currentCompany?.contactPersons ?? []);
    updatedContacts[index] = ContactPerson(name: name, email: email, phoneNumber: phoneNumber);
    currentCompany = currentCompany?.copyWith(contactPersons: updatedContacts);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  void removeContactPerson(int index) {
    final updatedContacts = List<ContactPerson>.from(currentCompany?.contactPersons ?? [])
      ..removeAt(index);
    currentCompany = currentCompany?.copyWith(contactPersons: updatedContacts);
    if (currentCompany != null) {
      emit(CompanyDataState(
        company: currentCompany,
        settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
        users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      ));
    }
  }

  Future<void> saveCompany() async {
    emit( SavingState());
    try {
      final company = currentCompany!;
      if (company.companyName.isEmpty) {
        emit(const ErrorState("Company name is required"));
        return;
      }

      final isUnique = await _companyService.isCompanyNameUnique(company.companyName);
      isUnique.fold(
            (l) => emit(ErrorState(l.toString())),
            (r) async {
          if (!r && (company.id.isEmpty)) {
            emit(const ErrorState("Company name already exists"));
            return;
          }
          if (company.id.isEmpty) {
            await _companyService.addCompany(company);
            final newLedger = AccountLedger(
              totalOutstanding: 0,
              promiseAmount: null,
              promiseDate: null,
              transactions: [],
            );
            await _accountLedgerService.createLedger(company, newLedger);
          } else {
            await _companyService.updateCompany(company.id!, company);
          }
          emit( SavedState());
        },
      );
    } catch (e) {
      emit(ErrorState("Failed to save: $e"));
    }
  }

  void updateCompany(Partner updatedCompany) {
    currentCompany = updatedCompany;
    emit(CompanyDataState(
      company: currentCompany,
      settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
      users: state is CompanyDataState ? (state as CompanyDataState).users : [],
    ));
  }

  // CompanyListPage Methods
  Future<void> loadCompanies() async {
    emit( LoadingState());
    try {
      final result = await _companyService.getAllCompanies();
      result.fold(
            (error) => emit(ErrorState(error.toString())),
            (companies) {
          originalCompanies.clear();
          originalCompanies.addAll(companies);
          emit(CompaniesLoadedState(
            companies: companies,
            originalCompanies: originalCompanies,
          ));
          sortCompaniesByDate(ascending: false);
        },
      );
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  void filterByCompanyType(String companyType) {
    final filteredCompanies = originalCompanies.where((company) => company.companyType == companyType).toList();
    emit(CompaniesFilteredState(
      companies: filteredCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  void sortCompaniesByDate({required bool ascending}) {
    final sortedCompanies = List<Partner>.from(originalCompanies);
    sortedCompanies.sort((a, b) => ascending ? a.dateCreated.compareTo(b.dateCreated) : b.dateCreated.compareTo(a.dateCreated));
    emit(CompaniesSortedState(
      companies: sortedCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  Future<void> deleteCompany(String id) async {
    emit( LoadingState());
    try {
      await _companyService.deleteCompany(id);
      final updatedCompanies = originalCompanies.where((company) => company.id != id).toList();
      originalCompanies.clear();
      originalCompanies.addAll(updatedCompanies);
      emit(CompanyDeletedState(
        companies: updatedCompanies,
        originalCompanies: originalCompanies,
      ));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  void sortCompaniesByName() {
    final sortedCompanies = List<Partner>.from(originalCompanies)..sort((a, b) => a.companyName.compareTo(b.companyName));
    emit(CompaniesSortedState(
      companies: sortedCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  void sortCompaniesByCountry() {
    final sortedCompanies = List<Partner>.from(originalCompanies)..sort((a, b) => (a.country ?? '').compareTo(b.country ?? ''));
    emit(CompaniesSortedState(
      companies: sortedCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  void searchCompanies(String query) {
    searchKeyword = query;
    applyGeneralFilters();
  }

  void toggleFilterVisibility() {
    emit(FilterToggledState(
      isFilterVisible: !originalCompanies.isEmpty,
      companies: originalCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  void clearFilters() {
    searchKeyword = '';
    emit(CompaniesFilteredState(
      companies: originalCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  Future<void> applyGeneralFilters() async {
    List<Partner> filteredCompanies = List.from(originalCompanies);

    if (searchKeyword.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.companyName.toLowerCase().contains(searchKeyword.toLowerCase());
      }).toList();
    }

    if (currentCompany?.country != null && currentCompany!.country!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.country == currentCompany?.country;
      }).toList();
    }

    if (currentCompany?.city != null && currentCompany!.city!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.city == currentCompany?.city;
      }).toList();
    }

    if (currentCompany?.businessType != null && currentCompany!.businessType!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.businessType == currentCompany?.businessType;
      }).toList();
    }

    if (currentCompany?.interestLevel != null && currentCompany!.interestLevel!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.interestLevel == currentCompany?.interestLevel;
      }).toList();
    }

    if (currentCompany?.emailSent != null) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.emailSent == currentCompany?.emailSent;
      }).toList();
    }

    if (currentCompany?.theyReplied != null) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.theyReplied == currentCompany?.theyReplied;
      }).toList();
    }

    if (currentCompany?.priority != null && currentCompany!.priority!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.priority == currentCompany?.priority;
      }).toList();
    }

    if (currentCompany?.source != null && currentCompany!.source!.isNotEmpty) {
      filteredCompanies = filteredCompanies.where((company) {
        return company.source == currentCompany?.source;
      }).toList();
    }

    emit(CompaniesFilteredState(
      companies: filteredCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  void sortCompaniesBy(String? sortTypeString) {
    List<Partner> sortedCompanies = List.from(originalCompanies);
    SortType sortType = sortTypeString != null
        ? SortType.values.firstWhere(
          (e) => e.toString() == 'SortType.$sortTypeString',
      orElse: () => SortType.latest,
    )
        : SortType.latest;

    switch (sortType) {
      case SortType.latest:
        sortedCompanies.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
      case SortType.oldest:
        sortedCompanies.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      case SortType.highToLowInterest:
        sortedCompanies.sort((a, b) {
          final interestA = int.tryParse(a.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          final interestB = int.tryParse(b.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          return interestB.compareTo(interestA);
        });
        break;
      case SortType.lowToHighInterest:
        sortedCompanies.sort((a, b) {
          final interestA = int.tryParse(a.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          final interestB = int.tryParse(b.interestLevel?.replaceAll('%', '') ?? '0') ?? 0;
          return interestA.compareTo(interestB);
        });
        break;
    }

    emit(CompaniesSortedState(
      companies: sortedCompanies,
      originalCompanies: originalCompanies,
    ));
  }

  // Utility Methods
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
        emit(ErrorState("Failed to launch URL: $e"));
      }
    } else {
      emit(ErrorState("Cannot launch URL: $url"));
    }
  }

  List<String> getCitiesForCountry(String? country) {
    final countryCityMap = currentCompany?.settings?.countryCityMap ?? {};
    return countryCityMap[country] ?? [];
  }

  // Report Page Methods
  Map<String, int> getFollowUpDataForYear(String? year) {
    final followUpData = {
      AppKeys.totalKey: originalCompanies.where((c) => getYearFromDate(c.dateCreated.toString()) == year).length,
      AppKeys.sentKey: originalCompanies.where((c) => getYearFromDate(c.dateCreated.toString()) == year && c.emailSent).length,
      AppKeys.notSentKey: originalCompanies.where((c) => getYearFromDate(c.dateCreated.toString()) == year && !c.emailSent).length,
    };
    emit(FollowUpDataLoadedState(followUpData));
    return followUpData;
  }

  ProgressChartData getProgressData(String? selectedYearForProgress) {
    final companies = originalCompanies.where((c) => getYearFromDate(c.dateCreated.toString()) == selectedYearForProgress).toList();

    List<int> data = List.generate(12, (index) {
      return companies.where((c) => c.dateCreated.month == index + 1).length;
    });

    final progressData = ProgressChartData(
      bars: List.generate(data.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              colors: [AppColors.blue],
              width: 20,
              borderRadius: BorderRadius.circular(6),
              y: data[index].toDouble(),
            ),
          ],
        );
      }),
      labels: AppKeys.monthLabels,
      maxValue: data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 1,
    );

    emit(ProgressDataLoadedState(progressData));
    return progressData;
  }

  Map<String, int> getComparisonData(String? period1, String? period2) {
    final comparisonData = {
      AppKeys.period1Key: _getCompanyCountForPeriod(period1),
      AppKeys.period2Key: _getCompanyCountForPeriod(period2),
    };
    emit(ComparisonDataLoadedState(comparisonData));
    return comparisonData;
  }

  List<String> getAvailableYears() {
    final years = originalCompanies
        .map((company) => getYearFromDate(company.dateCreated.toString()))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    emit(AvailableYearsLoadedState(years));
    return years;
  }

  List<String> getAvailablePeriods() {
    Set<String> periods = {};
    for (var company in originalCompanies) {
      periods.add(getYearFromDate(company.dateCreated.toString()));
      periods.add(getMonthYearFromDate(company.dateCreated.toString()));
      periods.add(getQuarterFromDate(company.dateCreated.toString()));
    }
    final periodList = periods.toList()..sort((a, b) => b.compareTo(a));
    emit(AvailablePeriodsLoadedState(periodList));
    return periodList;
  }

  void updateSelectedYearForFollowUp(String year) {
    emit(CompanyDataState(
      company: currentCompany,
      settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
      users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      selectedYearForFollowUp: year,
    ));
  }

  void updateSelectedYearForProgress(String year) {
    emit(CompanyDataState(
      company: currentCompany,
      settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
      users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      selectedYearForProgress: year,
    ));
  }

  void updateSelectedPeriod1(String period) {
    emit(CompanyDataState(
      company: currentCompany,
      settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
      users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      selectedPeriod1: period,
    ));
  }

  void updateSelectedPeriod2(String period) {
    emit(CompanyDataState(
      company: currentCompany,
      settings: state is CompanyDataState ? (state as CompanyDataState).settings : null,
      users: state is CompanyDataState ? (state as CompanyDataState).users : [],
      selectedPeriod2: period,
    ));
  }

  int _getCompanyCountForPeriod(String? period) {
    if (period == null || period.isEmpty) return 0;
    return originalCompanies.where((company) {
      return getYearFromDate(company.dateCreated.toString()) == period ||
          getMonthYearFromDate(company.dateCreated.toString()) == period ||
          getQuarterFromDate(company.dateCreated.toString()) == period;
    }).length;
  }
}

enum SortType { latest, oldest, highToLowInterest, lowToHighInterest }

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