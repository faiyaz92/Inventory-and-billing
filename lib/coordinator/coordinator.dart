import 'package:requirment_gathering_app/data/company.dart';

abstract class Coordinator {
  void navigateToLoginPage();
  void navigateToDashboardPage();
  void navigateToSplashScreen();
  void navigateToHomePage();
  void navigateToCompanyListPage();
  void navigateToReportsPage();
  void navigateToCompanySettingsPage();
  void navigateToAddCompanyPage();
  void navigateToCompanyDetailsPage(Company company); // New method for navigating to company details
  void navigateToEditCompanyPage(Company? company); // New method for navigating to edit company page
  void navigateBack();
}
