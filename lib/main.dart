import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/app_router/app_router.dart'
    show AppRouter;
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl.get<AppRouter>();
    return Material(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
      
        theme: ThemeData(
          primaryColor: Colors.blue,
          // fontFamily: 'Roboto', // Default font for the app
      
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.blue.shade800,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.7),
          ),
        ),
        routerDelegate: appRouter.delegate(),
        routeInformationParser: appRouter.defaultRouteParser(),
      ),
    );
  }
}
