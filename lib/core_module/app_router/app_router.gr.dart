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
import 'dart:async' as _i28;

import 'package:auto_route/auto_route.dart' as _i26;
import 'package:flutter/material.dart' as _i27;

import '../../company_admin_module/data/product/category.dart' as _i34;
import '../../company_admin_module/data/product/product_model.dart' as _i33;
import '../../company_admin_module/data/product/sub_category.dart' as _i35;
import '../../company_admin_module/data/task/task_model.dart' as _i32;
import '../../company_admin_module/presentation/company_admin_dashboard.dart'
    as _i14;
import '../../company_admin_module/presentation/ledger/account_ledger_page.dart'
    as _i18;
import '../../company_admin_module/presentation/ledger/create_account_ledger.dart'
    as _i19;
import '../../company_admin_module/presentation/product/add_edit_category_page.dart'
    as _i23;
import '../../company_admin_module/presentation/product/add_edit_product_page.dart'
    as _i21;
import '../../company_admin_module/presentation/product/add_edit_sub_category_page.dart'
    as _i24;
import '../../company_admin_module/presentation/product/category_sub_category_list_page.dart'
    as _i25;
import '../../company_admin_module/presentation/product/dashboard/product_mgt_page.dart'
    as _i22;
import '../../company_admin_module/presentation/product/product_list_page.dart'
    as _i20;
import '../../company_admin_module/presentation/tasks/add_edit_task.dart'
    as _i17;
import '../../company_admin_module/presentation/tasks/task_list_page.dart'
    as _i16;
import '../../company_admin_module/presentation/users/add_company_user_page.dart'
    as _i13;
import '../../company_admin_module/presentation/users/user_list_page.dart'
    as _i15;
import '../../super_admin_module/ai_module/presentation/ai_company_list_page.dart'
    as _i10;
import '../../super_admin_module/data/tenant_company.dart' as _i30;
import '../../super_admin_module/data/user_info.dart' as _i31;
import '../../super_admin_module/presentation/add_tenant_company/add_tenant_company_page.dart'
    as _i12;
import '../../super_admin_module/presentation/dashboard/super_admin_page.dart'
    as _i11;
import '../../user_module/data/company.dart' as _i29;
import '../../user_module/presentation/add_company/add_company_page.dart'
    as _i8;
import '../../user_module/presentation/company_list/company_details_page.dart'
    as _i9;
import '../../user_module/presentation/company_list/company_list_page.dart'
    as _i5;
import '../../user_module/presentation/company_settings/settings_page.dart'
    as _i7;
import '../presentation/dashboard/dashboard/dashboard_page.dart' as _i2;
import '../presentation/dashboard/dashboard/reports_page.dart' as _i6;
import '../presentation/dashboard/home/home_page.dart' as _i4;
import '../presentation/login/login_page.dart' as _i3;
import '../presentation/login/splash_screen.dart' as _i1;

