import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_cubit.dart';

import '../main.mocks.dart';


void main() {
  late SplashCubit splashCubit;
  late MockAccountRepository mockAccountRepository;

  setUp(() {
    mockAccountRepository = MockAccountRepository();
    splashCubit = SplashCubit(mockAccountRepository);
  });

  tearDown(() {
    splashCubit.close();
  });

  group('SplashCubit Tests', () {
    blocTest<SplashCubit, SplashState>(
      'emits [NavigateToDashboard] when user is logged in',
      build: () {
        when(mockAccountRepository.isUserLoggedIn()).thenReturn(true);
        return splashCubit;
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [NavigateToDashboard()],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [NavigateToLogin] when user is not logged in',
      build: () {
        when(mockAccountRepository.isUserLoggedIn()).thenReturn(false);
        return splashCubit;
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [NavigateToLogin()],
    );
  });
}
