import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_page.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define demo expiration date
    final DateTime demoExpirationDate = DateTime(2030, 10, 10);
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
                    padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: Card(
                        //     elevation: 8,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(16),
                        //     ),
                        //     color: Colors.white,
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                        //       child: Text(
                        //         "Welcome, ${state.userName}",
                        //         style: TextStyle(
                        //           fontSize: kIsWeb ? 28 : 24,
                        //           fontWeight: FontWeight.bold,
                        //           color: Theme.of(context).primaryColor,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: kIsWeb ? 32 : 24),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: kIsWeb ? 7 : 3,
                            crossAxisSpacing: kIsWeb ? 16 : 12,
                            mainAxisSpacing: kIsWeb ? 16 : 12,
                            childAspectRatio: kIsWeb ? 1.0 : 1.0,
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

  List<Widget> _buildGridItemsForRole({
    required BuildContext context,
    required Role role,
  }) {
    final List<Widget> gridItems = [];

    // Role-based access
    switch (role) {
      case Role.SUPER_ADMIN:
        gridItems.addAll([
          _buildGridItem(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Super Admin',
            color: Colors.cyan,
            onTap: () {
              sl<Coordinator>().navigateToSuperAdminPage();
            },
          ),
          _buildGridItem(
            icon: Icons.add_business_outlined,
            label: 'Add Company',
            color: Colors.orange,
            onTap: () {
              sl<Coordinator>().navigateToAddCompanyPage();
            },
          ),
        ]);
        break;
      case Role.COMPANY_ADMIN:
      case Role.COMPANY_ACCOUNTANT:
        gridItems.addAll([
          _buildGridItem(
            icon: Icons.bar_chart,
            label: 'Statistics',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToDashboardStaticsPage();
            },
          ),
          _buildGridItem(
            icon: Icons.inventory_2_outlined,
            label: 'Product Management',
            color: Colors.lightGreenAccent,
            onTap: () {
              sl<Coordinator>().navigateToProductManagementPage();
            },
          ),
          _buildGridItem(
            icon: Icons.point_of_sale,
            label: 'Sales',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToCartDashboard();
            },
          ),
          _buildGridItem(
            icon: Icons.receipt_long,
            label: 'Purchase Invoice',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToPurchaseInvoicePanelPage();
            },
          ),
          _buildGridItem(
            icon: Icons.warehouse_outlined,
            label: 'Inventory',
            color: Colors.teal,
            onTap: () {
              sl<Coordinator>().navigateToInventoryDashBoard();
            },
          ),
          _buildGridItem(
            icon: Icons.account_balance_wallet,
            label: 'Accounts',
            color: Colors.green,
            onTap: () {
              sl<Coordinator>().navigateToAccountsDashboard();
            },
          ),
          _buildGridItem(
            icon: Icons.money_off,
            label: 'Add Expenses',
            color: Colors.orangeAccent,
            onTap: () {
              sl<Coordinator>().navigateToUserLedgerPage(
                  transactionType: TransactionType.Expense);
            },
          ),
          _buildGridItem(
            icon: Icons.payments,
            label: 'Add Reimbursement',
            color: Colors.orangeAccent,
            onTap: () {
              sl<Coordinator>().navigateToUserLedgerPage(
                  transactionType: TransactionType.Reimbursement);
            },
          ),
          _buildGridItem(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            color: Colors.blue,
            onTap: () {
              sl<Coordinator>().navigateToAnalyticsPage();
            },
          ),
          _buildGridItem(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Company Admin',
            color: Colors.deepPurple,
            onTap: () {
              sl<Coordinator>().navigateToCompanyAdminPage();
            },
          ),
          _buildGridItem(
            icon: Icons.add_task,
            label: 'Add Task',
            color: Colors.blue,
            onTap: () {
              sl<Coordinator>().navigateToAddTaskPage();
            },
          ),
          _buildGridItem(
            icon: Icons.task_alt,
            label: 'Task List',
            color: Colors.green,
            onTap: () {
              sl<Coordinator>().navigateToTaskListPage();
            },
          ),
          _buildGridItem(
            icon: Icons.settings_outlined,
            label: 'Company Settings',
            color: Colors.indigo,
            onTap: () {
              sl<Coordinator>().navigateToCompanySettingsPage();
            },
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
          ),
          _buildGridItem(
            icon: Icons.store_mall_directory_outlined,
            label: 'Store List',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToStoresListPage();
            },
          ),
          _buildGridItem(
            icon: Icons.inventory_outlined,
            label: 'Stock List',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToStockListPage();
            },
          ),
          _buildGridItem(
            icon: Icons.storage_outlined,
            label: 'Overall Stock',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToOverAllStockPage();
            },
          ),
          _buildGridItem(
            icon: Icons.event_note,
            label: 'Store Attendance',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToAttendancePage();
            },
          ),
          _buildGridItem(
            icon: Icons.add_task,
            label: 'Add Task',
            color: Colors.blueAccent,
            onTap: () {
              sl<Coordinator>().navigateToAddTaskPage();
            },
          ),
          _buildGridItem(
            icon: Icons.task_alt,
            label: 'Task List',
            color: Colors.green,
            onTap: () {
              sl<Coordinator>().navigateToTaskListPage();
            },
          ),
          _buildGridItem(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Add Customer',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToAddUserPage();
            },
          ),
          _buildGridItem(
            icon: Icons.receipt_long_outlined,
            label: 'Billing Customer',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToBillingPage();
            },
          ),
          _buildGridItem(
            icon: Icons.add_shopping_cart,
            label: 'Cart Management',
            color: Colors.pink,
            onTap: () {
              sl<Coordinator>().navigateToCartDashboard();
            },
          ),
        ]);
        break;
      case Role.SALES_MAN:
        gridItems.addAll([
          // _buildGridItem(
          //   icon: Icons.note_add,
          //   label: 'Take Purchase Order',
          //   color: Colors.blueAccent,
          //   onTap: () {
          //     sl<Coordinator>().navigateToSalesManOrderPage();
          //   },
          // ),
          _buildGridItem(
            icon: Icons.receipt,
            label: 'Create Invoice',
            color: Colors.orange,
            onTap: () {
              sl<Coordinator>().navigateToBillingPage();
            },
          ),
          _buildGridItem(
            icon: Icons.list,
            label: 'Orders List',
            color: Colors.orange,
            onTap: () {
              sl<Coordinator>().navigateToAdminPanelPage();
            },
          ),
          _buildGridItem(
            icon: Icons.receipt_long,
            label: 'Invoices',
            color: Colors.cyan,
            onTap: () {
              sl<Coordinator>().navigateToInvoiceListPage();
            },
          ),
          _buildGridItem(
            icon: Icons.inventory,
            label: 'My Stock',
            color: Colors.cyan,
            onTap: () {
              sl<Coordinator>().navigateToStoreDetailsPage('');
            },
          ),
          _buildGridItem(
            icon: Icons.person_add,
            label: 'Add Customer',
            color: Colors.red,
            onTap: () => sl<Coordinator>().navigateToAddUserPage(),
          ),
          _buildGridItem(
            icon: Icons.money_off,
            label: 'Add Expenses',
            color: Colors.orangeAccent,
            onTap: () {
              sl<Coordinator>().navigateToUserLedgerPage(
                  transactionType: TransactionType.Expense);
            },
          ),
        ]);
        break;
      case Role.DELIVERY_MAN:
      case Role.STORE_ACCOUNTANT:
      case Role.STORE_MANAGER:
      case Role.USER:
        // Common items for all roles
        break;
    }

    // Add common grid items for all roles
    gridItems.addAll([
      _buildGridItem(
        icon: Icons.attach_money,
        label: 'Quick Receive',
        color: Colors.green,
        onTap: () {
          sl<Coordinator>().navigateToQuickTransactionPage('receive');
        },
      ),
      _buildGridItem(
        icon: Icons.payment,
        label: 'Quick Pay',
        color: Colors.red,
        onTap: () {
          sl<Coordinator>().navigateToQuickTransactionPage('pay');
        },
      ),
      _buildGridItem(
        icon: Icons.account_circle,
        label: 'My Account',
        color: Colors.orangeAccent,
        onTap: () {
          sl<Coordinator>().navigateToUserLedgerPage();
        },
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
                label,
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
