// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i22;

import 'package:auto_route/auto_route.dart' as _i20;
import 'package:flutter/material.dart' as _i21;

import '../../company_admin_module/data/task_model.dart' as _i26;
import '../../company_admin_module/presentation/account_ledger_page.dart'
    as _i18;
import '../../company_admin_module/presentation/add_company_user_page.dart'
    as _i13;
import '../../company_admin_module/presentation/add_edit_task.dart' as _i17;
import '../../company_admin_module/presentation/company_admin_dashboard.dart'
    as _i14;
import '../../company_admin_module/presentation/create_account_ledger.dart'
    as _i19;
import '../../company_admin_module/presentation/task_list_page.dart' as _i16;
import '../../company_admin_module/presentation/user_list_page.dart' as _i15;
import '../../super_admin_module/ai_module/presentation/ai_company_list_page.dart'
    as _i10;
import '../../super_admin_module/data/tenant_company.dart' as _i24;
import '../../super_admin_module/data/user_info.dart' as _i25;
import '../../super_admin_module/presentation/add_tenant_company/add_tenant_company_page.dart'
    as _i12;
import '../../super_admin_module/presentation/dashboard/super_admin_page.dart'
    as _i11;
import '../../user_module/data/company.dart' as _i23;
import '../../user_module/presentation/add_company/add_company_page.dart'
    as _i8;
import '../../user_module/presentation/company_list/company_details_page.dart'
    as _i9;
import '../../user_module/presentation/company_list/company_list_page.dart'
    as _i5;
import '../../user_module/presentation/company_settings/settings_page.dart'
    as _i7;
import '../presentation/dashboard/home/dashboard_page.dart' as _i2;
import '../presentation/dashboard/home/home_page.dart' as _i4;
import '../presentation/dashboard/home/reports_page.dart' as _i6;
import '../presentation/login/login_page.dart' as _i3;
import '../presentation/login/splash_screen.dart' as _i1;

