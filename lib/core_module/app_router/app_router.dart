import 'package:auto_route/annotations.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/account_ledger_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/add_company_user_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/add_edit_task.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/company_admin_dashboard.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/create_account_ledger.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/task_list_page.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/user_list_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/dashboard_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/reports_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_screen.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/presentation/ai_company_list_page.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_page.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/dashboard/super_admin_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_list/company_details_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_list/company_list_page.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_settings/settings_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashScreen, initial: true),
    AutoRoute(page: DashboardPage, path: '/dashboard'),
    AutoRoute(page: LoginPage, path: '/login'),
    AutoRoute(page: HomePage, path: '/home'),
    AutoRoute(page: CompanyListPage, path: '/company-list'),
    AutoRoute(page: ReportPage, path: '/reports'),
    AutoRoute(page: CompanySettingPage, path: '/settings'),
    AutoRoute(page: AddCompanyPage, path: '/add-company'),
    // Added AddCompanyPage
    AutoRoute(page: CompanyDetailsPage, path: '/company-details'),
    // Added CompanyDetailsPage
    AutoRoute(page: AiCompanyListPage, path: '/ai-company-list'),
    // New route for AiCompanyListPage
    AutoRoute(page: SuperAdminPage, path: '/super-admin'),
    // ✅ Super Admin Page
    AutoRoute(page: AddTenantCompanyPage, path: '/add-tenant-company'),
    AutoRoute(page: AddUserPage, path: '/add-user'),
    AutoRoute(page: CompanyAdminPage, path: '/company-admin'), // ✅ New Page
    AutoRoute(page: UserListPage, path: '/user-list'), // ✅ New Page
    AutoRoute(page: TaskListPage, path: '/task-list'),
    AutoRoute(page: AddTaskPage, path: '/add-task'),
    AutoRoute(page: AccountLedgerPage, path: '/account-ledger'), // 🔥 Account Ledger Page
    AutoRoute(
      page: CreateLedgerPage,
      path: '/create-ledger/:companyId/:customerCompanyId',
    ),
  ],
)
class $AppRouter {}
