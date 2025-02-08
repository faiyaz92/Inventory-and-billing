import 'package:requirment_gathering_app/data/company.dart';

abstract class Coordinator {
  void navigateToLoginPage();
  void navigateToDashboardPage();
  void navigateToSplashScreen();
  void navigateToHomePage();
  void navigateToCompanyListPage();  // For existing CompanyListPage
  void navigateToAiCompanyListPage();  // For AiCompanyListPage
  void navigateToReportsPage();
  void navigateToCompanySettingsPage();
  void navigateToAddCompanyPage();
  void navigateToCompanyDetailsPage(Company company);
  void navigateToEditCompanyPage(Company? company);
  void navigateBack();
}
