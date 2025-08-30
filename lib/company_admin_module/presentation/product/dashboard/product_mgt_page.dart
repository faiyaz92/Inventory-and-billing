import 'package:auto_route/annotations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
                //         'Welcome to Product Management',
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
                    children: _buildGridItems(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGridItems() {
    return [
      _buildGridItem(
        icon: Icons.add_business,
        label: 'Add Product',
        color: Colors.blue,
        onTap: () => sl<Coordinator>().navigateToAddEditProductPage(),
      ),
      _buildGridItem(
        icon: Icons.list,
        label: 'Product List',
        color: Colors.green,
        onTap: () => sl<Coordinator>().navigateToProductListPage(),
      ),
      _buildGridItem(
        icon: Icons.category,
        label: 'Add Category',
        color: Colors.orange,
        onTap: () => sl<Coordinator>().navigateToAddEditCategoryPage(),
      ),
      _buildGridItem(
        icon: Icons.category,
        label: 'Cat and Sub Cat List',
        color: Colors.purple,
        onTap: () => sl<Coordinator>().navigateToCategoriesWithSubcategoriesPage(),
      ),
    ];
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