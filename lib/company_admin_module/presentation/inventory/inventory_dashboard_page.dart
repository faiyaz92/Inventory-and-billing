import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600;

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
                        'Welcome to Inventory Dashboard',
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
                Expanded(
                  child: GridView.count(
                    crossAxisCount: isWeb ? 4 : 3,
                    crossAxisSpacing: isWeb ? 16 : 12,
                    mainAxisSpacing: isWeb ? 16 : 12,
                    childAspectRatio: isWeb ? 1.2 : 1.0,
                    children: _buildGridItems(context, isWeb),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGridItems(BuildContext context, bool isWeb) {
    return [
      _buildDashboardCard(
        context,
        'Stock List',
        Icons.list,
        Colors.blue,
            () => sl<Coordinator>().navigateToStockListPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Sales Report',
        Icons.bar_chart,
        Colors.purple,
            () => sl<Coordinator>().navigateToSalesReportPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Transactions',
        Icons.account_balance,
        Colors.teal,
            () => sl<Coordinator>().navigateToTransactionsPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Add Customer',
        Icons.person_add,
        Colors.red,
            () => sl<Coordinator>().navigateToAddUserPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Store List',
        Icons.store,
        Colors.indigo,
            () => sl<Coordinator>().navigateToStoresListPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Add Store',
        Icons.add_business,
        Colors.amber,
            () => sl<Coordinator>().navigateToAddStorePage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Overall Stock',
        Icons.account_balance_wallet,
        Colors.green,
            () => sl<Coordinator>().navigateToOverAllStockPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'My Store',
        Icons.store,
        Colors.orangeAccent,
            () => sl<Coordinator>().navigateToStoreDetailsPage(''),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Store Attendance',
        Icons.people,
        Colors.green,
            () => sl<Coordinator>().navigateToAttendancePage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Add Stock',
        Icons.inventory_2,
        Colors.cyan,
            () => sl<Coordinator>().navigateToAddStockPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Purchase Invoices',
        Icons.receipt_long,
        Colors.cyan,
            () => sl<Coordinator>().navigateToPurchaseInvoicePanelPage(),
        isWeb,
      ),
    ];
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