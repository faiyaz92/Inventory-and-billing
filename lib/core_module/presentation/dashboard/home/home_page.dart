import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define demo expiration date
    final DateTime demoExpirationDate = DateTime(2025, 7, 10);
    final bool isDemoExpired = DateTime.now().isAfter(demoExpirationDate);

    return BlocProvider(
      create: (context) => sl<HomeCubit>()..fetchUserInfo(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // If demo is expired, show purchase message
          if (isDemoExpired) {
            return Scaffold(
              body: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your free demo period has ended.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please purchase a subscription to continue using the app.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Contact support to purchase a subscription.'),
                              ),
                            );
                          },
                          child: const Text('Purchase Now'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Existing UI for non-expired demo
          if (state is HomeLoading) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          } else if (state is HomeLoaded) {
            final List<Widget> gridItems = _buildGridItemsForRole(
              context: context,
              role: state.role,
              userName: state.userName, // Pass userName for the welcome message
            );

            return Scaffold(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Welcome, ${state.userName}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                            children: gridItems,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is HomeError) {
            return Scaffold(
              appBar: CustomAppBar(
                title: 'Home Dashboard',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => sl<Coordinator>().navigateToAddStockPage(),
                    tooltip: 'Add Stock',
                  ),
                ],
              ),
              body: Center(
                child: Text(
                  "Error: ${state.message}",
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            );
          }
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Home Dashboard',
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => sl<Coordinator>().navigateToAddStockPage(),
                  tooltip: 'Add Stock',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGridItemsForRole({
    required BuildContext context,
    required Role role,
    required String userName,
  }) {
    final List<Widget> gridItems = [];

    // Role-specific tiles

    // Add all tiles from CartDashboardPage for all roles
    gridItems.addAll([
      _buildGridItem(
        icon: Icons.admin_panel_settings_outlined,
        label: 'Taxi admin',
        color: Colors.orange,
        onTap: () => sl<Coordinator>().navigateToTaxiBookingsAdminPage(),
      ),
      _buildGridItem(
        icon: Icons.local_taxi,
        label: 'Taxi booking',
        color: Colors.blue,
        onTap: () => sl<Coordinator>().navigateToTaxiBookingPage(),
      ),
      _buildGridItem(
        icon: Icons.tune,
        label: 'Taxi Setting',
        color: Colors.green,
        onTap: () => sl<Coordinator>().navigateToTaxiSettingsPage(),
      ),
      _buildGridItem(
        icon: Icons.people_alt,
        label: 'Driver List',
        color: Colors.purple,
        onTap: () => sl<Coordinator>().navigateToDriverListPage(),
      ),
      _buildGridItem(
        icon: Icons.trending_up,
        label: 'Taxi Company performance',
        color: Colors.teal,
        onTap: () => sl<Coordinator>().navigateToTaxiCompanyPerformancePage(),
      ),
      _buildGridItem(
        icon: Icons.traffic,
        label: 'Taxi Company visitor counter',
        color: Colors.red,
        onTap: () => sl<Coordinator>().navigateToTaxiVisitorCounterPage(),
      ),
      _buildGridItem(
        icon: Icons.history_toggle_off,
        label: 'Booking history',
        color: Colors.amber,
        onTap: () => sl<Coordinator>().navigateToUserBookingHistory(),
      ),
      _buildGridItem(
        icon: Icons.web,
        label: 'WEB',
        color: Colors.indigo,
        onTap: () => sl<Coordinator>().navigateToWebApp(),
      ),
      _buildGridItem(
        icon: Icons.nights_stay,
        label: 'Taxi admin dark',
        color: Colors.blueGrey,
        onTap: () => sl<Coordinator>().navigateToTaxiBookingsAdminDarkPage(),
      ),
      _buildGridItem(
        icon: Icons.admin_panel_settings,
        label: 'Company Admin',
        color: Colors.deepPurple,
        onTap: () {
          sl<Coordinator>().navigateToCompanyAdminPage();
        },
      ),
      _buildGridItem(
        icon: Icons.today,
        label: "Today's Booking",
        color: Colors.cyan,
        onTap: () => sl<Coordinator>().navigateToTodaysTaxiBookingsPage(),
      ),
    ]);

    return gridItems;
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        color: Colors.white,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
