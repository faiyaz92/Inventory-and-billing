import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.dart'
    show AppRouter;
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Main: Initializing Firebase');
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAY3TseN8w0IvVJIxpaYvLKnP3H1DmtFYg',
        authDomain: 'requiementgathering.firebaseapp.com',
        projectId: 'requiementgathering',
        storageBucket: 'requiementgathering.firebasestorage.app',
        messagingSenderId: '297040139948',
        appId: '1:297040139948:web:4a339a1d3150e95a3c3109',
        measurementId: 'G-TB2KW7KLLB',
      ),
    );
    print('Main: Firebase initialized successfully');
  } catch (e) {
    print('Main: Firebase initialization failed: $e');
    // Proceed to avoid crash, SplashCubit will handle the error
  }
  print('Main: Setting up service locator');
  try {
    await setupServiceLocator();
    print('Main: Service locator setup completed');
  } catch (e) {
    print('Main: Service locator setup failed: $e');
  }
  print('Main: Running app');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp: Building MaterialApp.router');
    final appRouter = sl.get<AppRouter>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blue.shade800,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
        ),
      ),
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}