import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define demo expiration date
    final DateTime demoExpirationDate = DateTime(2025,10 , 10);
    final bool isDemoExpired = DateTime.now().isAfter(demoExpirationDate);

    // Determine screen size for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600; // Consider web for screens wider than 600px

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
                  margin: EdgeInsets.all(isWeb ? 32.0 : 16.0),
                  child: Padding(
                    padding: EdgeInsets.all(isWeb ? 32.0 : 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: isWeb ? 64 : 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: isWeb ? 24 : 16),
                        Text(
                          'Your free demo period has ended.',
                          style: TextStyle(
                            fontSize: isWeb ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isWeb ? 12 : 8),
                        Text(
                          'Please purchase a subscription to continue using the app.',
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isWeb ? 32 : 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb ? 32.0 : 24.0,
                              vertical: isWeb ? 16.0 : 12.0,
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
                          child: Text(
                            'Purchase Now',
                            style: TextStyle(fontSize: isWeb ? 18 : 16),
                          ),
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
              isWeb: isWeb,
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
                                "Welcome, ${state.userName}",
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
                            crossAxisCount: isWeb ? 4 : 3, // More columns on web
                            crossAxisSpacing: isWeb ? 16 : 12,
                            mainAxisSpacing: isWeb ? 16 : 12,
                            childAspectRatio: isWeb ? 1.2 : 1.0,
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
              body: Center(
                child: Text(
                  "Error: ${state.message}",
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
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

  List<Widget> _buildGridItemsForRole({
    required BuildContext context,
    required Role role,
    required bool isWeb,
  }) {
    final List<Widget> gridItems = [];

    // Common grid item for all roles: User Ledger
    gridItems.add(
      _buildGridItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'User Ledger',
        color: Colors.deepPurple,
        onTap: () async {
          final user = await sl<AccountRepository>().getUserInfo();
          sl<Coordinator>().navigateToUserLedgerPage(
            user: user?.copyWith(accountLedgerId: '1q3XGuMfV9LunYhnKDh8') ?? UserInfo(),
          );
        },
        isWeb: isWeb,
      ),
    );

    // Role-based access
    switch (role) {
      case Role.SUPER_ADMIN:
        gridItems.add(
          _buildGridItem(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Super Admin',
            color: Colors.cyan,
            onTap: () {
              sl<Coordinator>().navigateToSuperAdminPage();
            },
            isWeb: isWeb,
          ),
        );
        gridItems.add(
          _buildGridItem(
            icon: Icons.add_business_outlined,
            label: 'Add Company',
            color: Colors.orange,
            onTap: () {
              sl<Coordinator>().navigateToAddCompanyPage();
            },
            isWeb: isWeb,
          ),
        );
        break;

      case Role.COMPANY_ADMIN:
        gridItems.addAll([
          _buildGridItem(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Company Admin',
            color: Colors.deepPurple,
            onTap: () {
              sl<Coordinator>().navigateToCompanyAdminPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.add_task,
            label: 'Add Task',
            color: Colors.blue,
            onTap: () {
              sl<Coordinator>().navigateToAddTaskPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.task_alt,
            label: 'Task List',
            color: Colors.green,
            onTap: () {
              sl<Coordinator>().navigateToTaskListPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.settings_outlined,
            label: 'Company Settings',
            color: Colors.indigo,
            onTap: () {
              sl<Coordinator>().navigateToCompanySettingsPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.inventory_2_outlined,
            label: 'Product Management',
            color: Colors.lightGreenAccent,
            onTap: () {
              sl<Coordinator>().navigateToProductManagementPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.bar_chart_outlined,
            label: 'Sales Dashboard',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToCartDashboard();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.warehouse_outlined,
            label: 'Inventory',
            color: Colors.teal,
            onTap: () {
              sl<Coordinator>().navigateToInventoryDashBoard();
            },
            isWeb: isWeb,
          ),_buildGridItem(
            icon: Icons.account_balance_wallet,
            label: 'Accounts',
            color: Colors.green,
            onTap: () {
              sl<Coordinator>().navigateToAccountsDashboard();
            },
            isWeb: isWeb,
          ),
        ]);
        break;

      case Role.STORE_ADMIN:
        gridItems.addAll([
          _buildGridItem(
            icon: Icons.storefront_outlined,
            label: 'My Store',
            color: Colors.orangeAccent,
            onTap: () {
              sl<Coordinator>().navigateToStoreDetailsPage('');
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.store_mall_directory_outlined,
            label: 'Store List',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToStoresListPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.inventory_outlined,
            label: 'Stock List',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToStockListPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.storage_outlined,
            label: 'Overall Stock',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToOverAllStockPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.event_available_outlined,
            label: 'Store Attendance',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToAttendancePage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.add_task,
            label: 'Add Task',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToAddTaskPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.task_alt,
            label: 'Task List',
            color: Colors.green,
            onTap: () {
              sl<Coordinator>().navigateToTaskListPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Add Customer',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToAddUserPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.receipt_long_outlined,
            label: 'Billing Customer',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToBillingPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Cart Management',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToCartDashboard();
            },
            isWeb: isWeb,
          ),
        ]);
        break;

      case Role.SALES_MAN:
        gridItems.addAll([
          _buildGridItem(
            icon: Icons.receipt,
            label: 'Cart Admin',
            color: Colors.orange,
            onTap: () {
              sl<Coordinator>().navigateToAdminPanelPage();
            },
            isWeb: isWeb,
          ),
          _buildGridItem(
            icon: Icons.book,
            label: 'Salesman Orders',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToSalesManOrderPage();
            },
            isWeb: isWeb,
          ),
        ]);
        break;

      case Role.DELIVERY_MAN:
      // Empty access for now, only User Ledger is added above
        break;

      case Role.STORE_ACCOUNTANT:
      // Empty access for now, only User Ledger is added above
        break;

      case Role.STORE_MANAGER:
      // Empty access for now, only User Ledger is added above
        break;

      case Role.COMPANY_ACCOUNTANT:
      // Empty access for now, only User Ledger is added above
        break;

      case Role.USER:
      // Empty access for now, only User Ledger is added above
        break;
    }

    return gridItems;
  }


  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isWeb,
  }) {
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
                label,
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