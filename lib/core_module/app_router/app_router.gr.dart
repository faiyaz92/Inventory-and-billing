// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AccountLedgerPage]
class AccountLedgerRoute extends PageRouteInfo<AccountLedgerRouteArgs> {
  AccountLedgerRoute({
    Key? key,
    required Partner company,
    List<PageRouteInfo>? children,
  }) : super(
         AccountLedgerRoute.name,
         args: AccountLedgerRouteArgs(key: key, company: company),
         initialChildren: children,
       );

  static const String name = 'AccountLedgerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AccountLedgerRouteArgs>();
      return AccountLedgerPage(key: args.key, company: args.company);
    },
  );
}

class AccountLedgerRouteArgs {
  const AccountLedgerRouteArgs({this.key, required this.company});

  final Key? key;

  final Partner company;

  @override
  String toString() {
    return 'AccountLedgerRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [AddCompanyPage]
class AddCompanyRoute extends PageRouteInfo<AddCompanyRouteArgs> {
  AddCompanyRoute({Key? key, Partner? company, List<PageRouteInfo>? children})
    : super(
        AddCompanyRoute.name,
        args: AddCompanyRouteArgs(key: key, company: company),
        initialChildren: children,
      );

  static const String name = 'AddCompanyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddCompanyRouteArgs>(
        orElse: () => const AddCompanyRouteArgs(),
      );
      return AddCompanyPage(key: args.key, company: args.company);
    },
  );
}

class AddCompanyRouteArgs {
  const AddCompanyRouteArgs({this.key, this.company});

  final Key? key;

  final Partner? company;

  @override
  String toString() {
    return 'AddCompanyRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [AddEditCategoryPage]
class AddEditCategoryRoute extends PageRouteInfo<AddEditCategoryRouteArgs> {
  AddEditCategoryRoute({
    Key? key,
    Category? category,
    List<PageRouteInfo>? children,
  }) : super(
         AddEditCategoryRoute.name,
         args: AddEditCategoryRouteArgs(key: key, category: category),
         initialChildren: children,
       );

  static const String name = 'AddEditCategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddEditCategoryRouteArgs>(
        orElse: () => const AddEditCategoryRouteArgs(),
      );
      return AddEditCategoryPage(key: args.key, category: args.category);
    },
  );
}

class AddEditCategoryRouteArgs {
  const AddEditCategoryRouteArgs({this.key, this.category});

  final Key? key;

  final Category? category;

  @override
  String toString() {
    return 'AddEditCategoryRouteArgs{key: $key, category: $category}';
  }
}

/// generated route for
/// [AddEditProductPage]
class AddEditProductRoute extends PageRouteInfo<AddEditProductRouteArgs> {
  AddEditProductRoute({
    Key? key,
    Product? product,
    List<PageRouteInfo>? children,
  }) : super(
         AddEditProductRoute.name,
         args: AddEditProductRouteArgs(key: key, product: product),
         initialChildren: children,
       );

  static const String name = 'AddEditProductRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddEditProductRouteArgs>(
        orElse: () => const AddEditProductRouteArgs(),
      );
      return AddEditProductPage(key: args.key, product: args.product);
    },
  );
}

class AddEditProductRouteArgs {
  const AddEditProductRouteArgs({this.key, this.product});

  final Key? key;

  final Product? product;

  @override
  String toString() {
    return 'AddEditProductRouteArgs{key: $key, product: $product}';
  }
}

/// generated route for
/// [AddEditSubcategoryPage]
class AddEditSubcategoryRoute
    extends PageRouteInfo<AddEditSubcategoryRouteArgs> {
  AddEditSubcategoryRoute({
    Key? key,
    Subcategory? subcategory,
    required Category category,
    List<PageRouteInfo>? children,
  }) : super(
         AddEditSubcategoryRoute.name,
         args: AddEditSubcategoryRouteArgs(
           key: key,
           subcategory: subcategory,
           category: category,
         ),
         initialChildren: children,
       );

  static const String name = 'AddEditSubcategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddEditSubcategoryRouteArgs>();
      return AddEditSubcategoryPage(
        key: args.key,
        subcategory: args.subcategory,
        category: args.category,
      );
    },
  );
}

