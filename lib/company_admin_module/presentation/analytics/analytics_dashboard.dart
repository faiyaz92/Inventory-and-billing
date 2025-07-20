import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analytics Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => sl<Coordinator>().navigateToAddStockPage(),
            tooltip: 'Add Stock',
          ),
        ],
      ),
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
                        child: Text(
                          'Welcome to Analytics Dashboard',
                          style: TextStyle(
                            fontSize: isWeb ? 28 : 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isWeb ? 32 : 24),
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
                        isWeb,
                      ),
                      _buildDashboardCard(
                        context,
                        'Top Delivery Men List',
                        Icons.delivery_dining,
                        Colors.purple,
                            () => sl<Coordinator>().navigateToDeliveryManOrderListPage(),
                        isWeb,
                      ),
                    ],
                    isWeb,
                  ),
                  SizedBox(height: isWeb ? 32 : 24),
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
                        isWeb,
                      ),
                      _buildDashboardCard(
                        context,
                        'Top Store List',
                        Icons.store,
                        Colors.red,
                            () => sl<Coordinator>().navigateToStoreOrderListPage(),
                        isWeb,
                      ),
                      _buildDashboardCard(
                        context,
                        'Company Performance',
                        Icons.trending_up,
                        Colors.blueAccent,
                            () => sl<Coordinator>().navigateToCompanyPerformancePage(),
                        isWeb,
                      ),
                      _buildDashboardCard(
                        context,
                        'Product Performance',
                        Icons.trending_up,
                        Colors.blueAccent,
                            () => sl<Coordinator>().navigateToProductPerformanceListPage(),
                        isWeb,
                      ),
                    ],
                    isWeb,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSection(
      BuildContext context,
      String title,
      List<Widget> children,
      bool isWeb,
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
        padding: EdgeInsets.all(isWeb ? 16.0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: isWeb ? 4 : 3,
              crossAxisSpacing: isWeb ? 16 : 12,
              mainAxisSpacing: isWeb ? 16 : 12,
              childAspectRatio: isWeb ? 1.2 : 1.0,
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
      bool isWeb,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        color: Colors.white,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isWeb ? 48 : 36,
                color: color,
              ),
              SizedBox(height: isWeb ? 12 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isWeb ? 16 : 14,
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