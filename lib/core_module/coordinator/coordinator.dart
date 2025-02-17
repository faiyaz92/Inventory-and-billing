import 'package:requirment_gathering_app/company_admin_module/data/task_model.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';

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
  // 🔹 Super Admin Navigation
  void navigateToSuperAdminPage();

  // 🔹 Add & Edit Tenant Company Navigation
  void navigateToAddTenantCompanyPage({TenantCompany? company});
  void navigateToAddUserPage({UserInfo? user});
  void navigateToCompanyAdminPage();
  void navigateToUserListPage();
  void navigateToTaskListPage();
  void navigateToAddTaskPage({TaskModel? task});
  void navigateToAccountLedgerPage({required String companyId, required String customerCompanyId});
  void navigateToCreateLedgerPage(String companyId, String customerCompanyId);
}
