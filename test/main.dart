import 'package:mockito/annotations.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_cubit.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service.dart';

@GenerateMocks([AccountRepository,SplashCubit,Coordinator,AuthService,TenantCompanyService])
void main() {}