class AppRouter extends _i26.RootStackRouter {
  AppRouter([_i27.GlobalKey<_i27.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i26.PageFactory> pagesMap = {
    SplashScreen.name: (routeData) {
      final args = routeData.argsAs<SplashScreenArgs>(
          orElse: () => const SplashScreenArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i1.SplashScreen(
          key: args.key,
          onDelayComplete: args.onDelayComplete,
        ),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>(
          orElse: () => const LoginRouteArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i3.LoginPage(key: args.key),
      );
    },
    HomeRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.HomePage(),
      );
    },
    CompanyListRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.CompanyListPage(),
      );
    },
    ReportRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.ReportPage(),
      );
    },
    CompanySettingRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.CompanySettingPage(),
      );
    },
    AddCompanyRoute.name: (routeData) {
      final args = routeData.argsAs<AddCompanyRouteArgs>(
          orElse: () => const AddCompanyRouteArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i8.AddCompanyPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
    CompanyDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CompanyDetailsRouteArgs>();
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i9.CompanyDetailsPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
    AiCompanyListRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i10.AiCompanyListPage(),
      );
    },
    SuperAdminRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i11.SuperAdminPage(),
      );
    },
    AddTenantCompanyRoute.name: (routeData) {
      final args = routeData.argsAs<AddTenantCompanyRouteArgs>(
          orElse: () => const AddTenantCompanyRouteArgs());
      return _i26.MaterialPageX<dynamic>(
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
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i13.AddUserPage(
          key: args.key,
          user: args.user,
        ),
      );
    },
    CompanyAdminRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i14.CompanyAdminPage(),
      );
    },
    UserListRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i15.UserListPage(),
      );
    },
    TaskListRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i16.TaskListPage(),
      );
    },
    AddTaskRoute.name: (routeData) {
      final args = routeData.argsAs<AddTaskRouteArgs>(
          orElse: () => const AddTaskRouteArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i17.AddTaskPage(
          key: args.key,
          task: args.task,
        ),
      );
    },
    AccountLedgerRoute.name: (routeData) {
      final args = routeData.argsAs<AccountLedgerRouteArgs>();
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i18.AccountLedgerPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
    CreateLedgerRoute.name: (routeData) {
      final args = routeData.argsAs<CreateLedgerRouteArgs>();
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i19.CreateLedgerPage(
          key: args.key,
          companyId: args.companyId,
          customerCompanyId: args.customerCompanyId,
        ),
      );
    },
    ProductListRoute.name: (routeData) {
      final args = routeData.argsAs<ProductListRouteArgs>(
          orElse: () => const ProductListRouteArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i20.ProductListPage(key: args.key),
      );
    },
    AddEditProductRoute.name: (routeData) {
      final args = routeData.argsAs<AddEditProductRouteArgs>(
          orElse: () => const AddEditProductRouteArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i21.AddEditProductPage(
          key: args.key,
          product: args.product,
        ),
      );
    },
    ProductMgtRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i22.ProductMgtPage(),
      );
    },
    AddEditCategoryRoute.name: (routeData) {
      final args = routeData.argsAs<AddEditCategoryRouteArgs>(
          orElse: () => const AddEditCategoryRouteArgs());
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i23.AddEditCategoryPage(
          key: args.key,
          category: args.category,
        ),
      );
    },
    AddEditSubcategoryRoute.name: (routeData) {
      final args = routeData.argsAs<AddEditSubcategoryRouteArgs>();
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i24.AddEditSubcategoryPage(
          key: args.key,
          subcategory: args.subcategory,
          category: args.category,
        ),
      );
    },
    CategoriesWithSubcategoriesRoute.name: (routeData) {
      return _i26.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i25.CategoriesWithSubcategoriesPage(),
      );
    },
  };

  @override
  List<_i26.RouteConfig> get routes => [
        _i26.RouteConfig(
          SplashScreen.name,
          path: '/',
        ),
        _i26.RouteConfig(
          DashboardRoute.name,
          path: '/dashboard',
        ),
        _i26.RouteConfig(
          LoginRoute.name,
          path: '/login',
        ),
        _i26.RouteConfig(
          HomeRoute.name,
          path: '/home',
        ),
        _i26.RouteConfig(
          CompanyListRoute.name,
          path: '/company-list',
        ),
        _i26.RouteConfig(
          ReportRoute.name,
          path: '/reports',
        ),
        _i26.RouteConfig(
          CompanySettingRoute.name,
          path: '/settings',
        ),
        _i26.RouteConfig(
          AddCompanyRoute.name,
          path: '/add-company',
        ),
        _i26.RouteConfig(
          CompanyDetailsRoute.name,
          path: '/company-details',
        ),
        _i26.RouteConfig(
          AiCompanyListRoute.name,
          path: '/ai-company-list',
        ),
        _i26.RouteConfig(
          SuperAdminRoute.name,
          path: '/super-admin',
        ),
        _i26.RouteConfig(
          AddTenantCompanyRoute.name,
          path: '/add-tenant-company',
        ),
        _i26.RouteConfig(
          AddUserRoute.name,
          path: '/add-user',
        ),
        _i26.RouteConfig(
          CompanyAdminRoute.name,
          path: '/company-admin',
        ),
        _i26.RouteConfig(
          UserListRoute.name,
          path: '/user-list',
        ),
        _i26.RouteConfig(
          TaskListRoute.name,
          path: '/task-list',
        ),
        _i26.RouteConfig(
          AddTaskRoute.name,
          path: '/add-task',
        ),
        _i26.RouteConfig(
          AccountLedgerRoute.name,
          path: '/account-ledger',
        ),
        _i26.RouteConfig(
          CreateLedgerRoute.name,
          path: '/create-ledger/:companyId/:customerCompanyId',
        ),
        _i26.RouteConfig(
          ProductListRoute.name,
          path: '/product-list',
        ),
        _i26.RouteConfig(
          AddEditProductRoute.name,
          path: '/add-edit-product',
        ),
        _i26.RouteConfig(
          ProductMgtRoute.name,
          path: '/manage-product',
        ),
        _i26.RouteConfig(
          AddEditCategoryRoute.name,
          path: '/add-edit-category',
        ),
        _i26.RouteConfig(
          AddEditSubcategoryRoute.name,
          path: '/add-edit-subcategory',
        ),
        _i26.RouteConfig(
          CategoriesWithSubcategoriesRoute.name,
          path: '/categories-with-subcategories',
        ),
      ];
}

