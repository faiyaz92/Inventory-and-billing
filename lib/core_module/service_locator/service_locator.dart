import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/add_user_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/task_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/account_ledger_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/task_repository_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/task_service_impl.dart';
import 'package:requirment_gathering_app/company_admin_module/service/tenant_company_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/tenant_company_service_impl.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.gr.dart';
import 'package:requirment_gathering_app/core_module/coordinator/app_cordinator.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/dashboard_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_cubit.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository_impl.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service_impl.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider_impl.dart';
import 'package:requirment_gathering_app/core_module/services/provider.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/presentation/ai_company_list_cubit.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/repositories/ai_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/ai_module/repositories/ai_company_repository_impl.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_cubit.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository_impl.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service_impl.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/company_cubit.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_settings/company_settings_cubit.dart';
import 'package:requirment_gathering_app/user_module/repo/company_repository.dart';
import 'package:requirment_gathering_app/user_module/repo/company_repository_impl.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository_impl.dart';
import 'package:requirment_gathering_app/user_module/services/company_service.dart';
import 'package:requirment_gathering_app/user_module/services/company_service_impl.dart';

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
  sl.registerFactory<CompanyRepository>(() => CompanyRepositoryImpl(
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
}

/// **3. Initialize Services**
void _initServices() {
  sl.registerLazySingleton<AuthService>(
      () => AuthServiceImpl(sl<AccountRepository>()));

  sl.registerLazySingleton<CompanyService>(
    () => CompanyServiceImpl(
      sl<CompanyRepository>(),
      companySettingRepository: sl<CompanySettingRepository>(),
    ),
  );
  sl.registerLazySingleton<TenantCompanyService>(
    () => TenantCompanyServiceImpl(
      sl<ITenantCompanyRepository>(),
    ),
  );

  // ✅ Register CompanyOperationsService
  sl.registerLazySingleton<CompanyOperationsService>(
    () => CompanyOperationsServiceImpl(
      sl<ITenantCompanyRepository>(),
      sl<AccountRepository>(),
    ),
  );
  sl.registerLazySingleton<TaskService>(
          () => TaskServiceImpl(sl<TaskRepository>(), sl<AccountRepository>()));

  sl.registerLazySingleton<IAccountLedgerService>(
          () => AccountLedgerServiceImpl(sl<IAccountLedgerRepository>()));

}

/// **4. Initialize Cubits (State Management)**
void _initCubits() {
  sl.registerFactory(
      () => LoginCubit(sl<AuthService>(), sl<TenantCompanyService>()));
  sl.registerFactory(() => SplashCubit(sl<AccountRepository>()));

  sl.registerFactory(() => CompanyCubit(sl<CompanyService>()));
  sl.registerFactory(() => DashboardCubit());
  sl.registerFactory(() => CompanySettingCubit(sl<CompanyService>()));

  sl.registerFactory(() => AiCompanyListCubit(
        sl<AiCompanyListRepository>(),
        sl<CompanySettingRepository>(),
        sl<CompanyRepository>(),
      ));

  // ✅ Register AddTenantCompanyCubit
  sl.registerFactory(() => AddTenantCompanyCubit(
        sl<TenantCompanyService>(),
      ));

  // ✅ Register AddUserCubit for adding users
  sl.registerFactory(() => AddUserCubit(
        sl<CompanyOperationsService>(),
      ));
  sl.registerFactory(() => TaskCubit(sl<TaskService>()));
  sl.registerFactory(() => AccountLedgerCubit(sl<IAccountLedgerService>()));

}

/// **5. Initialize App Navigation & Coordinator**
void _initAppNavigation() {
  sl.registerLazySingleton<AppRouter>(() => AppRouter());
  sl.registerLazySingleton<Coordinator>(() => AppCoordinator(sl<AppRouter>()));
}
