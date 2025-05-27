import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class CompanyAdminPage extends StatelessWidget {
  const CompanyAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Company Admin Dashboard'),
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
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    children: [
                      _buildGridItem(
                        icon: Icons.person_add,
                        label: 'Add User',
                        color: Colors.blue,
                        onTap: () {
                          sl<Coordinator>().navigateToAddUserPage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.monetization_on_sharp,
                        label: 'User salary List',
                        color: Colors.orangeAccent,
                        onTap: () {
                          sl<Coordinator>().navigateToUserListPage();
                        },
                      ), _buildGridItem(
                        icon: Icons.list,
                        label: 'User List',
                        color: Colors.green,
                        onTap: () {
                          sl<Coordinator>().navigateToSimpleEmployeeList();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.task,
                        label: 'Add Task',
                        color: Colors.orange,
                        onTap: () {
                          sl<Coordinator>().navigateToAddTaskPage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.task,
                        label: 'Task List',
                        color: Colors.purple,
                        onTap: () {
                          sl<Coordinator>().navigateToTaskListPage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.add_chart,
                        label: 'Attendance',
                        color: Colors.lightGreen,
                        onTap: () {
                          sl<Coordinator>().navigateToAttendancePage();
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.security,
                        label: 'Manage Roles',
                        color: Colors.red,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Manage Roles Coming Soon!"),
                            ),
                          );
                        },
                      ),
                      _buildGridItem(
                        icon: Icons.bar_chart,
                        label: 'Reports',
                        color: Colors.teal,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Reports Coming Soon!"),
                            ),
                          );
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
