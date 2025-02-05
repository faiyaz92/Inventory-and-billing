  import 'package:auto_route/annotations.dart';
import 'package:requirment_gathering_app/ai_module/ai_company_list_page.dart';
  import 'package:requirment_gathering_app/dashboard/home/company_details_page.dart';
  import 'package:requirment_gathering_app/dashboard/home/company_list_page.dart';
  import 'package:requirment_gathering_app/dashboard/home/add_company_page.dart';
  import 'package:requirment_gathering_app/dashboard/home/home_page.dart';
  import 'package:requirment_gathering_app/dashboard/reports_page.dart';
  import 'package:requirment_gathering_app/dashboard/settings_page.dart';
  import 'package:requirment_gathering_app/dashboard/home/dashboard_page.dart';
  import 'package:requirment_gathering_app/login/login_page.dart';
  import 'package:requirment_gathering_app/login/splash_screen.dart';

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
      AutoRoute(page: AddCompanyPage, path: '/add-company'), // Added AddCompanyPage
      AutoRoute(page: CompanyDetailsPage, path: '/company-details'), // Added CompanyDetailsPage
      AutoRoute(page: AiCompanyListPage, path: '/ai-company-list'), // New route for AiCompanyListPage

    ],
  )
  class $AppRouter {}
