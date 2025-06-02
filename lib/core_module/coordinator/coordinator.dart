import 'package:flutter/src/widgets/framework.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';

abstract class Coordinator {
  void navigateToLoginPage();

  void navigateToDashboardPage();

  void navigateToSplashScreen();

  void navigateToHomePage();

  void navigateToCompanyListPage(); // For existing CompanyListPage
  void navigateToAiCompanyListPage(); // For AiCompanyListPage
  void navigateToReportsPage();

  void navigateToCompanySettingsPage();

  void navigateToAddCompanyPage();

  void navigateToCompanyDetailsPage(Partner company);

  void navigateToEditCompanyPage(Partner? company);

  void navigateBack({bool isUpdated});

  // 🔹 Super Admin Navigation
  void navigateToSuperAdminPage();

  // 🔹 Add & Edit Tenant Company Navigation
  void navigateToAddTenantCompanyPage({TenantCompany? company});

  void navigateToAddUserPage({UserInfo? user});

  void navigateToCompanyAdminPage();

  void navigateToUserListPage();

  void navigateToTaskListPage();

  Future<dynamic> navigateToAddTaskPage({TaskModel? task});

  void navigateToAccountLedgerPage({required Partner company});

  void navigateToCreateLedgerPage(String companyId, String customerCompanyId);

  // ✅ New Product Navigation Methods
  void navigateToProductListPage();

  Future<dynamic> navigateToAddEditProductPage({Product? product});

  // 🔹 Add Edit Category/Subcategory Navigation Methods
  void navigateToAddEditCategoryPage({Category? category});

  void navigateToAddEditSubcategoryPage(
      {Subcategory? subcategory, required Category category});

  void navigateToProductManagementPage();

  Future<dynamic>
      navigateToCategoriesWithSubcategoriesPage(); // Add this line for the new page.
  void navigateToSupplierListPage(); // For SupplierListPage

  void navigateToSupplierDetailsPage(Partner company);
  void navigateToAddEditSupplierPage({Partner? company});
  Future<dynamic> navigateToAttendancePage();
  Future<dynamic> navigateToEmployeeDetailsPage({String? userId});
  Future<dynamic> navigateToForgotPasswordPage();

  Future<dynamic> navigateToStockListPage();


   Future<dynamic> navigateToBillingPage();

   Future<dynamic> navigateToSalesReportPage();

   Future<dynamic> navigateToTransactionsPage() ;

   Future<dynamic> navigateToAddCustomerPage() ;

   Future<dynamic> navigateToAddStockPage() ;
   Future<dynamic> navigateToInventoryDashBoard() ;
   Future<dynamic> navigateToStoresListPage() ;
   Future<dynamic> navigateToAddStorePage() ;
   Future<dynamic> navigateToStoreDetailsPage(String? storeId) ;
   Future<dynamic> navigateToOverAllStockPage() ;

  Future<dynamic> navigateToWishlistPage();
  Future<dynamic> navigateToCartPage();
  Future<dynamic> navigateToOrderListPage();
  Future<dynamic> navigateToSettingsPage();
  Future<dynamic> navigateToShoppingCartEntryPage();
  Future<dynamic> navigateToCartHomePage();
  Future<dynamic> navigateToCheckoutPage();
  Future<dynamic> navigateToPreviewOrderPage();
  Future<dynamic> navigateToAdminPanelPage();
  Future<dynamic> navigateToAdminOrderDetailsPage(String? orderId);
  Future<dynamic> navigateToUserOrderDetailsPage(String? orderId);
  Future<dynamic> navigateToCartDashboard();
  Future<dynamic> navigateToSalesManOrderPage();
  Future<dynamic> navigateToSimpleEmployeeList();
  // New Navigation Methods
  Future<dynamic> navigateToSalesmanOrderListPage();
  Future<dynamic> navigateToDeliveryManOrderListPage();
  Future<dynamic> navigateToStoreOrderListPage();
  Future<dynamic> navigateToCustomerOrderListPage();
  Future<dynamic> navigateToPerformanceDetailsPage({required String entityType, required String entityId});
  Future<dynamic> navigateToCompanyPerformancePage();
  Future<dynamic> navigateToProductPerformanceListPage();
  Future<dynamic> navigateToUserLedgerPage({required UserInfo user});
  Future<dynamic> navigateToTaxiBookingPage();
  Future<dynamic> navigateToTaxiSettingsPage();
  Future<dynamic> navigateToTaxiBookingsAdminPage();
}
