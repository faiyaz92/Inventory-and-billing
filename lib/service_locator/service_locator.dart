import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
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
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/repositories/company_repository_impl.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository_impl.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Register FirebaseAuth
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register AccountRepository
  sl.registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(sl<FirebaseAuth>()));
  sl.registerLazySingleton<AppRouter>(() => AppRouter());
  sl.registerLazySingleton<Coordinator>(() => AppCoordinator(sl<AppRouter>()));

  // Register LoginCubit
  sl.registerFactory(() => LoginCubit(sl<AccountRepository>()));
  // SplashCubit
  sl.registerFactory(() => SplashCubit(sl<AccountRepository>()));
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Company Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(sl<FirebaseFirestore>()),
  );
  sl.registerFactory(() =>
      CompanyCubit(sl<CompanyRepository>(), sl<CompanySettingRepository>()));
  sl.registerFactory(() => DashboardCubit());
  sl.registerLazySingleton<CompanySettingRepository>(
    () => CompanySettingRepositoryImpl(sl<FirebaseFirestore>()),
  );
  sl.registerFactory(() => CompanySettingCubit(sl<CompanySettingRepository>()));

  // AddCompany Cubit
}
