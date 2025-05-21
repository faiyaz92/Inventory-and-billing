import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/add_edit_category_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/product/product_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/tasks/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_user_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/attendance_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employee_details_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/employess_list_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/account_ledger_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/category_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/product_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/product_repository_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/transaction_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/category_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/category_service_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/employee_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/employee_services_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/product_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/product_service_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.dart'
    show AppRouter;
import 'package:requirment_gathering_app/core_module/coordinator/app_cordinator.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/dashboard/dashboard_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/forgot_password_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_cubit.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository_impl.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service_impl.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider_impl.dart';
import 'package:requirment_gathering_app/core_module/services/provider.dart';
import 'package:requirment_gathering_app/core_module/services/user_service.dart';
import 'package:requirment_gathering_app/core_module/services/user_service_impl.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/presentation/ai_company_list_cubit.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/repositories/ai_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/repositories/ai_company_repository_impl.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_cubit.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository_impl.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service_impl.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/product_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/wish_list_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/cart_repository_impl.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/i_cart_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/i_wish_list_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/order_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/wish_list_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/services/cart_service_impl.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_cart_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_user_product_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_wishlist_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/order_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/user_product_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/wish_list_service.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_settings/company_settings_cubit.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository_impl.dart';
import 'package:requirment_gathering_app/user_module/repo/customer_company_repository.dart';
import 'package:requirment_gathering_app/user_module/repo/customer_company_repository_impl.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service_impl.dart';
import 'package:requirment_gathering_app/user_module/services/permission_handler.dart';
import 'package:requirment_gathering_app/user_module/services/update_location_service.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  _initFirebase();
  _initRepositories();
  _initServices();
  _initCubits();
  _initAppNavigation();
}

/// **1. Initialize Firebase Dependencies**
void _initFirebase() {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<IFirestorePathProvider>(
      () => FirestorePathProviderImpl(sl<FirebaseFirestore>()));
}

/// **2. Initialize Repositories**
void _initRepositories() {
  // Account Repository
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(
        sl<FirebaseAuth>(),
        sl<IFirestorePathProvider>(),
      ));

  // Company Repository
  sl.registerFactory<CustomerCompanyRepository>(() =>
      CustomerCompanyRepositoryImpl(
          sl<IFirestorePathProvider>(), sl<AccountRepository>()));

  // Company Setting Repository
  sl.registerLazySingleton<CompanySettingRepository>(
      () => CompanySettingRepositoryImpl(
            sl<IFirestorePathProvider>(),
            sl<AccountRepository>(),
          ));

  // AI Company Repository
  sl.registerLazySingleton<AiCompanyListRepository>(
      () => AiCompanyListRepositoryImpl(sl<DioClientProvider>()));

  sl.registerLazySingleton<ITenantCompanyRepository>(
      () => TenantCompanyRepository(
            sl<IFirestorePathProvider>(),
            sl<FirebaseAuth>(),
            sl<AccountRepository>(),
          ));

  sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(sl<IFirestorePathProvider>()));
  sl.registerLazySingleton<IAccountLedgerRepository>(
      () => AccountLedgerRepositoryImpl(sl<IFirestorePathProvider>()));
  // ✅ Register Product Repository
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      firestorePathProvider: sl<IFirestorePathProvider>()));
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(
        firestorePathProvider: sl<IFirestorePathProvider>(),
      ));

  // ✅ Register Stock and Transaction Repositories
  sl.registerLazySingleton<StockRepository>(() => StockRepositoryImpl(
        firestorePathProvider: sl<IFirestorePathProvider>(),
        accountRepository: sl<AccountRepository>(),
      ));
  sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(
            firestorePathProvider: sl<IFirestorePathProvider>(),
          ));
  sl.registerLazySingleton<IOrderRepository>(() => OrderRepositoryImpl(
        firestorePathProvider: sl<IFirestorePathProvider>(),
      ));
  sl.registerLazySingleton<ICartRepository>(
      () => CartRepositoryImpl(sl<IFirestorePathProvider>()));
  sl.registerLazySingleton<IWishlistRepository>(() => WishlistRepositoryImpl(
        firestorePathProvider: sl<IFirestorePathProvider>(),
      ));
}