/// generated route for
/// [_i1.SplashScreen]
class SplashScreen extends _i26.PageRouteInfo<SplashScreenArgs> {
  SplashScreen({
    _i27.Key? key,
    _i28.Future<void> Function()? onDelayComplete,
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

  final _i27.Key? key;

  final _i28.Future<void> Function()? onDelayComplete;

  @override
  String toString() {
    return 'SplashScreenArgs{key: $key, onDelayComplete: $onDelayComplete}';
  }
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardRoute extends _i26.PageRouteInfo<void> {
  const DashboardRoute()
      : super(
          DashboardRoute.name,
          path: '/dashboard',
        );

  static const String name = 'DashboardRoute';
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i26.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({_i27.Key? key})
      : super(
          LoginRoute.name,
          path: '/login',
          args: LoginRouteArgs(key: key),
        );

  static const String name = 'LoginRoute';
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final _i27.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i26.PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/home',
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i5.CompanyListPage]
class CompanyListRoute extends _i26.PageRouteInfo<void> {
  const CompanyListRoute()
      : super(
          CompanyListRoute.name,
          path: '/company-list',
        );

  static const String name = 'CompanyListRoute';
}

/// generated route for
/// [_i6.ReportPage]
class ReportRoute extends _i26.PageRouteInfo<void> {
  const ReportRoute()
      : super(
          ReportRoute.name,
          path: '/reports',
        );

  static const String name = 'ReportRoute';
}

/// generated route for
/// [_i7.CompanySettingPage]
class CompanySettingRoute extends _i26.PageRouteInfo<void> {
  const CompanySettingRoute()
      : super(
          CompanySettingRoute.name,
          path: '/settings',
        );

  static const String name = 'CompanySettingRoute';
}

/// generated route for
/// [_i8.AddCompanyPage]
class AddCompanyRoute extends _i26.PageRouteInfo<AddCompanyRouteArgs> {
  AddCompanyRoute({
    _i27.Key? key,
    _i29.Company? company,
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

  final _i27.Key? key;

  final _i29.Company? company;

  @override
  String toString() {
    return 'AddCompanyRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i9.CompanyDetailsPage]
class CompanyDetailsRoute extends _i26.PageRouteInfo<CompanyDetailsRouteArgs> {
  CompanyDetailsRoute({
    _i27.Key? key,
    required _i29.Company company,
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

  final _i27.Key? key;

  final _i29.Company company;

  @override
  String toString() {
    return 'CompanyDetailsRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i10.AiCompanyListPage]
class AiCompanyListRoute extends _i26.PageRouteInfo<void> {
  const AiCompanyListRoute()
      : super(
          AiCompanyListRoute.name,
          path: '/ai-company-list',
        );

  static const String name = 'AiCompanyListRoute';
}

/// generated route for
/// [_i11.SuperAdminPage]
class SuperAdminRoute extends _i26.PageRouteInfo<void> {
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
    extends _i26.PageRouteInfo<AddTenantCompanyRouteArgs> {
  AddTenantCompanyRoute({
    _i27.Key? key,
    _i30.TenantCompany? company,
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

  final _i27.Key? key;

  final _i30.TenantCompany? company;

  @override
  String toString() {
    return 'AddTenantCompanyRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i13.AddUserPage]
class AddUserRoute extends _i26.PageRouteInfo<AddUserRouteArgs> {
  AddUserRoute({
    _i27.Key? key,
    _i31.UserInfo? user,
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

  final _i27.Key? key;

  final _i31.UserInfo? user;

  @override
  String toString() {
    return 'AddUserRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [_i14.CompanyAdminPage]
class CompanyAdminRoute extends _i26.PageRouteInfo<void> {
  const CompanyAdminRoute()
      : super(
          CompanyAdminRoute.name,
          path: '/company-admin',
        );

  static const String name = 'CompanyAdminRoute';
}

/// generated route for
/// [_i15.UserListPage]
class UserListRoute extends _i26.PageRouteInfo<void> {
  const UserListRoute()
      : super(
          UserListRoute.name,
          path: '/user-list',
        );

  static const String name = 'UserListRoute';
}

/// generated route for
/// [_i16.TaskListPage]
class TaskListRoute extends _i26.PageRouteInfo<void> {
  const TaskListRoute()
      : super(
          TaskListRoute.name,
          path: '/task-list',
        );

  static const String name = 'TaskListRoute';
}

/// generated route for
/// [_i17.AddTaskPage]
class AddTaskRoute extends _i26.PageRouteInfo<AddTaskRouteArgs> {
  AddTaskRoute({
    _i27.Key? key,
    _i32.TaskModel? task,
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

  final _i27.Key? key;

  final _i32.TaskModel? task;

  @override
  String toString() {
    return 'AddTaskRouteArgs{key: $key, task: $task}';
  }
}

/// generated route for
/// [_i18.AccountLedgerPage]
class AccountLedgerRoute extends _i26.PageRouteInfo<AccountLedgerRouteArgs> {
  AccountLedgerRoute({
    _i27.Key? key,
    required _i29.Company company,
  }) : super(
          AccountLedgerRoute.name,
          path: '/account-ledger',
          args: AccountLedgerRouteArgs(
            key: key,
            company: company,
          ),
        );

  static const String name = 'AccountLedgerRoute';
}

class AccountLedgerRouteArgs {
  const AccountLedgerRouteArgs({
    this.key,
    required this.company,
  });

  final _i27.Key? key;

  final _i29.Company company;

  @override
  String toString() {
    return 'AccountLedgerRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [_i19.CreateLedgerPage]
class CreateLedgerRoute extends _i26.PageRouteInfo<CreateLedgerRouteArgs> {
  CreateLedgerRoute({
    _i27.Key? key,
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

  final _i27.Key? key;

  final String companyId;

  final String customerCompanyId;

  @override
  String toString() {
    return 'CreateLedgerRouteArgs{key: $key, companyId: $companyId, customerCompanyId: $customerCompanyId}';
  }
}

/// generated route for
/// [_i20.ProductListPage]
class ProductListRoute extends _i26.PageRouteInfo<ProductListRouteArgs> {
  ProductListRoute({_i27.Key? key})
      : super(
          ProductListRoute.name,
          path: '/product-list',
          args: ProductListRouteArgs(key: key),
        );

  static const String name = 'ProductListRoute';
}

class ProductListRouteArgs {
  const ProductListRouteArgs({this.key});

  final _i27.Key? key;

  @override
  String toString() {
    return 'ProductListRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i21.AddEditProductPage]
class AddEditProductRoute extends _i26.PageRouteInfo<AddEditProductRouteArgs> {
  AddEditProductRoute({
    _i27.Key? key,
    _i33.Product? product,
  }) : super(
          AddEditProductRoute.name,
          path: '/add-edit-product',
          args: AddEditProductRouteArgs(
            key: key,
            product: product,
          ),
        );

  static const String name = 'AddEditProductRoute';
}

class AddEditProductRouteArgs {
  const AddEditProductRouteArgs({
    this.key,
    this.product,
  });

  final _i27.Key? key;

  final _i33.Product? product;

  @override
  String toString() {
    return 'AddEditProductRouteArgs{key: $key, product: $product}';
  }
}

/// generated route for
/// [_i22.ProductMgtPage]
class ProductMgtRoute extends _i26.PageRouteInfo<void> {
  const ProductMgtRoute()
      : super(
          ProductMgtRoute.name,
          path: '/manage-product',
        );

  static const String name = 'ProductMgtRoute';
}

/// generated route for
/// [_i23.AddEditCategoryPage]
class AddEditCategoryRoute
    extends _i26.PageRouteInfo<AddEditCategoryRouteArgs> {
  AddEditCategoryRoute({
    _i27.Key? key,
    _i34.Category? category,
  }) : super(
          AddEditCategoryRoute.name,
          path: '/add-edit-category',
          args: AddEditCategoryRouteArgs(
            key: key,
            category: category,
          ),
        );

  static const String name = 'AddEditCategoryRoute';
}

class AddEditCategoryRouteArgs {
  const AddEditCategoryRouteArgs({
    this.key,
    this.category,
  });

  final _i27.Key? key;

  final _i34.Category? category;

  @override
  String toString() {
    return 'AddEditCategoryRouteArgs{key: $key, category: $category}';
  }
}

/// generated route for
/// [_i24.AddEditSubcategoryPage]
class AddEditSubcategoryRoute
    extends _i26.PageRouteInfo<AddEditSubcategoryRouteArgs> {
  AddEditSubcategoryRoute({
    _i27.Key? key,
    _i35.Subcategory? subcategory,
    required _i34.Category category,
  }) : super(
          AddEditSubcategoryRoute.name,
          path: '/add-edit-subcategory',
          args: AddEditSubcategoryRouteArgs(
            key: key,
            subcategory: subcategory,
            category: category,
          ),
        );

  static const String name = 'AddEditSubcategoryRoute';
}

class AddEditSubcategoryRouteArgs {
  const AddEditSubcategoryRouteArgs({
    this.key,
    this.subcategory,
    required this.category,
  });

  final _i27.Key? key;

  final _i35.Subcategory? subcategory;

  final _i34.Category category;

  @override
  String toString() {
    return 'AddEditSubcategoryRouteArgs{key: $key, subcategory: $subcategory, category: $category}';
  }
}

/// generated route for
/// [_i25.CategoriesWithSubcategoriesPage]
class CategoriesWithSubcategoriesRoute extends _i26.PageRouteInfo<void> {
  const CategoriesWithSubcategoriesRoute()
      : super(
          CategoriesWithSubcategoriesRoute.name,
          path: '/categories-with-subcategories',
        );

  static const String name = 'CategoriesWithSubcategoriesRoute';
}
