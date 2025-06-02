import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';

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
    _router.replace(SplashScreenRoute()); // Ensures splash replaces the stack
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
    // _router.push(const ReportRoute());
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
  void navigateToCompanyDetailsPage(Partner company) {
    _router.push(CompanyDetailsRoute(
        company: company)); // Navigate to CompanyDetailsPage
  }

  @override
  void navigateToEditCompanyPage(Partner? company) {
    _router.push(AddCompanyRoute(
        company: company)); // Navigate to AddCompanyPage with pre-filled data
  }

  @override
  void navigateToAddEditSupplierPage({Partner? company}) {
    _router.push(AddSupplierRoute(
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
    _router.push(const EmployeesRoute());
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
  void navigateToAccountLedgerPage({required Partner company}) {
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
    _router.push(AddEditCategoryRoute(
        category: category)); // Navigate to Add/Edit Category page
  }

  // 🔹 Add/Edit Subcategory Navigation
  @override
  void navigateToAddEditSubcategoryPage(
      {Subcategory? subcategory, required Category category}) {
    _router.push(AddEditSubcategoryRoute(
        subcategory: subcategory,
        category: category)); // Navigate to Add/Edit Subcategory page
  }

  @override
  Future<dynamic> navigateToCategoriesWithSubcategoriesPage() {
    return _router.push(
        const CategoriesWithSubcategoriesRoute()); // Navigate to CategoriesWithSubcategoriesPage
  }

  @override
  void navigateToSupplierListPage() {
    _router.push(const SupplierListRoute());
  }

  @override
  void navigateToSupplierDetailsPage(Partner company) {
    _router.push(SupplierDetailsRoute(company: company));
  }

  @override
  void navigateBack({bool isUpdated = false}) {
    _router.maybePop(isUpdated);
  }

  @override
  Future navigateToAttendancePage() {
    return _router.push(const AttendanceRegisterRoute());
  }

  @override
  Future navigateToEmployeeDetailsPage({String? userId}) {
    // TODO: implement navigateToEmployeeDetailsPage
    return _router.push(EmployeeDetailsRoute(userId: userId ?? ''));
  }

  @override
  Future navigateToForgotPasswordPage() {
    // TODO: implement navigateToForgotPasswordPage
    return _router.push(ForgotPasswordRoute());
  }

  @override
  Future navigateToAddCustomerPage() {
    // TODO: implement navigateToAddCustomerPage
    throw UnimplementedError();
  }

  @override
  Future navigateToAddStockPage() {
    // TODO: implement navigateToAddStockPage
    return _router.push(const AddStockRoute());
  }

  @override
  Future<void> navigateToBillingPage() {
    // TODO: implement navigateToBillingPage
    // return _router.push(const BillingRoute());
    return _router.push(const AddStockRoute()); //dummy
  }

  @override
  Future navigateToSalesReportPage() {
    // TODO: implement navigateToSalesReportPage
    return _router.push(const SalesReportRoute());
  }

  @override
  Future navigateToStockListPage() {
    // TODO: implement navigateToStockListPage
    return _router.push(const StockListRoute());
  }

  @override
  Future navigateToTransactionsPage() {
    // TODO: implement navigateToTransactionsPage
    return _router.push(const TransactionsRoute());
  }

  @override
  Future navigateToInventoryDashBoard() {
    // TODO: implement navigateToInventoryDashBoard
    return _router.push(const InventoryDashboardRoute());
  }

  @override
  Future navigateToStoresListPage() {
    // TODO: implement navigateToStoresListPage
    return _router.push(const StoresListRoute());
  }

  @override
  Future navigateToAddStorePage() {
    // TODO: implement navigateToAddStorePagr
    return _router.push(const AddStoreRoute());
  }

  @override
  Future navigateToStoreDetailsPage(String? storeId) {
    // TODO: implement navigateToStoreDetailsPage
    return _router.push(StoreDetailsRoute(storeId: storeId ?? ''));
  }

  @override
  Future navigateToOverAllStockPage() {
    // TODO: implement navigateToOverAllStockPage
    return _router.push(const OverallStockRoute());
  }

  @override
  Future<dynamic> navigateToWishlistPage() {
    return _router.push(const WishlistRoute());
  }

  @override
  Future<dynamic> navigateToCartPage() {
    return _router.push(const CartRoute());
  }

  @override
  Future<dynamic> navigateToOrderListPage() {
    return _router.push(const OrderListRoute());
  }

  @override
  Future<dynamic> navigateToSettingsPage() {
    // _router.push(const SettingsRoute());
    return _router.push(const OrderListRoute());
  }

  @override
  Future<dynamic> navigateToShoppingCartEntryPage() {
    // _router.push(const ShoppingCartEntryRoute());
    return _router.push(const OrderListRoute());
  }

  @override
  Future<dynamic> navigateToCartHomePage() {
    return _router.push(const CartHomeRoute());
  }

  @override
  Future<dynamic> navigateToCheckoutPage() {
    return _router.push(const CheckoutRoute());
  }

  @override
  Future<dynamic> navigateToPreviewOrderPage() {
    return _router.push(const PreviewOrderRoute());
  }

  @override
  Future<dynamic> navigateToAdminPanelPage() {
    return _router.push(const AdminPanelRoute());
  }

  @override
  Future<dynamic> navigateToAdminOrderDetailsPage(String? orderId) {
    return _router.push(AdminOrderDetailsRoute(orderId: orderId ?? ''));
  }

  @override
  Future<dynamic> navigateToUserOrderDetailsPage(String? orderId) {
    return _router.push(UserOrderDetailsRoute(orderId: orderId ?? ''));
  }

  @override
  Future navigateToCartDashboard() {
    // TODO: implement navigateToCartDashboard
    return _router.push(const CartDashboardRoute());
  }

  @override
  Future navigateToSalesManOrderPage() {
    // TODO: implement navigateToSalesManOrderPage
    return _router.push(const SalesmanOrderRoute());
  }

  @override
  Future navigateToSimpleEmployeeList() {
    // TODO: implement navigateToSimpleEmployeeList
    return _router.push(const SimpleEmployeesRoute());
  }

  @override
  Future<dynamic> navigateToSalesmanOrderListPage() =>
      _router.push(const SalesmanOrderListRoute());

  @override
  Future<dynamic> navigateToDeliveryManOrderListPage() =>
      _router.push(const DeliveryManOrderListRoute());

  @override
  Future<dynamic> navigateToStoreOrderListPage() =>
      _router.push(const StoreOrderListRoute());

  @override
  Future<dynamic> navigateToCustomerOrderListPage() =>
      _router.push(const CustomerOrderListRoute());

  @override
  Future<dynamic> navigateToPerformanceDetailsPage(
          {required String entityType, required String entityId}) =>
      _router.push(
          PerformanceDetailsRoute(entityType: entityType, entityId: entityId));

  @override
  Future<dynamic> navigateToCompanyPerformancePage() =>
      _router.push(const CompanyPerformanceRoute());@override
  Future<dynamic> navigateToProductPerformanceListPage() =>
      _router.push(const ProductTrendingListRoute());
  // File: core_module/coordinator/app_coordinator.dart
  @override
  Future<dynamic> navigateToUserLedgerPage({required UserInfo user}) {
    return _router.push(UserLedgerRoute(user: user));
  }
  @override
  Future<dynamic> navigateToTaxiBookingPage() {
    return _router.push(const TaxiBookingRoute());
  }

  @override
  Future<dynamic> navigateToTaxiSettingsPage() {
    return _router.push(const TaxiSettingsRoute());
  }

  @override
  Future<dynamic> navigateToTaxiBookingsAdminPage() {
    return _router.push(const TaxiBookingsAdminRoute());
  }
}
