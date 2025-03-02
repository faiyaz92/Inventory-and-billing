import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeCubit>()..fetchUserInfo(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          } else if (state is HomeLoaded) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${state.userName}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildGridItem(
                            icon: Icons.business,
                            label: 'Add Company',
                            onTap: () {
                              sl<Coordinator>().navigateToAddCompanyPage();
                            },
                          ),
                          _buildGridItem(
                            icon: Icons.person_add,
                            label: 'Add Customer',
                            onTap: () {
                              // Implement navigation to Add Customer Page
                            },
                          ),
                          _buildGridItem(
                            icon: Icons.lightbulb,
                            label: 'Add Strategy',
                            onTap: () {
                              // Implement navigation to Add Strategy Page
                            },
                          ),
                          _buildGridItem(
                            icon: Icons.settings,
                            label: 'Company Settings',
                            onTap: () {
                              sl<Coordinator>().navigateToCompanySettingsPage();
                            },
                          ),
                          _buildGridItem(
                            icon: Icons.admin_panel_settings,
                            label: 'Super admin',
                            onTap: () {
                              sl<Coordinator>().navigateToSuperAdminPage();
                            },
                          ),
                          _buildGridItem(
                            icon: Icons.admin_panel_settings,
                            label: 'Company admin',
                            onTap: () {
                              sl<Coordinator>().navigateToCompanyAdminPage();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is HomeError) {
            return Scaffold(
                body: Center(child: Text("Error: ${state.message}")));
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
