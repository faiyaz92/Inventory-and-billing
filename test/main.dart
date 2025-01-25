import 'package:mockito/annotations.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/login/splash_cubit.dart';
import 'package:requirment_gathering_app/repositories/account_repository.dart';

@GenerateMocks([AccountRepository,SplashCubit,Coordinator])
void main() {}
