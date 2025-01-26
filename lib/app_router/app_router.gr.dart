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
import 'dart:async' as _i12;

import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/material.dart' as _i11;

import '../dashboard/home/add_company_page.dart' as _i8;
import '../dashboard/home/company_details_page.dart' as _i9;
import '../dashboard/home/company_list_page.dart' as _i5;
import '../dashboard/home/dashboard_page.dart' as _i2;
import '../dashboard/home/home_page.dart' as _i4;
import '../dashboard/reports_page.dart' as _i6;
import '../dashboard/settings_page.dart' as _i7;
import '../data/company.dart' as _i13;
import '../login/login_page.dart' as _i3;
import '../login/splash_screen.dart' as _i1;

class AppRouter extends _i10.RootStackRouter {
  AppRouter([_i11.GlobalKey<_i11.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i10.PageFactory> pagesMap = {
    SplashScreen.name: (routeData) {
      final args = routeData.argsAs<SplashScreenArgs>(
          orElse: () => const SplashScreenArgs());
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i1.SplashScreen(
          key: args.key,
          onDelayComplete: args.onDelayComplete,
        ),
      );
    },
    DashboardRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i2.DashboardPage(),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>(
          orElse: () => const LoginRouteArgs());
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i3.LoginPage(key: args.key),
      );
    },
    HomeRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i4.HomePage(),
      );
    },
    CompanyListRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i5.CompanyListPage(),
      );
    },
    ReportsRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i6.ReportsPage(),
      );
    },
    CompanySettingRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i7.CompanySettingPage(),
      );
    },
    AddCompanyRoute.name: (routeData) {
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: const _i8.AddCompanyPage(),
      );
    },
    CompanyDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CompanyDetailsRouteArgs>();
      return _i10.MaterialPageX<dynamic>(
        routeData: routeData,
        child: _i9.CompanyDetailsPage(
          key: args.key,
          company: args.company,
        ),
      );
    },
  };

  @override
  List<_i10.RouteConfig> get routes => [
        _i10.RouteConfig(
          SplashScreen.name,
          path: '/',
        ),
        _i10.RouteConfig(
          DashboardRoute.name,
          path: '/dashboard',
        ),
        _i10.RouteConfig(
          LoginRoute.name,
          path: '/login',
        ),
        _i10.RouteConfig(
          HomeRoute.name,
          path: '/home',
        ),
        _i10.RouteConfig(
          CompanyListRoute.name,
          path: '/company-list',
        ),
        _i10.RouteConfig(
          ReportsRoute.name,
          path: '/reports',
        ),
        _i10.RouteConfig(
          CompanySettingRoute.name,
          path: '/settings',
        ),
        _i10.RouteConfig(
          AddCompanyRoute.name,
          path: '/add-company',
        ),
        _i10.RouteConfig(
          CompanyDetailsRoute.name,
          path: '/company-details',
        ),
      ];
}

/// generated route for
/// [_i1.SplashScreen]
class SplashScreen extends _i10.PageRouteInfo<SplashScreenArgs> {
  SplashScreen({
    _i11.Key? key,
    _i12.Future<void> Function()? onDelayComplete,
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

  final _i11.Key? key;

  final _i12.Future<void> Function()? onDelayComplete;

  @override
  String toString() {
    return 'SplashScreenArgs{key: $key, onDelayComplete: $onDelayComplete}';
  }
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardRoute extends _i10.PageRouteInfo<void> {
  const DashboardRoute()
      : super(
          DashboardRoute.name,
          path: '/dashboard',
        );

  static const String name = 'DashboardRoute';
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i10.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({_i11.Key? key})
      : super(
          LoginRoute.name,
          path: '/login',
          args: LoginRouteArgs(key: key),
        );

  static const String name = 'LoginRoute';
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final _i11.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i10.PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/home',
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i5.CompanyListPage]
class CompanyListRoute extends _i10.PageRouteInfo<void> {
  const CompanyListRoute()
      : super(
          CompanyListRoute.name,
          path: '/company-list',
        );

  static const String name = 'CompanyListRoute';
}

/// generated route for
/// [_i6.ReportsPage]
class ReportsRoute extends _i10.PageRouteInfo<void> {
  const ReportsRoute()
      : super(
          ReportsRoute.name,
          path: '/reports',
        );

  static const String name = 'ReportsRoute';
}

/// generated route for
/// [_i7.CompanySettingPage]
class CompanySettingRoute extends _i10.PageRouteInfo<void> {
  const CompanySettingRoute()
      : super(
          CompanySettingRoute.name,
          path: '/settings',
        );

  static const String name = 'CompanySettingRoute';
}

/// generated route for
/// [_i8.AddCompanyPage]
class AddCompanyRoute extends _i10.PageRouteInfo<void> {
  const AddCompanyRoute()
      : super(
          AddCompanyRoute.name,
          path: '/add-company',
        );

  static const String name = 'AddCompanyRoute';
}

/// generated route for
/// [_i9.CompanyDetailsPage]
class CompanyDetailsRoute extends _i10.PageRouteInfo<CompanyDetailsRouteArgs> {
  CompanyDetailsRoute({
    _i11.Key? key,
    required _i13.Company company,
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

  final _i11.Key? key;

  final _i13.Company company;

  @override
  String toString() {
    return 'CompanyDetailsRouteArgs{key: $key, company: $company}';
  }
}
