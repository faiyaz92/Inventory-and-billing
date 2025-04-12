import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class CompanyAdminPage extends StatelessWidget {
  const CompanyAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Company Admin Dashboard'),
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
                    icon: Icons.person_add,
                    label: 'Add User',
                    onTap: () {
                      sl<Coordinator>().navigateToAddUserPage(); // ✅ Add New User
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.list,
                    label: 'User List',
                    onTap: () {
                      sl<Coordinator>().navigateToUserListPage(); // ✅ Add New User
                    },
                  ),_buildGridItem(
                    icon: Icons.task,
                    label: 'Add Task',
                    onTap: () {
                      sl<Coordinator>().navigateToAddTaskPage(); // ✅ Add New User
                    },
                  ),_buildGridItem(
                    icon: Icons.task,
                    label: 'Task List',
                    onTap: () {
                      sl<Coordinator>().navigateToTaskListPage(); // ✅ Add New User
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
