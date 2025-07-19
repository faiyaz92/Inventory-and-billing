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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sales Dashboard',
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
                        'Welcome to Sales Dashboard',
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
        'Cart',
        Icons.list,
        Colors.blue,
            () => sl<Coordinator>().navigateToCartHomePage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Cart Admin',
        Icons.receipt,
        Colors.orange,
            () => sl<Coordinator>().navigateToAdminPanelPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Salesman Orders',
        Icons.book,
        Colors.blueAccent,
            () => sl<Coordinator>().navigateToSalesManOrderPage(),
        isWeb,
      ),
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
        'Top Customers List',
        Icons.people,
        Colors.teal,
            () => sl<Coordinator>().navigateToCustomerOrderListPage(),
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
      _buildDashboardCard(
        context,
        'Billing',
        Icons.receipt,
        Colors.orange,
            () => sl<Coordinator>().navigateToBillingPage(),
        isWeb,
      ),
      _buildDashboardCard(
        context,
        'Invoices',
        Icons.receipt_long,
        Colors.cyan,
            () => sl<Coordinator>().navigateToInvoiceListPage(),
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