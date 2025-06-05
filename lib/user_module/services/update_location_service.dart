import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:geolocator/geolocator.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class LocationUpdateService {
  final UserServices _employeeServices;
  static final service = FlutterBackgroundService();

  LocationUpdateService(this._employeeServices);

  Future<void> initializeService() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'location_service',
        initialNotificationTitle: 'Location Service',
        initialNotificationContent: 'Updating your location in the background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    await service.startService();
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'Location Service',
        content: 'Updating your location in the background',
      );
    }

    final employeeServices = sl<UserServices>();
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return; // Location services disabled
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return; // No permission
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await employeeServices.updateUserLocation(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        // Log error (consider using a logging service)
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  Future<void> stopService() async {
    if (await service.isRunning()) {
      service.invoke('stopService');
    }
  }
}