class AddEditSubcategoryRouteArgs {
  const AddEditSubcategoryRouteArgs({
    this.key,
    this.subcategory,
    required this.category,
  });

  final Key? key;

  final Subcategory? subcategory;

  final Category category;

  @override
  String toString() {
    return 'AddEditSubcategoryRouteArgs{key: $key, subcategory: $subcategory, category: $category}';
  }
}

/// generated route for
/// [AddSupplierPage]
class AddSupplierRoute extends PageRouteInfo<AddSupplierRouteArgs> {
  AddSupplierRoute({Key? key, Partner? company, List<PageRouteInfo>? children})
    : super(
        AddSupplierRoute.name,
        args: AddSupplierRouteArgs(key: key, company: company),
        initialChildren: children,
      );

  static const String name = 'AddSupplierRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddSupplierRouteArgs>(
        orElse: () => const AddSupplierRouteArgs(),
      );
      return AddSupplierPage(key: args.key, company: args.company);
    },
  );
}

class AddSupplierRouteArgs {
  const AddSupplierRouteArgs({this.key, this.company});

  final Key? key;

  final Partner? company;

  @override
  String toString() {
    return 'AddSupplierRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [AddTaskPage]
class AddTaskRoute extends PageRouteInfo<AddTaskRouteArgs> {
  AddTaskRoute({Key? key, TaskModel? task, List<PageRouteInfo>? children})
    : super(
        AddTaskRoute.name,
        args: AddTaskRouteArgs(key: key, task: task),
        initialChildren: children,
      );

  static const String name = 'AddTaskRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddTaskRouteArgs>(
        orElse: () => const AddTaskRouteArgs(),
      );
      return AddTaskPage(key: args.key, task: args.task);
    },
  );
}

class AddTaskRouteArgs {
  const AddTaskRouteArgs({this.key, this.task});

  final Key? key;

  final TaskModel? task;

  @override
  String toString() {
    return 'AddTaskRouteArgs{key: $key, task: $task}';
  }
}

/// generated route for
/// [AddTenantCompanyPage]
class AddTenantCompanyRoute extends PageRouteInfo<AddTenantCompanyRouteArgs> {
  AddTenantCompanyRoute({
    Key? key,
    TenantCompany? company,
    List<PageRouteInfo>? children,
  }) : super(
         AddTenantCompanyRoute.name,
         args: AddTenantCompanyRouteArgs(key: key, company: company),
         initialChildren: children,
       );

  static const String name = 'AddTenantCompanyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddTenantCompanyRouteArgs>(
        orElse: () => const AddTenantCompanyRouteArgs(),
      );
      return AddTenantCompanyPage(key: args.key, company: args.company);
    },
  );
}

class AddTenantCompanyRouteArgs {
  const AddTenantCompanyRouteArgs({this.key, this.company});

  final Key? key;

  final TenantCompany? company;

  @override
  String toString() {
    return 'AddTenantCompanyRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [AddUserPage]
class AddUserRoute extends PageRouteInfo<AddUserRouteArgs> {
  AddUserRoute({Key? key, UserInfo? user, List<PageRouteInfo>? children})
    : super(
        AddUserRoute.name,
        args: AddUserRouteArgs(key: key, user: user),
        initialChildren: children,
      );

  static const String name = 'AddUserRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddUserRouteArgs>(
        orElse: () => const AddUserRouteArgs(),
      );
      return AddUserPage(key: args.key, user: args.user);
    },
  );
}

class AddUserRouteArgs {
  const AddUserRouteArgs({this.key, this.user});

  final Key? key;

  final UserInfo? user;

  @override
  String toString() {
    return 'AddUserRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [AiCompanyListPage]
class AiCompanyListRoute extends PageRouteInfo<void> {
  const AiCompanyListRoute({List<PageRouteInfo>? children})
    : super(AiCompanyListRoute.name, initialChildren: children);

  static const String name = 'AiCompanyListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AiCompanyListPage();
    },
  );
}

/// generated route for
/// [AttendanceRegisterPage]
class AttendanceRegisterRoute extends PageRouteInfo<void> {
  const AttendanceRegisterRoute({List<PageRouteInfo>? children})
    : super(AttendanceRegisterRoute.name, initialChildren: children);