/// **3. Initialize Services**
void _initServices() {
  sl.registerLazySingleton<AuthService>(
      () => AuthServiceImpl(sl<AccountRepository>()));

  sl.registerLazySingleton<CustomerCompanyService>(
    () => CustomerCompanyServiceImpl(
      sl<CustomerCompanyRepository>(),
      companySettingRepository: sl<CompanySettingRepository>(),
      accountService: sl<AccountRepository>(),
    ),
  );
  sl.registerLazySingleton<TenantCompanyService>(
    () => TenantCompanyServiceImpl(
      sl<ITenantCompanyRepository>(),
    ),
  );

  // ✅ Register CompanyOperationsService
  sl.registerLazySingleton<EmployeeServices>(
    () => EmployeesServiceImpl(
      sl<ITenantCompanyRepository>(),
      sl<AccountRepository>(),
    ),
  );
  sl.registerLazySingleton<TaskService>(
      () => TaskServiceImpl(sl<TaskRepository>(), sl<AccountRepository>()));

  sl.registerLazySingleton<IAccountLedgerService>(
      () => AccountLedgerServiceImpl(
            sl<IAccountLedgerRepository>(),
            sl<AccountRepository>(),
            sl<CustomerCompanyService>(),
          ));
  sl.registerLazySingleton<IUserService>(
      () => UserServiceImpl(sl<AccountRepository>()));
  // ✅ Register Product Service
  sl.registerLazySingleton<ProductService>(() => ProductServiceImpl(
      productRepository: sl<ProductRepository>(), sl<AccountRepository>()));
  sl.registerLazySingleton<CategoryService>(() => CategoryServiceImpl(
        categoryRepository: sl<CategoryRepository>(),
        accountRepository: sl<AccountRepository>(),
      ));

  sl.registerSingleton<LocationUpdateService>(
      LocationUpdateService(sl<EmployeeServices>()));
  sl.registerSingleton<PermissionHandler>(PermissionHandler());
  sl.registerLazySingleton<StockService>(() => StockServiceImpl(
        stockRepository: sl<StockRepository>(),
        accountRepository: sl<AccountRepository>(),
      ));
  sl.registerLazySingleton<TransactionService>(() => TransactionServiceImpl(
        stockRepository: sl<StockRepository>(),
        transactionRepository: sl<TransactionRepository>(),
        accountRepository: sl<AccountRepository>(),
      ));

  sl.registerLazySingleton<IUserProductService>(
      () => UserProductService(stockService: sl<StockService>()));
  sl.registerLazySingleton<IOrderService>(() => OrderService(
        orderRepository: sl<IOrderRepository>(),
        accountRepository: sl<AccountRepository>(),
      ));
  sl.registerLazySingleton<ICartService>(() => CartService(
        cartRepository: sl<ICartRepository>(),
        accountRepository: sl<AccountRepository>(),
      ));
  sl.registerLazySingleton<IWishlistService>(() => WishlistService(
        wishlistRepository: sl<IWishlistRepository>(),
        accountRepository: sl<AccountRepository>(),
      ));
}

/// **4. Initialize Cubits (State Management)**
void _initCubits() {
  sl.registerFactory(
      () => LoginCubit(sl<AuthService>(), sl<TenantCompanyService>()));
  sl.registerLazySingleton(() => ForgotPasswordCubit(sl<AuthService>()));
  sl.registerFactory(() => SplashCubit(sl<AccountRepository>()));

  sl.registerFactory(() => PartnerCubit(sl<CustomerCompanyService>(),
      sl<EmployeeServices>(), sl<IAccountLedgerService>()));
  sl.registerFactory(() => DashboardCubit(sl<AuthService>()));
  sl.registerFactory(() => CompanySettingCubit(sl<CustomerCompanyService>()));

  sl.registerFactory(() => AiCompanyListCubit(
        sl<AiCompanyListRepository>(),
        sl<CompanySettingRepository>(),
        sl<CustomerCompanyRepository>(),
      ));

  // ✅ Register AddTenantCompanyCubit
  sl.registerFactory(() => AddTenantCompanyCubit(
        sl<TenantCompanyService>(),
      ));

  // ✅ Register AddUserCubit for adding users
  sl.registerFactory(() => AddUserCubit(
        sl<EmployeeServices>(),
      ));
  sl.registerFactory(() => TaskCubit(sl<TaskService>(), sl<EmployeeServices>(),
      sl<CustomerCompanyService>(), sl<AccountRepository>()));
  sl.registerFactory(() => AccountLedgerCubit(
        sl<IAccountLedgerService>(),
        sl<AccountRepository>(),
        sl<CustomerCompanyService>(),
      ));
  sl.registerFactory(() => HomeCubit(sl<IUserService>()));
  sl.registerFactory(() => EmployeeCubit(sl<EmployeeServices>()));
  sl.registerFactory(() => AdminProductCubit(
        productService: sl<ProductService>(),
        categoryService: sl<CategoryService>(),
      ));
  sl.registerFactory(() => CategoryCubit(
        categoryService: sl<CategoryService>(),
      ));
  sl.registerFactory(() => EmployeeDetailsCubit(sl<EmployeeServices>()));
  sl.registerFactory(() => AttendanceCubit(sl<EmployeeServices>()));

  sl.registerFactory<StockCubit>(() => StockCubit(
        stockService: sl<StockService>(),
        employeeServices: sl<EmployeeServices>(),
        transactionService: sl<TransactionService>(),
        accountRepository: sl<AccountRepository>(),
      ));
  sl.registerFactory(() => TransactionCubit(
        transactionService: sl<TransactionService>(),
      ));

  sl.registerFactory(() => ProductCubit(
        productService: sl<IUserProductService>(),
        wishlistService: sl<IWishlistService>(),
        cartService: sl<ICartService>(),
      ));
  sl.registerFactory(() => CartCubit(cartService: sl<ICartService>()));
  sl.registerFactory(
      () => WishlistCubit(wishlistService: sl<IWishlistService>()));
  sl.registerFactory(() => OrderCubit(
      orderService: sl<IOrderService>(),
      accountRepository: sl<AccountRepository>()));
  sl.registerFactory(() => AdminOrderCubit(orderService: sl<IOrderService>()));
}

/// **5. Initialize App Navigation & Coordinator**
void _initAppNavigation() {
  sl.registerLazySingleton<AppRouter>(() => AppRouter());
  sl.registerLazySingleton<Coordinator>(() => AppCoordinator(sl<AppRouter>()));
}
