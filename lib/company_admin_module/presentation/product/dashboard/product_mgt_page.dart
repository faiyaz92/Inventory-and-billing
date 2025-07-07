import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class ProductMgtPage extends StatelessWidget {
  const ProductMgtPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Manage Product",
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                // SizedBox(
                //   width: double.infinity,
                //   child: Card(
                //     elevation: 4,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     color: Colors.white,
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Text(
                //         "Welcome to Product Management",
                //         style: TextStyle(
                //           fontSize: 24,
                //           fontWeight: FontWeight.bold,
                //           color: Theme.of(context).primaryColor,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),
                // GridView
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildGridItem(
                        icon: Icons.add_business,
                        label: 'Add product',
                        color: Colors.blue,
                        onTap: () {
                          sl<Coordinator>().navigateToAddEditProductPage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.list,
                        label: 'Product list',
                        color: Colors.green,
                        onTap: () {
                          sl<Coordinator>().navigateToProductListPage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.category,
                        label: 'Add category',
                        color: Colors.orange,
                        onTap: () {
                          sl<Coordinator>().navigateToAddEditCategoryPage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.category,
                        label: 'Cat and sub cat list',
                        color: Colors.purple,
                        onTap: () {
                          sl<Coordinator>().navigateToCategoriesWithSubcategoriesPage();
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