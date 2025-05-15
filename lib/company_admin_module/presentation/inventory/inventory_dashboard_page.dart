import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inventory Dashboard',
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

                // GridView
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildDashboardCard(
                        context,
                        'Stock List',
                        Icons.list,
                        Colors.blue,
                            () => sl<Coordinator>().navigateToStockListPage(),
                      ),

                      _buildDashboardCard(
                        context,
                        'Billing',
                        Icons.receipt,
                        Colors.orange,
                            () => sl<Coordinator>().navigateToBillingPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Sales Report',
                        Icons.bar_chart,
                        Colors.purple,
                            () => sl<Coordinator>().navigateToSalesReportPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Transactions',
                        Icons.account_balance,
                        Colors.teal,
                            () => sl<Coordinator>().navigateToTransactionsPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Add Customer',
                        Icons.person_add,
                        Colors.red,
                            () => sl<Coordinator>().navigateToAddUserPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Store List',
                        Icons.store,
                        Colors.indigo,
                            () => sl<Coordinator>().navigateToStoresListPage(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Add Store',
                        Icons.add_business,
                        Colors.amber,
                            () => sl<Coordinator>().navigateToAddStorePage(),
                      ),_buildDashboardCard(
                        context,
                        'Over all stock',
                        Icons.food_bank,
                        Colors.green,
                            () => sl<Coordinator>().navigateToOverAllStockPage(),
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