import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/login/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function()? onDelayComplete; // Optional callback for testing

  const SplashScreen({super.key, this.onDelayComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final splashCubit;

  @override
  void initState() {
    super.initState();
    splashCubit = sl<SplashCubit>();

    _startSplashDelay();
  }

  void _startSplashDelay() {
    if (widget.onDelayComplete != null) {
      widget.onDelayComplete!(); // Testing callback
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          splashCubit.checkSession();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      bloc: splashCubit,
      listener: (context, state) {
        if (state is NavigateToDashboard) {
          sl<Coordinator>().navigateToDashboardPage();
        } else if (state is NavigateToLogin) {
          sl<Coordinator>().navigateToLoginPage();
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to the App",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
