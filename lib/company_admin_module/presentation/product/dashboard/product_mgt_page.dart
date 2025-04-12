import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class ProductMgtPage extends StatelessWidget {
  const ProductMgtPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Manage Product",
      ),
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
                    icon: Icons.add_business,
                    label: 'Add product',
                    onTap: () {
                      // Implement navigation to App Settings Page
                      sl<Coordinator>().navigateToAddEditProductPage();
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.list,
                    label: 'Product list',
                    onTap: () {
                      // Implement navigation to App Settings Page
                      sl<Coordinator>().navigateToProductListPage();
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.category,
                    label: 'Add category',
                    onTap: () {
                      // Implement navigation to App Settings Page
                      sl<Coordinator>().navigateToAddEditCategoryPage();
                    },
                  ),

                  _buildGridItem(
                    icon: Icons.category,
                    label: 'Cat and sub cat list',
                    onTap: () {
                      // Implement navigation to App Settings Page
                      sl<Coordinator>()
                          .navigateToCategoriesWithSubcategoriesPage();
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
