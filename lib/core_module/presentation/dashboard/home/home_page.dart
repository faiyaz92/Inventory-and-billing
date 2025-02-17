import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      // sl<Coordinator>().navigateToAddCustomerPage();
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.lightbulb,
                    label: 'Add Strategy',
                    onTap: () {
                      // Implement navigation to Add Strategy Page
                      // sl<Coordinator>().navigateToAddStrategyPage();
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.settings,
                    label: 'Company Settings',
                    onTap: () {
                      // Implement navigation to App Settings Page
                      sl<Coordinator>().navigateToCompanySettingsPage();
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Super admin',
                    onTap: () {
                      // Implement navigation to App Settings Page
                      sl<Coordinator>().navigateToSuperAdminPage();
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Company admin',
                    onTap: () {
                      // Implement navigation to App Settings Page
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
