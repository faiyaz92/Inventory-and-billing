import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_page.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

@RoutePage()
class AccountsDashboardPage extends StatelessWidget {
  const AccountsDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Accounts Dashboard',
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
                        'Accounts Dashboard',
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
                    children: [
                      _buildDashboardCard(
                        context,
                        'Check Accounts', // Adjusted to singular for consistency
                        Icons.account_balance, // Changed to a more relevant icon
                        Colors.green,
                            () {
                              sl<Coordinator>().navigateToUserLedgerPage(transactionType: TransactionType.OtherLedger);
                        },
                        isWeb,
                      ),_buildDashboardCard(
                        context,
                        'Sales man Accounts', // Adjusted to singular for consistency
                        Icons.account_balance, // Changed to a more relevant icon
                        Colors.green,
                            () {
                          sl<Coordinator>().navigateToSimpleUserList(userType: UserType.Employee,role: Role.SALES_MAN);
                        },
                        isWeb,
                      ),
                      ..._buildGridItems(context, isWeb),
                      _buildDashboardCard(
                        context,
                        'Store Accounts', // Adjusted to singular for consistency
                        Icons.store, // Changed to a more relevant icon
                        Colors.orangeAccent,
                            () {
                          sl<Coordinator>().navigateToStoresListPage(fromAccountPage: true);
                        },
                        isWeb,
                      ),
                      _buildDashboardCard(
                        context,
                        'Invoices',
                        Icons.receipt_long, // More specific than Icons.receipt
                        Colors.cyan,
                            () => sl<Coordinator>().navigateToInvoiceListPage(),
                        isWeb,
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

  List<Widget> _buildGridItems(BuildContext context, bool isWeb) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.green,
    ];

    // Define icons for each UserType
    final iconMap = {
      UserType.Employee: Icons.person,
      UserType.Supplier: Icons.local_shipping,
      UserType.Customer: Icons.people,
      UserType.Boss: Icons.supervisor_account,
      UserType.ThirdPartyVendor: Icons.business,
      UserType.Contractor: Icons.work,
      UserType.Accounts: Icons.account_balance_wallet,
      UserType.Store: Icons.store, // Not used due to exclusion, included for completeness
    };

    return UserType.values
        .asMap()
        .entries
        .where((entry) => entry.value != UserType.Store) // Exclude Store
        .map((entry) {
      final index = entry.key;
      final userType = entry.value;
      // Use "Operations Account" for UserType.Accounts, else use userType.name with "Accounts"
      final displayName =
      userType == UserType.Accounts ? 'Operations Account' : userType.name;
      return _buildDashboardCard(
        context,
        userType == UserType.Accounts ? displayName : '$displayName Accounts',
        iconMap[userType] ?? Icons.group, // Fallback to Icons.group if not found
        colors[index % colors.length],
            () => sl<Coordinator>().navigateToSimpleUserList(userType: userType),
        isWeb,
      );
    }).toList();
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