class AppRouter extends _i20.RootStackRouter {
  AppRouter([_i21.GlobalKey<_i21.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i20.PageFactory> pagesMap = {
    SplashScreen.name: (routeData) {
      final args = routeData.argsAs<SplashScreenArgs>(
          orElse: () => const SplashScreenArgs());
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i1.SplashScreen(
          key: args.key,
          onDelayComplete: args.onDelayComplete,
        ),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>(
          orElse: () => const LoginRouteArgs());
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i3.LoginPage(key: args.key),
      );
    },
    HomeRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.HomePage(),
      );
    },
    CompanyListRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.CompanyListPage(),
      );
    },
    ReportRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.ReportPage(),
      );
    },
    CompanySettingRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.CompanySettingPage(),
      );
    },
    AddCompanyRoute.name: (routeData) {
      final args = routeData.argsAs<AddCompanyRouteArgs>(
          orElse: () => const AddCompanyRouteArgs());
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i8.AddCompanyPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
    CompanyDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CompanyDetailsRouteArgs>();
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i9.CompanyDetailsPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
    AiCompanyListRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i10.AiCompanyListPage(),
      );
    },
    SuperAdminRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i11.SuperAdminPage(),
      );
    },
    AddTenantCompanyRoute.name: (routeData) {
      final args = routeData.argsAs<AddTenantCompanyRouteArgs>(
          orElse: () => const AddTenantCompanyRouteArgs());
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i12.AddTenantCompanyPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
    AddUserRoute.name: (routeData) {
      final args = routeData.argsAs<AddUserRouteArgs>(
          orElse: () => const AddUserRouteArgs());
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.AddUserPage(
          key: args.key,
          user: args.user,
        ),
      );
    },
    CompanyAdminRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i14.CompanyAdminPage(),
      );
    },
    UserListRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i15.UserListPage(),
      );
    },
    TaskListRoute.name: (routeData) {
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i16.TaskListPage(),
      );
    },
    AddTaskRoute.name: (routeData) {
      final args = routeData.argsAs<AddTaskRouteArgs>(
          orElse: () => const AddTaskRouteArgs());
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i17.AddTaskPage(
          key: args.key,
          task: args.task,
        ),
      );
    },
    AccountLedgerRoute.name: (routeData) {
      final args = routeData.argsAs<AccountLedgerRouteArgs>();
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i18.AccountLedgerPage(
          key: args.key,
          companyId: args.companyId,
          customerCompanyId: args.customerCompanyId,
        ),
      );
    },
    CreateLedgerRoute.name: (routeData) {
      final args = routeData.argsAs<CreateLedgerRouteArgs>();
      return _i20.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i19.CreateLedgerPage(
          key: args.key,
          companyId: args.companyId,
          customerCompanyId: args.customerCompanyId,
        ),
      );
    },
  };

  @override
  List<_i20.RouteConfig> get routes => [
        _i20.RouteConfig(
          SplashScreen.name,
          path: '/',
        ),
        _i20.RouteConfig(
          DashboardRoute.name,
          path: '/dashboard',
        ),
        _i20.RouteConfig(
          LoginRoute.name,
          path: '/login',
        ),
        _i20.RouteConfig(
          HomeRoute.name,
          path: '/home',
        ),
        _i20.RouteConfig(
          CompanyListRoute.name,
          path: '/company-list',
        ),
        _i20.RouteConfig(
          ReportRoute.name,
          path: '/reports',
        ),
        _i20.RouteConfig(
          CompanySettingRoute.name,
          path: '/settings',
        ),
        _i20.RouteConfig(
          AddCompanyRoute.name,
          path: '/add-company',
        ),
        _i20.RouteConfig(
          CompanyDetailsRoute.name,
          path: '/company-details',
        ),
        _i20.RouteConfig(
          AiCompanyListRoute.name,
          path: '/ai-company-list',
        ),
        _i20.RouteConfig(
          SuperAdminRoute.name,
          path: '/super-admin',
        ),
        _i20.RouteConfig(
          AddTenantCompanyRoute.name,
          path: '/add-tenant-company',
        ),
        _i20.RouteConfig(
          AddUserRoute.name,
          path: '/add-user',
        ),
        _i20.RouteConfig(
          CompanyAdminRoute.name,
          path: '/company-admin',
        ),
        _i20.RouteConfig(
          UserListRoute.name,
          path: '/user-list',
        ),
        _i20.RouteConfig(
          TaskListRoute.name,
          path: '/task-list',
        ),
        _i20.RouteConfig(
          AddTaskRoute.name,
          path: '/add-task',
        ),
        _i20.RouteConfig(
          AccountLedgerRoute.name,
          path: '/account-ledger',
        ),
        _i20.RouteConfig(
          CreateLedgerRoute.name,
          path: '/create-ledger/:companyId/:customerCompanyId',
        ),
      ];
}

/// generated route for
/// [_i1.SplashScreen]
class SplashScreen extends _i20.PageRouteInfo<SplashScreenArgs> {
  SplashScreen({
    _i21.Key? key,
    _i22.Future<void> Function()? onDelayComplete,
  }) : super(
          SplashScreen.name,
          path: '/',
          args: SplashScreenArgs(
            key: key,
            onDelayComplete: onDelayComplete,
          ),
        );

  static const String name = 'SplashScreen';
}

class SplashScreenArgs {
  const SplashScreenArgs({
    this.key,
    this.onDelayComplete,
  });

  final _i21.Key? key;

  final _i22.Future<void> Function()? onDelayComplete;

  @override
  String toString() {
    return 'SplashScreenArgs{key: $key, onDelayComplete: $onDelayComplete}';
  }
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardRoute extends _i20.PageRouteInfo<void> {
  const DashboardRoute()
      : super(
          DashboardRoute.name,
          path: '/dashboard',
        );

  static const String name = 'DashboardRoute';
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i20.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({_i21.Key? key})
      : super(
          LoginRoute.name,
          path: '/login',
          args: LoginRouteArgs(key: key),
        );

  static const String name = 'LoginRoute';
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final _i21.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i20.PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/home',
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i5.CompanyListPage]
class CompanyListRoute extends _i20.PageRouteInfo<void> {
  const CompanyListRoute()
      : super(
          CompanyListRoute.name,
          path: '/company-list',
        );

