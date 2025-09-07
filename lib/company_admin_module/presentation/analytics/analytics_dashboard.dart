import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';

@RoutePage()
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define demo expiration date
    final DateTime demoExpirationDate = DateTime(2025, 10, 10);
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
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  margin: const EdgeInsets.all(kIsWeb ? 32.0 : 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(kIsWeb ? 32.0 : 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: kIsWeb ? 64 : 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: kIsWeb ? 24 : 16),
                        const Text(
                          'Your free demo period has ended.',
                          style: TextStyle(
                            fontSize: kIsWeb ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kIsWeb ? 12 : 8),
                        const Text(
                          'Please purchase a subscription to continue using the app.',
                          style: TextStyle(
                            fontSize: kIsWeb ? 18 : 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: kIsWeb ? 32 : 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: kIsWeb ? 32.0 : 24.0,
                              vertical: kIsWeb ? 16.0 : 12.0,
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
                          child: const Text(
                            'Purchase Now',
                            style: TextStyle(fontSize: kIsWeb ? 18 : 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Handle states
          if (state is HomeLoading) {
            return Scaffold(
              appBar: CustomAppBar(
                title: 'Analytics Dashboard',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Stock',
                    onPressed: () => sl<Coordinator>().navigateToAddStockPage(),
                  ),
                ],
              ),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          } else if (state is HomeLoaded) {
            return Scaffold(
              appBar: CustomAppBar(
                title: 'Analytics Dashboard',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Stock',
                    onPressed: () => sl<Coordinator>().navigateToAddStockPage(),
                  ),
                ],
              ),
              body: Container(
                height: MediaQuery.of(context).size.height, // Fix: Set explicit height
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGroupSection(
                            context,
                            'Employee Analytics',
                            [
                              _buildDashboardCard(
                                context,
                                'Top Salesman List',
                                Icons.people,
                                Colors.green,
                                    () => sl<Coordinator>().navigateToSalesmanOrderListPage(),
                              ),
                              _buildDashboardCard(
                                context,
                                'Top Delivery Men List',
                                Icons.delivery_dining,
                                Colors.purple,
                                    () => sl<Coordinator>().navigateToDeliveryManOrderListPage(),
                              ),
                            ],
                          ),
                          const SizedBox(height: kIsWeb ? 32 : 24),
                          _buildGroupSection(
                            context,
                            'Company Analytics',
                            [
                              _buildDashboardCard(
                                context,
                                'Top Customers List',
                                Icons.people,
                                Colors.teal,
                                    () => sl<Coordinator>().navigateToCustomerOrderListPage(),
                              ),
                              _buildDashboardCard(
                                context,
                                'Top Store List',
                                Icons.store,
                                Colors.red,
                                    () => sl<Coordinator>().navigateToStoreOrderListPage(),
                              ),
                              _buildDashboardCard(
                                context,
                                'Company Performance',
                                Icons.trending_up,
                                Colors.blueAccent,
                                    () => sl<Coordinator>().navigateToCompanyPerformancePage(),
                              ),
                              _buildDashboardCard(
                                context,
                                'Product Performance',
                                Icons.trending_up,
                                Colors.blueAccent,
                                    () => sl<Coordinator>().navigateToProductPerformanceListPage(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (state is HomeError) {
            return Scaffold(
              appBar: CustomAppBar(
                title: 'Analytics Dashboard',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Stock',
                    onPressed: () => sl<Coordinator>().navigateToAddStockPage(),
                  ),
                ],
              ),
              body: Center(
                child: Text(
                  "Error: ${state.message}",
                  style: const TextStyle(
                    fontSize: kIsWeb ? 18 : 16,
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }
          return const Scaffold();
        },
      ),
    );
  }

  Widget _buildGroupSection(
      BuildContext context,
      String title,
      List<Widget> children,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kIsWeb ? 16.0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: kIsWeb ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: kIsWeb ? 7 : 3,
              crossAxisSpacing: kIsWeb ? 16 : 12,
              mainAxisSpacing: kIsWeb ? 16 : 12,
              childAspectRatio: kIsWeb ? 1.0 : 1.0,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Colors.grey[50], // Offwhite background
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: kIsWeb ? 28 : 36,
                color: color,
              ),
              const SizedBox(height: kIsWeb ? 12 : 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: kIsWeb ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
