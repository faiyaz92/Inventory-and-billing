import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeCubit>()..fetchUserInfo(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
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
                        // Header

                        // Welcome Card
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
                        // GridView
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                            children: [
                              _buildGridItem(
                                icon: Icons.admin_panel_settings,
                                label: 'Company Admin',
                                color: Colors.deepPurple,
                                onTap: () {
                                  sl<Coordinator>()
                                      .navigateToCompanyAdminPage();
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
                                  sl<Coordinator>()
                                      .navigateToAddEditSupplierPage();
                                },
                              ),
                              _buildGridItem(
                                icon: Icons.add_business,
                                label: 'Supplier List',
                                color: Colors.teal,
                                onTap: () {
                                  sl<Coordinator>()
                                      .navigateToSupplierListPage();
                                },
                              ),
                              _buildGridItem(
                                icon: Icons.lightbulb,
                                label: 'Add Strategy',
                                color: Colors.amber,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Add Strategy Coming Soon!"),
                                    ),
                                  );
                                },
                              ),
                              _buildGridItem(
                                icon: Icons.settings,
                                label: 'Company Settings',
                                color: Colors.indigo,
                                onTap: () {
                                  sl<Coordinator>()
                                      .navigateToCompanySettingsPage();
                                },
                              ),
                              _buildGridItem(
                                icon: Icons.admin_panel_settings,
                                label: 'Super Admin',
                                color: Colors.cyan,
                                onTap: () {
                                  sl<Coordinator>().navigateToSuperAdminPage();
                                },
                              ),
                              _buildGridItem(
                                icon: Icons.manage_accounts,
                                label: 'Product Management',
                                color: Colors.pink,
                                onTap: () {
                                  sl<Coordinator>()
                                      .navigateToProductManagementPage();
                                },
                              ),_buildGridItem(
                                icon: Icons.manage_accounts,
                                label: 'Cart Management',
                                color: Colors.pink,
                                onTap: () {
                                  sl<Coordinator>()
                                      .navigateToCartDashboard();
                                },
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
