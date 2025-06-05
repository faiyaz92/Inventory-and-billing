import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/splash_cubit.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/user_module/services/permission_handler.dart';
import 'package:requirment_gathering_app/user_module/services/update_location_service.dart';

@RoutePage()
class SplashScreenPage extends StatefulWidget {
  final Future<void> Function()? onDelayComplete; // Optional callback for testing

  const SplashScreenPage({super.key, this.onDelayComplete});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> with SingleTickerProviderStateMixin {
  late final SplashCubit splashCubit;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    splashCubit = sl<SplashCubit>();
    // _initializePermissionsAndService();
    _startSplashDelay();
    // Start fade-in animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  Future<void> _initializePermissionsAndService() async {
    final permissionHandler = sl<PermissionHandler>();
    final locationService = sl<LocationUpdateService>();
    final hasPermission = await permissionHandler.requestLocationPermissions(context);
    if (hasPermission) {
      await locationService.initializeService();
    }
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
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(seconds: 1),
                          child: const Text(
                            "Easy Tasks",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            strokeWidth: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, color: Colors.grey[700], size: 30),
                      const SizedBox(width: 8),
                      Text(
                        "Powered by Easy2Solutions",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.code, color: Colors.grey[700], size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}