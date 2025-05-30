import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class CartDashboardPage extends StatelessWidget {
  const CartDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cart Dashboard',
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildDashboardCard(
                        context,
                        'Cart',
                        Icons.list,
                        Colors.blue,
                            () => sl<Coordinator>().navigateToCartHomePage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Cart Admin',
                        Icons.receipt,
                        Colors.orange,
                            () => sl<Coordinator>().navigateToAdminPanelPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Salesman Orders',
                        Icons.receipt,
                        Colors.orange,
                            () => sl<Coordinator>().navigateToSalesManOrderPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Salesman List',
                        Icons.person,
                        Colors.green,
                            () => sl<Coordinator>().navigateToSalesmanOrderListPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Delivery Man List',
                        Icons.delivery_dining,
                        Colors.purple,
                            () => sl<Coordinator>().navigateToDeliveryManOrderListPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Store List',
                        Icons.store,
                        Colors.red,
                            () => sl<Coordinator>().navigateToStoreOrderListPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Customer List',
                        Icons.people,
                        Colors.teal,
                            () => sl<Coordinator>().navigateToCustomerOrderListPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Company Performance',
                        Icons.trending_up,
                        Colors.blueAccent,
                            () => sl<Coordinator>().navigateToCompanyPerformancePage(),
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

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
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