  static const String name = 'CompanyListRoute';
}

/// generated route for
/// [_i6.ReportPage]
class ReportRoute extends _i20.PageRouteInfo<void> {
  const ReportRoute()
      : super(
          ReportRoute.name,
          path: '/reports',
        );

  static const String name = 'ReportRoute';
}

/// generated route for
/// [_i7.CompanySettingPage]
class CompanySettingRoute extends _i20.PageRouteInfo<void> {
  const CompanySettingRoute()
      : super(
          CompanySettingRoute.name,
          path: '/settings',
        );

  static const String name = 'CompanySettingRoute';
}

/// generated route for
/// [_i8.AddCompanyPage]
class AddCompanyRoute extends _i20.PageRouteInfo<AddCompanyRouteArgs> {
  AddCompanyRoute({
    _i21.Key? key,
    _i23.Company? company,
  }) : super(
          AddCompanyRoute.name,
          path: '/add-company',
          args: AddCompanyRouteArgs(
            key: key,
            company: company,
          ),
        );

  static const String name = 'AddCompanyRoute';
}

class AddCompanyRouteArgs {
  const AddCompanyRouteArgs({
    this.key,
    this.company,
  });

  final _i21.Key? key;

  final _i23.Company? company;

  @override
  String toString() {
    return 'AddCompanyRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i9.CompanyDetailsPage]
class CompanyDetailsRoute extends _i20.PageRouteInfo<CompanyDetailsRouteArgs> {
  CompanyDetailsRoute({
    _i21.Key? key,
    required _i23.Company company,
  }) : super(
          CompanyDetailsRoute.name,
          path: '/company-details',
          args: CompanyDetailsRouteArgs(
            key: key,
            company: company,
          ),
        );

  static const String name = 'CompanyDetailsRoute';
}

class CompanyDetailsRouteArgs {
  const CompanyDetailsRouteArgs({
    this.key,
    required this.company,
  });

  final _i21.Key? key;

  final _i23.Company company;

  @override
  String toString() {
    return 'CompanyDetailsRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i10.AiCompanyListPage]
class AiCompanyListRoute extends _i20.PageRouteInfo<void> {
  const AiCompanyListRoute()
      : super(
          AiCompanyListRoute.name,
          path: '/ai-company-list',
        );

  static const String name = 'AiCompanyListRoute';
}

/// generated route for
/// [_i11.SuperAdminPage]
class SuperAdminRoute extends _i20.PageRouteInfo<void> {
  const SuperAdminRoute()
      : super(
          SuperAdminRoute.name,
          path: '/super-admin',
        );

  static const String name = 'SuperAdminRoute';
}

/// generated route for
/// [_i12.AddTenantCompanyPage]
class AddTenantCompanyRoute
    extends _i20.PageRouteInfo<AddTenantCompanyRouteArgs> {
  AddTenantCompanyRoute({
    _i21.Key? key,
    _i24.TenantCompany? company,
  }) : super(
          AddTenantCompanyRoute.name,
          path: '/add-tenant-company',
          args: AddTenantCompanyRouteArgs(
            key: key,
            company: company,
          ),
        );

  static const String name = 'AddTenantCompanyRoute';
}

class AddTenantCompanyRouteArgs {
  const AddTenantCompanyRouteArgs({
    this.key,
    this.company,
  });

  final _i21.Key? key;

  final _i24.TenantCompany? company;

  @override
  String toString() {
    return 'AddTenantCompanyRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i13.AddUserPage]
class AddUserRoute extends _i20.PageRouteInfo<AddUserRouteArgs> {
  AddUserRoute({
    _i21.Key? key,
    _i25.UserInfo? user,
  }) : super(
          AddUserRoute.name,
          path: '/add-user',
          args: AddUserRouteArgs(
            key: key,
            user: user,
          ),
        );

  static const String name = 'AddUserRoute';
}

class AddUserRouteArgs {
  const AddUserRouteArgs({
    this.key,
    this.user,
  });

  final _i21.Key? key;

  final _i25.UserInfo? user;

  @override
  String toString() {
    return 'AddUserRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [_i14.CompanyAdminPage]
class CompanyAdminRoute extends _i20.PageRouteInfo<void> {
  const CompanyAdminRoute()
      : super(
          CompanyAdminRoute.name,
          path: '/company-admin',
        );

  static const String name = 'CompanyAdminRoute';
}

/// generated route for
/// [_i15.UserListPage]
class UserListRoute extends _i20.PageRouteInfo<void> {
  const UserListRoute()
      : super(
          UserListRoute.name,
          path: '/user-list',
        );

  static const String name = 'UserListRoute';
}

/// generated route for
/// [_i16.TaskListPage]
class TaskListRoute extends _i20.PageRouteInfo<void> {
  const TaskListRoute()
      : super(
          TaskListRoute.name,
          path: '/task-list',
        );

  static const String name = 'TaskListRoute';
}

/// generated route for
/// [_i17.AddTaskPage]
class AddTaskRoute extends _i20.PageRouteInfo<AddTaskRouteArgs> {
  AddTaskRoute({
    _i21.Key? key,
    _i26.TaskModel? task,
  }) : super(
          AddTaskRoute.name,
          path: '/add-task',
          args: AddTaskRouteArgs(
            key: key,
            task: task,
          ),
        );

  static const String name = 'AddTaskRoute';
}

class AddTaskRouteArgs {
  const AddTaskRouteArgs({
    this.key,
    this.task,
  });

  final _i21.Key? key;

  final _i26.TaskModel? task;

  @override
  String toString() {
    return 'AddTaskRouteArgs{key: $key, task: $task}';
  }
}

/// generated route for
/// [_i18.AccountLedgerPage]
class AccountLedgerRoute extends _i20.PageRouteInfo<AccountLedgerRouteArgs> {
  AccountLedgerRoute({
    _i21.Key? key,
    required String companyId,
    required String customerCompanyId,
  }) : super(
          AccountLedgerRoute.name,
          path: '/account-ledger',
          args: AccountLedgerRouteArgs(
            key: key,
            companyId: companyId,
            customerCompanyId: customerCompanyId,
          ),
        );

  static const String name = 'AccountLedgerRoute';
}

class AccountLedgerRouteArgs {
  const AccountLedgerRouteArgs({
    this.key,
    required this.companyId,
    required this.customerCompanyId,
  });

  final _i21.Key? key;

  final String companyId;

  final String customerCompanyId;

  @override
  String toString() {
    return 'AccountLedgerRouteArgs{key: $key, companyId: $companyId, customerCompanyId: $customerCompanyId}';
  }
}

/// generated route for
/// [_i19.CreateLedgerPage]
class CreateLedgerRoute extends _i20.PageRouteInfo<CreateLedgerRouteArgs> {
  CreateLedgerRoute({
    _i21.Key? key,
    required String companyId,
    required String customerCompanyId,
  }) : super(
          CreateLedgerRoute.name,
          path: '/create-ledger/:companyId/:customerCompanyId',
          args: CreateLedgerRouteArgs(
            key: key,
            companyId: companyId,
            customerCompanyId: customerCompanyId,
          ),
        );

  static const String name = 'CreateLedgerRoute';
}

class CreateLedgerRouteArgs {
  const CreateLedgerRouteArgs({
    this.key,
    required this.companyId,
    required this.customerCompanyId,
  });

  final _i21.Key? key;

  final String companyId;

  final String customerCompanyId;

  @override
  String toString() {
    return 'CreateLedgerRouteArgs{key: $key, companyId: $companyId, customerCompanyId: $customerCompanyId}';
  }
}
