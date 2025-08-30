import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_page.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

@RoutePage()
class AccountsDashboardPage extends StatelessWidget {
  const AccountsDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define demo expiration date
    final DateTime demoExpirationDate = DateTime(2025, 10, 10);
    final bool isDemoExpired = DateTime.now().isAfter(demoExpirationDate);
    final bool isWeb = MediaQuery.of(context).size.width > 600;

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
              appBar: const CustomAppBar(
                title: 'Accounts Dashboard',
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
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: Card(
                        //     elevation: 8,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(16),
                        //     ),
                        //     color: Colors.white,
                        //     child: Padding(
                        //       padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
                        //       child: Text(
                        //         'Welcome to Accounts Dashboard, ${state.userName}',
                        //         style: TextStyle(
                        //           fontSize: isWeb ? 28 : 24,
                        //           fontWeight: FontWeight.bold,
                        //           color: Theme.of(context).primaryColor,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: isWeb ? 32 : 24),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: isWeb ? 7 : 3,
                            crossAxisSpacing: isWeb ? 16 : 12,
                            mainAxisSpacing: isWeb ? 16 : 12,
                            childAspectRatio: isWeb ? 1.0 : 1.0,
                            children: [
                              _buildDashboardCard(
                                context,
                                'Check Accounts',
                                Icons.account_balance,
                                Colors.green,
                                    () {
                                  sl<Coordinator>().navigateToUserLedgerPage(
                                      transactionType: TransactionType.OtherLedger);
                                },
                                isWeb,
                              ),
                              _buildDashboardCard(
                                context,
                                'Sales man Accounts',
                                Icons.account_balance,
                                Colors.green,
                                    () {
                                  sl<Coordinator>().navigateToSimpleUserList(
                                      userType: UserType.Employee, role: Role.SALES_MAN);
                                },
                                isWeb,
                              ),
                              ..._buildGridItems(context, isWeb),
                              _buildDashboardCard(
                                context,
                                'Store Accounts',
                                Icons.store,
                                Colors.orangeAccent,
                                    () {
                                  sl<Coordinator>().navigateToStoresListPage(
                                      fromAccountPage: true);
                                },
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
                            ],
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
              appBar: const CustomAppBar(
                title: 'Accounts Dashboard',
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
      UserType.Store: Icons.store,
    };

    return UserType.values
        .asMap()
        .entries
        .where((entry) => entry.value != UserType.Store)
        .map((entry) {
      final index = entry.key;
      final userType = entry.value;
      final displayName =
      userType == UserType.Accounts ? 'Operations Account' : userType.name;
      return _buildDashboardCard(
        context,
        userType == UserType.Accounts ? displayName : '$displayName Accounts',
        iconMap[userType] ?? Icons.group,
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
                size: isWeb ? 28 : 36,
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