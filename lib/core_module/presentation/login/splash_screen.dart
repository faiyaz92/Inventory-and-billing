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
  double _carOffset = -100.0; // For car animation

  @override
  void initState() {
    super.initState();
    splashCubit = sl<SplashCubit>();
    // _initializePermissionsAndService();
    _startSplashDelay();
    // Start fade-in and car slide animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _carOffset = 0.0; // Slide car into view
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
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          splashCubit.checkSession();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    final double basePadding = 16.0 * scaleFactor;

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
        backgroundColor: const Color(0xFF1C2526), // Match TaxiBookingPage background
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A2F32), // Darker shade to align with TaxiBookingPage
                Color(0xFF1C2526), // Primary background color
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
                          child: Text(
                            "EasyRide",
                            style: TextStyle(
                              fontFamily: 'Poppins', // Match TaxiBookingPage font
                              fontSize: 48 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                              letterSpacing: 1.5,
                              shadows: const [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black45,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scaleFactor),
                        AnimatedSlide(
                          offset: Offset(_carOffset / 100, 0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          child: Icon(
                            Icons.local_taxi_rounded,
                            size: 80 * scaleFactor,
                            color: const Color(0xFFFACC15), // Match TaxiBookingPage accent color
                          ),
                        ),
                        SizedBox(height: 24 * scaleFactor),
                        AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(seconds: 1),
                          child: Text(
                            "Your Journey, Our Priority",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label color
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: basePadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_taxi,
                        color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label color
                        size: 24 * scaleFactor,
                      ),
                      SizedBox(width: 8 * scaleFactor),
                      Text(
                        "Powered by Easy2Solutions",
                        style: TextStyle(
                          fontFamily: 'Poppins', // Match TaxiBookingPage font
                          fontSize: 16 * scaleFactor,
                          color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8 * scaleFactor),
                      Icon(
                        Icons.directions_car,
                        color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label color
                        size: 24 * scaleFactor,
                      ),
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