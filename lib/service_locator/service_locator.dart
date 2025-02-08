import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:requirment_gathering_app/ai_module/ai_company_list_cubit.dart';
import 'package:requirment_gathering_app/app_router/app_router.gr.dart';
import 'package:requirment_gathering_app/coordinator/app_cordinator.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/dashboard/home/company_settings_cubit.dart';
import 'package:requirment_gathering_app/dashboard/home/dashboard_cubit.dart';
import 'package:requirment_gathering_app/login/login_cubit.dart';
import 'package:requirment_gathering_app/login/splash_cubit.dart';
import 'package:requirment_gathering_app/repositories/account_repository.dart';
import 'package:requirment_gathering_app/repositories/account_repository_impl.dart';
import 'package:requirment_gathering_app/repositories/ai_company_repository.dart';
import 'package:requirment_gathering_app/repositories/ai_company_repository_impl.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/repositories/company_repository_impl.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository_impl.dart';
import 'package:requirment_gathering_app/services/company_service.dart';
import 'package:requirment_gathering_app/services/company_service_impl.dart';
import 'package:requirment_gathering_app/services/firestore_provider.dart';
import 'package:requirment_gathering_app/services/firestore_provider_impl.dart';
import 'package:requirment_gathering_app/services/login_service.dart';
import 'package:requirment_gathering_app/services/login_service_impl.dart';
import 'package:requirment_gathering_app/services/provider.dart';

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
  sl.registerLazySingleton<FirestorePathProvider>(() => FirestorePathProviderImpl(sl<FirebaseFirestore>()));
}

/// **2. Initialize Repositories**
void _initRepositories() {
  // Account Repository
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(sl<FirebaseAuth>()));

  // Company Repository
  sl.registerFactory<CompanyRepository>(() => CompanyRepositoryImpl(sl<FirestorePathProvider>()));

  // Company Setting Repository
  sl.registerLazySingleton<CompanySettingRepository>(() => CompanySettingRepositoryImpl(sl<FirestorePathProvider>()));

  // AI Company Repository
  sl.registerLazySingleton<AiCompanyListRepository>(() => AiCompanyListRepositoryImpl(sl<DioClientProvider>()));
}

/// **3. Initialize Services**
void _initServices() {
  sl.registerLazySingleton<LoginService>(() => LoginServiceImpl(sl<AccountRepository>()));

  sl.registerLazySingleton<CompanyService>(
        () => CompanyServiceImpl(
      sl<CompanyRepository>(),
      companySettingRepository: sl<CompanySettingRepository>(),
    ),
  );
}

/// **4. Initialize Cubits (State Management)**
void _initCubits() {
  sl.registerFactory(() => LoginCubit(sl<LoginService>()));
  sl.registerFactory(() => SplashCubit(sl<AccountRepository>()));

  sl.registerFactory(() => CompanyCubit(sl<CompanyService>()));
  sl.registerFactory(() => DashboardCubit());
  sl.registerFactory(() => CompanySettingCubit(sl<CompanyService>()));

  sl.registerFactory(() => AiCompanyListCubit(
    sl<AiCompanyListRepository>(),
    sl<CompanySettingRepository>(),
    sl<CompanyRepository>(),
  ));
}

/// **5. Initialize App Navigation & Coordinator**
void _initAppNavigation() {
  sl.registerLazySingleton<AppRouter>(() => AppRouter());
  sl.registerLazySingleton<Coordinator>(() => AppCoordinator(sl<AppRouter>()));
}