  static const String name = 'AttendanceRegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AttendanceRegisterPage();
    },
  );
}

/// generated route for
/// [CategoriesWithSubcategoriesPage]
class CategoriesWithSubcategoriesRoute extends PageRouteInfo<void> {
  const CategoriesWithSubcategoriesRoute({List<PageRouteInfo>? children})
    : super(CategoriesWithSubcategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesWithSubcategoriesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoriesWithSubcategoriesPage();
    },
  );
}

/// generated route for
/// [CompanyAdminPage]
class CompanyAdminRoute extends PageRouteInfo<void> {
  const CompanyAdminRoute({List<PageRouteInfo>? children})
    : super(CompanyAdminRoute.name, initialChildren: children);

  static const String name = 'CompanyAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CompanyAdminPage();
    },
  );
}

/// generated route for
/// [CompanyDetailsPage]
class CompanyDetailsRoute extends PageRouteInfo<CompanyDetailsRouteArgs> {
  CompanyDetailsRoute({
    Key? key,
    required Partner company,
    List<PageRouteInfo>? children,
  }) : super(
         CompanyDetailsRoute.name,
         args: CompanyDetailsRouteArgs(key: key, company: company),
         initialChildren: children,
       );

  static const String name = 'CompanyDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CompanyDetailsRouteArgs>();
      return CompanyDetailsPage(key: args.key, company: args.company);
    },
  );
}

class CompanyDetailsRouteArgs {
  const CompanyDetailsRouteArgs({this.key, required this.company});

  final Key? key;

  final Partner company;

  @override
  String toString() {
    return 'CompanyDetailsRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [CompanyListPage]
class CompanyListRoute extends PageRouteInfo<void> {
  const CompanyListRoute({List<PageRouteInfo>? children})
    : super(CompanyListRoute.name, initialChildren: children);

  static const String name = 'CompanyListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CompanyListPage();
    },
  );
}

/// generated route for
/// [CompanySettingPage]
class CompanySettingRoute extends PageRouteInfo<void> {
  const CompanySettingRoute({List<PageRouteInfo>? children})
    : super(CompanySettingRoute.name, initialChildren: children);

  static const String name = 'CompanySettingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CompanySettingPage();
    },
  );
}

/// generated route for
/// [CreateLedgerPage]
class CreateLedgerRoute extends PageRouteInfo<CreateLedgerRouteArgs> {
  CreateLedgerRoute({
    Key? key,
    required String companyId,
    required String customerCompanyId,
    List<PageRouteInfo>? children,
  }) : super(
         CreateLedgerRoute.name,
         args: CreateLedgerRouteArgs(
           key: key,
           companyId: companyId,
           customerCompanyId: customerCompanyId,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateLedgerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateLedgerRouteArgs>();
      return CreateLedgerPage(
        key: args.key,
        companyId: args.companyId,
        customerCompanyId: args.customerCompanyId,
      );
    },
  );
}

class CreateLedgerRouteArgs {
  const CreateLedgerRouteArgs({
    this.key,
    required this.companyId,
    required this.customerCompanyId,
  });

  final Key? key;

  final String companyId;

  final String customerCompanyId;

  @override
  String toString() {
    return 'CreateLedgerRouteArgs{key: $key, companyId: $companyId, customerCompanyId: $customerCompanyId}';
  }
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardPage();
    },
  );
}

/// generated route for
/// [EmployeeDetailsPage]
class EmployeeDetailsRoute extends PageRouteInfo<EmployeeDetailsRouteArgs> {
  EmployeeDetailsRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         EmployeeDetailsRoute.name,
         args: EmployeeDetailsRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'EmployeeDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployeeDetailsRouteArgs>();
      return EmployeeDetailsPage(key: args.key, userId: args.userId);
    },
  );
}

class EmployeeDetailsRouteArgs {
  const EmployeeDetailsRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'EmployeeDetailsRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [EmployeesPage]
class EmployeesRoute extends PageRouteInfo<void> {
  const EmployeesRoute({List<PageRouteInfo>? children})
    : super(EmployeesRoute.name, initialChildren: children);

