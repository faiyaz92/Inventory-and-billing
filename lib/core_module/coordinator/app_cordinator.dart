import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.gr.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';

class AppCoordinator implements Coordinator {
  final AppRouter _router;

  AppCoordinator(this._router);

  @override
  void navigateToLoginPage() {
    _router.replace(LoginRoute()); // Replaces the current route with Login
  }

  @override
  void navigateToDashboardPage() {
    _router.replace(
        const DashboardRoute()); // Replaces the current route with Dashboard
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
    _router.push(const ReportRoute());
  }

  @override
  void navigateToCompanySettingsPage() {
    _router.push(const CompanySettingRoute());
  }

  @override
  void navigateToAddCompanyPage() {
    _router.push(AddCompanyRoute()); // AddCompanyPage navigation
  }

  @override
  void navigateToCompanyDetailsPage(Company company) {
    _router.push(CompanyDetailsRoute(
        company: company)); // Navigate to CompanyDetailsPage
  }

  @override
  void navigateToEditCompanyPage(Company? company) {
    _router.push(AddCompanyRoute(
        company: company)); // Navigate to AddCompanyPage with pre-filled data
  }

  @override
  void navigateToAiCompanyListPage() {
    _router.push(const AiCompanyListRoute()); // For the new AiCompanyListPage
  }

  @override
  void navigateToSuperAdminPage() {
    _router.push(const SuperAdminRoute()); // ✅ Navigation to Super Admin Page
  }

  @override
  void navigateToAddTenantCompanyPage({TenantCompany? company}) {
    _router.push(AddTenantCompanyRoute(
        company: company)); // ✅ Navigation to Add/Edit Tenant Company Page
  }

  @override
  void navigateToAddUserPage({UserInfo? user}) {
    _router.push(AddUserRoute(user: user));
  }

  @override
  void navigateToCompanyAdminPage() {
    _router.push(const CompanyAdminRoute());
  }

  @override
  void navigateToUserListPage() {
    _router.push(const UserListRoute());
  }

  @override
  void navigateToTaskListPage() {
    _router.push(const TaskListRoute());
  }

  @override
  Future<dynamic> navigateToAddTaskPage({TaskModel? task}) {
    return _router.push(AddTaskRoute(task: task));
  }

  @override
  void navigateToAccountLedgerPage({required Company company}) {
    _router.push(AccountLedgerRoute(company: company));
  }

  @override
  void navigateToCreateLedgerPage(String companyId, String customerCompanyId) {
    _router.push(CreateLedgerRoute(
      companyId: companyId,
      customerCompanyId: customerCompanyId,
    ));
  }

  @override
  Future<dynamic> navigateToProductListPage() {
    return _router.push(ProductListRoute());
  }

  @override
  Future<dynamic> navigateToAddEditProductPage({Product? product}) async {
    return _router.push(AddEditProductRoute(product: product));
  }

  @override
  void navigateToProductManagementPage() {
    _router.push(const ProductMgtRoute());
  }
  // 🔹 Add/Edit Category Navigation
  @override
  void navigateToAddEditCategoryPage({Category? category}) {
    _router.push(AddEditCategoryRoute(category: category));  // Navigate to Add/Edit Category page
  }

  // 🔹 Add/Edit Subcategory Navigation
  @override
  void navigateToAddEditSubcategoryPage({Subcategory? subcategory, required Category category}) {
    _router.push(AddEditSubcategoryRoute(subcategory: subcategory, category: category));  // Navigate to Add/Edit Subcategory page
  }

  @override
  Future<dynamic> navigateToCategoriesWithSubcategoriesPage() {
  return  _router.push(const CategoriesWithSubcategoriesRoute()); // Navigate to CategoriesWithSubcategoriesPage
  }
  @override
  void navigateBack({bool isUpdated = false}) {
    _router.pop(isUpdated);
  }
}
