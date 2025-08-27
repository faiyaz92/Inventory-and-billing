import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/accounts/accounts_dashboard.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/accounts/admin_invoice_panel_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/analytics/analytics_dashboard.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/analytics/statics_dashboard.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/bill_pdf.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/billing_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/quick_pay_recieve.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_page.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/sub_category.dart';
import 'package:requirment_gathering_app/company_admin_module/data/task/task_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/company_admin_dashboard.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/add_stock_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/add_store_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/inventory_dashboard_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/over_stock_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/sales_report_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/store_details_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/store_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/create_account_ledger.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_product_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_sub_category_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/category_sub_category_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/dashboard/product_mgt_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/purchase/purchase_invoices.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/add_edit_task.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_company_user_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/attendance_register_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employee_details_view.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employee_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/simple_user_list.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/dashboard/dashboard_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/forgot_password_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/profile_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_screen.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/presentation/ai_company_list_page.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_page.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/dashboard/super_admin_page.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_details_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_panel_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_dashboard_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_home_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/check_out_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/company_performance_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/customer_order_list_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/deliveryman_order_list_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_list_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/performance_details_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/place_order_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/product_trending_list_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/sales_man_order_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/salesman_order_list_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/store_order_list_page.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/user_order_details.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/wish_list_page.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_list/company_details_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_list/company_list_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_settings/settings_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/suppliers/add_supplier_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/suppliers/supplier_details_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/suppliers/supplier_list_page.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart'; // Import UserType

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
      @override
      List<AutoRoute> get routes => [
            AutoRoute(page: SplashScreenRoute.page, initial: true),
            AutoRoute(page: DashboardRoute.page, path: '/dashboard'),
            AutoRoute(page: LoginRoute.page, path: '/login'),
            AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
            AutoRoute(page: HomeRoute.page, path: '/home'),
            AutoRoute(page: CompanyListRoute.page, path: '/company-list'),
            AutoRoute(page: CompanySettingRoute.page, path: '/settings'),
            AutoRoute(page: AddCompanyRoute.page, path: '/add-company'),
            AutoRoute(page: AddSupplierRoute.page, path: '/add-supplier'),
            AutoRoute(page: CompanyDetailsRoute.page, path: '/company-details'),
            AutoRoute(page: AiCompanyListRoute.page, path: '/ai-company-list'),
            AutoRoute(page: SuperAdminRoute.page, path: '/super-admin'),
            AutoRoute(page: AddTenantCompanyRoute.page, path: '/add-tenant-company'),
            AutoRoute(page: AddUserRoute.page, path: '/add-user'),
            AutoRoute(page: CompanyAdminRoute.page, path: '/company-admin'),
            AutoRoute(page: EmployeesRoute.page, path: '/user-list'),
            AutoRoute(page: TaskListRoute.page, path: '/task-list'),
            AutoRoute(page: AddTaskRoute.page, path: '/add-task'),
            AutoRoute(page: AccountLedgerRoute.page, path: '/account-ledger'),
            AutoRoute(
                  page: CreateLedgerRoute.page,
                  path: '/create-ledger/:companyId/:customerCompanyId',
            ),
            AutoRoute(page: ProductListRoute.page, path: '/product-list'),
            AutoRoute(page: AddEditProductRoute.page, path: '/add-edit-product'),
            AutoRoute(page: ProductMgtRoute.page, path: '/manage-product'),
            AutoRoute(page: AddEditCategoryRoute.page, path: '/add-edit-category'),
            AutoRoute(page: AddEditSubcategoryRoute.page, path: '/add-edit-subcategory'),
            AutoRoute(page: CategoriesWithSubcategoriesRoute.page, path: '/categories-with-subcategories'),
            AutoRoute(page: SupplierListRoute.page, path: '/supplierList'),
            AutoRoute(page: SupplierDetailsRoute.page, path: '/supplierDetailsPage'),
            AutoRoute(page: AttendanceRegisterRoute.page),
            AutoRoute(page: EmployeeDetailsRoute.page),
            AutoRoute(page: AddStockRoute.page),
            AutoRoute(page: SalesReportRoute.page),
            AutoRoute(page: TransactionsRoute.page),
            AutoRoute(page: InventoryDashboardRoute.page),
            AutoRoute(page: StoresListRoute.page, path: '/storeListPage'),
            AutoRoute(page: AddStoreRoute.page),
            AutoRoute(page: StoreDetailsRoute.page),
            AutoRoute(page: StockListRoute.page),
            AutoRoute(page: OverallStockRoute.page),
            AutoRoute(page: CartHomeRoute.page, path: '/cart-home'),
            AutoRoute(page: CartRoute.page, path: '/cart'),
            AutoRoute(page: WishlistRoute.page, path: '/wishlist'),
            AutoRoute(page: OrderListRoute.page, path: '/order-list'),
            AutoRoute(page: CheckoutRoute.page, path: '/checkout'),
            AutoRoute(page: PreviewOrderRoute.page, path: '/preview-order'),
            AutoRoute(page: AdminPanelRoute.page, path: '/admin-panel'),
            AutoRoute(page: AdminOrderDetailsRoute.page, path: '/admin-order-details'),
            AutoRoute(page: CartDashboardRoute.page),
            AutoRoute(page: UserOrderDetailsRoute.page),
            AutoRoute(page: SalesmanOrderRoute.page),
            AutoRoute(page: SimpleUsersRoute.page, path: '/simple-user-list'), // Updated to support UserType
            AutoRoute(page: SalesmanOrderListRoute.page, path: '/salesman-order-list'),
            AutoRoute(page: DeliveryManOrderListRoute.page, path: '/deliveryman-order-list'),
            AutoRoute(page: StoreOrderListRoute.page, path: '/store-order-list'),
            AutoRoute(page: CustomerOrderListRoute.page, path: '/customer-order-list'),
            AutoRoute(page: PerformanceDetailsRoute.page, path: '/performance-details'),
            AutoRoute(page: CompanyPerformanceRoute.page),
            AutoRoute(page: ProductTrendingListRoute.page),
            AutoRoute(page: UserLedgerRoute.page, path: '/user-ledger'),
            AutoRoute(page: BillingRoute.page, path: '/billing'),
            AutoRoute(page: BillPdfRoute.page, path: '/bill-pdf'),
            AutoRoute(page: AccountsDashboardRoute.page, path: '/accounts-dashboard'), // New route
            AutoRoute(page: AdminInvoicePanelRoute.page, path: '/invoice-list'),
            AutoRoute(page: AnalyticsRoute.page, path: '/analytics'),
            AutoRoute(page: QuickTransactionRoute.page, path: '/quick-transaction'),
            AutoRoute(page: PurchaseInvoicePanelRoute.page, path: '/purchase-invoice-panel'),
            AutoRoute(page: DashboardStaticsRoute.page, path: '/dashboard-statics'),// Add this line
      ];
}