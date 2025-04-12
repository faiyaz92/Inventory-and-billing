import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/login_state.dart';

import '../main.mocks.dart';


void main() {
  late  MockAuthService mockLoginService;
  late MockTenantCompanyService mockITenantCompanyService;
  late LoginCubit loginCubit;

  setUp(() {
    mockLoginService = MockAuthService();
    mockITenantCompanyService = MockTenantCompanyService();
    loginCubit = LoginCubit(mockLoginService,mockITenantCompanyService);
  });

  tearDown(() {
    loginCubit.close();
  });

  group('LoginCubit Tests', () {
    blocTest<LoginCubit, LoginState>(
      'emits [EmailValidationError] when email is invalid',
      build: () => loginCubit,
      act: (cubit) => cubit.validateEmail('invalid-email'),
      expect: () => [
        EmailValidationError('Invalid email format.'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [PasswordValidationError] when password is empty',
      build: () => loginCubit,
      act: (cubit) => cubit.validatePassword(''),
      expect: () => [
        PasswordValidationError('Password is required.'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginSuccess] when login is successful',
      build: () {
        when(mockLoginService.signIn(any, any))
            .thenAnswer((_) async => null); // Mock successful login
        return loginCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password123'),
      expect: () => [
        LoginLoading(),
        LoginSuccess(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] when login fails',
      build: () {
        when(mockLoginService.signIn(any, any))
            .thenThrow(Exception('Login failed')); // Mock login failure
        return loginCubit;
      },
      act: (cubit) => cubit.login('test@example.com', 'password123'),
      expect: () => [
        LoginLoading(),
        LoginFailure('Exception: Login failed'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginInitial] after logout',
      build: () {
        when(mockLoginService.signOut()).thenAnswer((_) async => null);
        return loginCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        LoginInitial(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [EmailValidationError] when email is empty during login',
      build: () => loginCubit,
      act: (cubit) => cubit.login('', 'password123'),
      expect: () => [
        EmailValidationError('Invalid or missing email.'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [PasswordValidationError] when password is empty during login',
      build: () => loginCubit,
      act: (cubit) => cubit.login('test@example.com', ''),
      expect: () => [
        PasswordValidationError('Password is required.'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [EmailValidationError, LoginInitial] when email is cleared and becomes valid',
      build: () => loginCubit,
      act: (cubit) {
        cubit.validateEmail('invalid-email');
        cubit.validateEmail('valid@example.com');
      },
      expect: () => [
        EmailValidationError('Invalid email format.'),
        LoginInitial(), // Clears previous error
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [PasswordValidationError, LoginInitial] when password is cleared and becomes valid',
      build: () => loginCubit,
      act: (cubit) {
        cubit.validatePassword('');
        cubit.validatePassword('validpassword123');
      },
      expect: () => [
        PasswordValidationError('Password is required.'),
        LoginInitial(), // Clears previous error
      ],
    );
  });
}
