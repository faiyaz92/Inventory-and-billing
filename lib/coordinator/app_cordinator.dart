import 'package:requirment_gathering_app/app_router/app_router.gr.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/data/company.dart';

class AppCoordinator implements Coordinator {
  final AppRouter _router;

  AppCoordinator(this._router);

  @override
  void navigateToLoginPage() {
    _router.replace(LoginRoute()); // Replaces the current route with Login
  }

  @override
  void navigateToDashboardPage() {
    _router.replace(const DashboardRoute()); // Replaces the current route with Dashboard
  }

  @override
  void navigateToSplashScreen() {
    _router.replace(SplashScreen()); // Ensures splash replaces the stack
  }

  @override
  void navigateToHomePage() {
    _router.push(const HomeRoute());
  }

  @override
  void navigateToCompanyListPage() {
    _router.push(const CompanyListRoute());
  }

  @override
  void navigateToReportsPage() {
    _router.push(const ReportsRoute());
  }

  @override
  void navigateToCompanySettingsPage() {
    _router.push(const CompanySettingRoute());
  }

  @override
  void navigateToAddCompanyPage() {
    _router.push(const AddCompanyRoute()); // AddCompanyPage navigation
  }
  @override
  void navigateToCompanyDetailsPage(Company company) {
    _router.push(CompanyDetailsRoute(company: company)); // Navigate to CompanyDetailsPage
  }

  @override
  void navigateToEditCompanyPage(Company company) {
    // _router.push(AddCompanyRoute(company: company)); // Navigate to AddCompanyPage with pre-filled data
  }
  @override
  void navigateBack() {
    _router.pop();
  }
}
