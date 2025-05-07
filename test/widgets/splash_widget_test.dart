import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_screen.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

import '../main.mocks.dart';


void main() {
  late MockSplashCubit mockSplashCubit;
  late MockCoordinator mockCoordinator;

  setUp(() {
    mockSplashCubit = MockSplashCubit();
    mockCoordinator = MockCoordinator();
    sl.registerLazySingleton<SplashCubit>(() => mockSplashCubit);
    sl.registerLazySingleton<Coordinator>(() => mockCoordinator);
  });

  tearDown(() {
    sl.reset();
  });

  testWidgets('displays welcome message and loading spinner', (WidgetTester tester) async {
    // Mock the initial state of the SplashCubit
    when(mockSplashCubit.state).thenReturn(SplashInitial());

    // Stub the SplashCubit stream to emit no states
    when(mockSplashCubit.stream).thenAnswer((_) => Stream.empty());

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SplashCubit>(
          create: (_) => mockSplashCubit,
          child: const SplashScreenPage(),
        ),
      ),
    );

    // Verify the welcome message is displayed
    expect(find.text("Welcome to the App"), findsOneWidget);

    // Verify the loading spinner is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });


  testWidgets('navigates to Dashboard after delay', (WidgetTester tester) async {
    when(mockSplashCubit.state).thenReturn(SplashInitial());
    when(mockSplashCubit.stream).thenAnswer((_) => Stream.fromIterable([NavigateToDashboard()]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SplashCubit>(
          create: (_) => mockSplashCubit,
          child: SplashScreenPage(
            onDelayComplete: () async {
              mockSplashCubit.checkSession();
            },
          ),
        ),
      ),
    );

    verify(mockSplashCubit.checkSession()).called(1);
    await tester.pump();

    verify(mockCoordinator.navigateToDashboardPage()).called(1);
  });

  testWidgets('navigates to Login after delay', (WidgetTester tester) async {
    when(mockSplashCubit.state).thenReturn(SplashInitial());
    when(mockSplashCubit.stream).thenAnswer((_) => Stream.fromIterable([NavigateToLogin()]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SplashCubit>(
          create: (_) => mockSplashCubit,
          child: SplashScreenPage(
            onDelayComplete: () async {
              mockSplashCubit.checkSession();
            },
          ),
        ),
      ),
    );

    verify(mockSplashCubit.checkSession()).called(1);
    await tester.pump();

    verify(mockCoordinator.navigateToLoginPage()).called(1);
  });
}