  static const String name = 'EmployeesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EmployeesPage();
    },
  );
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<ForgotPasswordRouteArgs> {
  ForgotPasswordRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        ForgotPasswordRoute.name,
        args: ForgotPasswordRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgotPasswordRouteArgs>(
        orElse: () => const ForgotPasswordRouteArgs(),
      );
      return ForgotPasswordPage(key: args.key);
    },
  );
}

class ForgotPasswordRouteArgs {
  const ForgotPasswordRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ForgotPasswordRouteArgs{key: $key}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        LoginRoute.name,
        args: LoginRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginPage(key: args.key);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }
}

/// generated route for
/// [ProductListPage]
class ProductListRoute extends PageRouteInfo<ProductListRouteArgs> {
  ProductListRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        ProductListRoute.name,
        args: ProductListRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'ProductListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductListRouteArgs>(
        orElse: () => const ProductListRouteArgs(),
      );
      return ProductListPage(key: args.key);
    },
  );
}

class ProductListRouteArgs {
  const ProductListRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ProductListRouteArgs{key: $key}';
  }
}

/// generated route for
/// [ProductMgtPage]
class ProductMgtRoute extends PageRouteInfo<void> {
  const ProductMgtRoute({List<PageRouteInfo>? children})
    : super(ProductMgtRoute.name, initialChildren: children);

  static const String name = 'ProductMgtRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProductMgtPage();
    },
  );
}

/// generated route for
/// [SplashScreenPage]
class SplashScreenRoute extends PageRouteInfo<SplashScreenRouteArgs> {
  SplashScreenRoute({
    Key? key,
    Future<void> Function()? onDelayComplete,
    List<PageRouteInfo>? children,
  }) : super(
         SplashScreenRoute.name,
         args: SplashScreenRouteArgs(
           key: key,
           onDelayComplete: onDelayComplete,
         ),
         initialChildren: children,
       );

  static const String name = 'SplashScreenRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SplashScreenRouteArgs>(
        orElse: () => const SplashScreenRouteArgs(),
      );
      return SplashScreenPage(
        key: args.key,
        onDelayComplete: args.onDelayComplete,
      );
    },
  );
}

class SplashScreenRouteArgs {
  const SplashScreenRouteArgs({this.key, this.onDelayComplete});

  final Key? key;

  final Future<void> Function()? onDelayComplete;

  @override
  String toString() {
    return 'SplashScreenRouteArgs{key: $key, onDelayComplete: $onDelayComplete}';
  }
}

/// generated route for
/// [SuperAdminPage]
class SuperAdminRoute extends PageRouteInfo<void> {
  const SuperAdminRoute({List<PageRouteInfo>? children})
    : super(SuperAdminRoute.name, initialChildren: children);

  static const String name = 'SuperAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SuperAdminPage();
    },
  );
}

/// generated route for
/// [SupplierDetailsPage]
class SupplierDetailsRoute extends PageRouteInfo<SupplierDetailsRouteArgs> {
  SupplierDetailsRoute({
    Key? key,
    required Partner company,
    List<PageRouteInfo>? children,
  }) : super(
         SupplierDetailsRoute.name,
         args: SupplierDetailsRouteArgs(key: key, company: company),
         initialChildren: children,
       );

  static const String name = 'SupplierDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupplierDetailsRouteArgs>();
      return SupplierDetailsPage(key: args.key, company: args.company);
    },
  );
}

class SupplierDetailsRouteArgs {
  const SupplierDetailsRouteArgs({this.key, required this.company});

  final Key? key;

  final Partner company;

  @override
  String toString() {
    return 'SupplierDetailsRouteArgs{key: $key, company: $company}';
  }
}

/// generated route for
/// [SupplierListPage]
class SupplierListRoute extends PageRouteInfo<void> {
  const SupplierListRoute({List<PageRouteInfo>? children})
    : super(SupplierListRoute.name, initialChildren: children);

  static const String name = 'SupplierListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SupplierListPage();
    },
  );
}

/// generated route for
/// [TaskListPage]
class TaskListRoute extends PageRouteInfo<void> {
  const TaskListRoute({List<PageRouteInfo>? children})
    : super(TaskListRoute.name, initialChildren: children);

  static const String name = 'TaskListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TaskListPage();
    },
  );
}
