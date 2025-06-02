import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/user_ledger_page.dart';
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
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/add_edit_task.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_company_user_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/attendance_register_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employee_details_view.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employee_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/simple_user_list.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/dashboard/dashboard_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/forgot_password_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_screen.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/presentation/ai_company_list_page.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_page.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/dashboard/super_admin_page.dart';
import 'package:requirment_gathering_app/taxi/taxi_admin_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_admin_panel_page.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_page.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_cubit.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_page.dart';
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

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashScreenRoute.page, initial: true),
        AutoRoute(page: DashboardRoute.page, path: '/dashboard'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
        AutoRoute(page: HomeRoute.page, path: '/home'),
        AutoRoute(page: CompanyListRoute.page, path: '/company-list'),
        // AutoRoute(page: ReportRoute.page, path: '/reports'),
        AutoRoute(page: CompanySettingRoute.page, path: '/settings'),
        AutoRoute(page: AddCompanyRoute.page, path: '/add-company'),
        AutoRoute(page: AddSupplierRoute.page, path: '/add-supplier'),
        AutoRoute(page: CompanyDetailsRoute.page, path: '/company-details'),
        AutoRoute(page: AiCompanyListRoute.page, path: '/ai-company-list'),
        AutoRoute(page: SuperAdminRoute.page, path: '/super-admin'),
        AutoRoute(
            page: AddTenantCompanyRoute.page, path: '/add-tenant-company'),
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
        AutoRoute(
            page: AddEditSubcategoryRoute.page, path: '/add-edit-subcategory'),
        AutoRoute(
            page: CategoriesWithSubcategoriesRoute.page,
            path: '/categories-with-subcategories'),
        AutoRoute(page: SupplierListRoute.page, path: '/supplierList'),
        AutoRoute(
            page: SupplierDetailsRoute.page, path: '/supplierDetailsPage'),
        AutoRoute(page: AttendanceRegisterRoute.page),
        AutoRoute(page: EmployeeDetailsRoute.page),
        AutoRoute(page: AddStockRoute.page),
        // AutoRoute(page: BillingRoute.page),
        AutoRoute(page: SalesReportRoute.page),
        AutoRoute(page: TransactionsRoute.page),
        AutoRoute(page: InventoryDashboardRoute.page),
        AutoRoute(page: StoresListRoute.page, path: '/storeListPage'),
        AutoRoute(
          page: AddStoreRoute.page,
        ),
        AutoRoute(
          page: StoreDetailsRoute.page,
        ),
        AutoRoute(
          page: StockListRoute.page,
        ),
        AutoRoute(
          page: OverallStockRoute.page,
        ),

        // Shopping Cart Routes
        // AutoRoute(page: ShoppingCartEntryRoute.page, path: '/shopping-cart-entry'),
        AutoRoute(page: CartHomeRoute.page, path: '/cart-home'),
        AutoRoute(page: CartRoute.page, path: '/cart'),
        AutoRoute(page: WishlistRoute.page, path: '/wishlist'),
        AutoRoute(page: OrderListRoute.page, path: '/order-list'),
        // AutoRoute(page: OrderDetailsRoute.page, path: '/order-details'),
        AutoRoute(page: CheckoutRoute.page, path: '/checkout'),
        AutoRoute(page: PreviewOrderRoute.page, path: '/preview-order'),
        AutoRoute(page: AdminPanelRoute.page, path: '/admin-panel'),
        AutoRoute(
            page: AdminOrderDetailsRoute.page, path: '/admin-order-details'),
        AutoRoute(
          page: CartDashboardRoute.page,
        ),
        AutoRoute(
          page: UserOrderDetailsRoute.page,
        ),
        AutoRoute(
          page: SalesmanOrderRoute.page,
        ),
        AutoRoute(
          page: SimpleEmployeesRoute.page,
        ),
        AutoRoute(
            page: SalesmanOrderListRoute.page, path: '/salesman-order-list'),
        AutoRoute(
            page: DeliveryManOrderListRoute.page,
            path: '/deliveryman-order-list'),
        AutoRoute(page: StoreOrderListRoute.page, path: '/store-order-list'),
        AutoRoute(
            page: CustomerOrderListRoute.page, path: '/customer-order-list'),
        AutoRoute(
            page: PerformanceDetailsRoute.page, path: '/performance-details'),
        AutoRoute(page: CompanyPerformanceRoute.page),
        AutoRoute(page: ProductTrendingListRoute.page),
        AutoRoute(page: UserLedgerRoute.page, path: '/user-ledger'),
        AutoRoute(
            page: PageInfo(TaxiBookingRoute.name, builder: (data) {
              return MultiBlocProvider(providers: [
                BlocProvider(
                  create: (context) => sl<TaxiBookingCubit>(),
                ),
                BlocProvider(
                  create: (context) => sl<TaxiSettingsCubit>(),
                ),
              ], child: const TaxiBookingPage());
            }),
            path: '/taxi-booking'),
        AutoRoute(
            page: PageInfo(TaxiSettingsRoute.name, builder: (data) {
              return BlocProvider(
                create: (context) => sl<TaxiSettingsCubit>(),
                child: const TaxiSettingsPage(),
              );
            }),
            path: '/taxi-settings'),
        AutoRoute(
            page: PageInfo(TaxiBookingsAdminRoute.name, builder: (data) {
              return BlocProvider(
                create: (context) => sl<TaxiAdminCubit>(),
                child: const TaxiBookingsAdminPage(),
              );
            }),
            path: '/taxi-bookings-admin'),
      ];
}
