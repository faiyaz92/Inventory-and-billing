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
                            // TODO: Implement purchase flow (e.g., navigate to subscription page)
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
              body: Center(
                child: Text(
                  "Error: ${state.message}",
                  style: const TextStyle(fontSize: 16, color: Colors.red),
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
  }) {
    final List<Widget> gridItems = [];

    if (role == Role.SUPER_ADMIN) {
      gridItems.add(
        _buildGridItem(
          icon: Icons.admin_panel_settings,
          label: 'Super Admin',
          color: Colors.cyan,
          onTap: () {
            sl<Coordinator>().navigateToSuperAdminPage();
          },
        ),
      );
    } else if (role == Role.COMPANY_ADMIN) {
      gridItems.addAll([
        _buildGridItem(
          icon: Icons.admin_panel_settings,
          label: 'Company Admin',
          color: Colors.deepPurple,
          onTap: () {
            sl<Coordinator>().navigateToCompanyAdminPage();
          },
        ),
        _buildGridItem(
          icon: Icons.add_task_outlined,
          label: 'Add Task',
          color: Colors.blue,
          onTap: () {
            sl<Coordinator>().navigateToAddTaskPage();
          },
        ),
        _buildGridItem(
          icon: Icons.task,
          label: 'Task List',
          color: Colors.green,
          onTap: () {
            sl<Coordinator>().navigateToTaskListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.business,
          label: 'Add Site',
          color: Colors.orange,
          onTap: () {
            sl<Coordinator>().navigateToAddCompanyPage();
          },
        ),
        _buildGridItem(
          icon: Icons.add_business,
          label: 'Site List',
          color: Colors.purple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Site List Coming Soon!"),
              ),
            );
          },
        ),
        _buildGridItem(
          icon: Icons.business,
          label: 'Add Supplier',
          color: Colors.red,
          onTap: () {
            sl<Coordinator>().navigateToAddEditSupplierPage();
          },
        ),
        _buildGridItem(
          icon: Icons.add_business,
          label: 'Supplier List',
          color: Colors.teal,
          onTap: () {
            sl<Coordinator>().navigateToSupplierListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.lightbulb,
          label: 'Add Strategy',
          color: Colors.amber,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Add Strategy Coming Soon!"),
              ),
            );
          },
        ),
        _buildGridItem(
          icon: Icons.settings,
          label: 'Company Settings',
          color: Colors.indigo,
          onTap: () {
            sl<Coordinator>().navigateToCompanySettingsPage();
          },
        ),
        _buildGridItem(
          icon: Icons.work,
          label: 'Product Management',
          color: Colors.lightGreenAccent,
          onTap: () {
            sl<Coordinator>().navigateToProductManagementPage();
          },
        ),
        _buildGridItem(
          icon: Icons.attach_money,
          label: 'Sales Dashboard',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToCartDashboard();
          },
        ),
        _buildGridItem(
          icon: Icons.inventory,
          label: 'Inventory',
          color: Colors.teal,
          onTap: () {
            sl<Coordinator>().navigateToInventoryDashBoard();
          },
        ),
      ]);
    } else if (role == Role.STORE_ADMIN) {
      gridItems.addAll([
        _buildGridItem(
          icon: Icons.store,
          label: 'My store',
          color: Colors.orangeAccent,
          onTap: () {
            sl<Coordinator>().navigateToStoreDetailsPage('');
          },
        ),
        _buildGridItem(
          icon: Icons.store,
          label: 'Store List',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToStoresListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.web_asset,
          label: 'Stock List',
          color: Colors.blueAccent,
          onTap: () {
            sl<Coordinator>().navigateToStockListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.store,
          label: 'Over all stock',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToOverAllStockPage();
          },
        ),
        _buildGridItem(
          icon: Icons.store,
          label: 'Store Attendance',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToAttendancePage();
          },
        ),
        _buildGridItem(
          icon: Icons.add_task_outlined,
          label: 'Add Task',
          color: Colors.blue,
          onTap: () {
            sl<Coordinator>().navigateToAddTaskPage();
          },
        ),
        _buildGridItem(
          icon: Icons.task,
          label: 'Task List',
          color: Colors.green,
          onTap: () {
            sl<Coordinator>().navigateToTaskListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.manage_accounts,
          label: 'Add Customer',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToAddUserPage();
          },
        ),
        _buildGridItem(
          icon: Icons.manage_accounts,
          label: 'Billing Customer',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToBillingPage();
          },
        ),
        _buildGridItem(
          icon: Icons.shopping_cart,
          label: 'Cart Management',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToCartDashboard();
          },
        ),
      ]);
    } else {
      gridItems.addAll([
        _buildGridItem(
          icon: Icons.add_task_outlined,
          label: 'Add Task',
          color: Colors.blue,
          onTap: () {
            sl<Coordinator>().navigateToAddTaskPage();
          },
        ),
        _buildGridItem(
          icon: Icons.task,
          label: 'Task List',
          color: Colors.green,
          onTap: () {
            sl<Coordinator>().navigateToTaskListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.business,
          label: 'Add Site',
          color: Colors.orange,
          onTap: () {
            sl<Coordinator>().navigateToAddCompanyPage();
          },
        ),
        _buildGridItem(
          icon: Icons.add_business,
          label: 'Site List',
          color: Colors.purple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Site List Coming Soon!"),
              ),
            );
          },
        ),
        _buildGridItem(
          icon: Icons.business,
          label: 'Add Supplier',
          color: Colors.red,
          onTap: () {
            sl<Coordinator>().navigateToAddEditSupplierPage();
          },
        ),
        _buildGridItem(
          icon: Icons.add_business,
          label: 'Supplier List',
          color: Colors.teal,
          onTap: () {
            sl<Coordinator>().navigateToSupplierListPage();
          },
        ),
        _buildGridItem(
          icon: Icons.lightbulb,
          label: 'Add Strategy',
          color: Colors.amber,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Add Strategy Coming Soon!"),
              ),
            );
          },
        ),
        _buildGridItem(
          icon: Icons.settings,
          label: 'Company Settings',
          color: Colors.indigo,
          onTap: () {
            sl<Coordinator>().navigateToCompanySettingsPage();
          },
        ),
        _buildGridItem(
          icon: Icons.manage_accounts,
          label: 'Product Management',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToProductManagementPage();
          },
        ),
        _buildGridItem(
          icon: Icons.manage_accounts,
          label: 'Cart Management',
          color: Colors.pink,
          onTap: () {
            sl<Coordinator>().navigateToCartDashboard();
          },
        ),
      ]);
    }
    gridItems.add(_buildGridItem(
      icon: Icons.account_balance,
      label: 'User ledger',
      color: Colors.deepPurple,
      onTap: () async {
        final user = await sl<AccountRepository>().getUserInfo();
        user?.copyWith(accountLedgerId: '1q3XGuMfV9LunYhnKDh8');
        sl<Coordinator>().navigateToUserLedgerPage(user: user?.copyWith(accountLedgerId: '1q3XGuMfV9LunYhnKDh8') ?? UserInfo());
      },
    ));
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
