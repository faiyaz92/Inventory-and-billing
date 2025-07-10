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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = screenWidth > 600;

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
                        'Welcome to Company Admin Dashboard',
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
                    children: _buildGridItems(context, isWeb),
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
    return [
      _buildGridItem(
        context:context,
        icon: Icons.person_add,
        label: 'Add User',
        color: Colors.blue,
        onTap: () => sl<Coordinator>().navigateToAddUserPage(),
        isWeb: isWeb,
      ),
      _buildGridItem(
        context:context,
        icon: Icons.monetization_on_sharp,
        label: 'User Salary List',
        color: Colors.orangeAccent,
        onTap: () => sl<Coordinator>().navigateToUserListPage(),
        isWeb: isWeb,
      ),
      _buildGridItem(
        context:context,
        icon: Icons.list,
        label: 'User List',
        color: Colors.green,
        onTap: () => sl<Coordinator>().navigateToSimpleEmployeeList(),
        isWeb: isWeb,
      ),
      _buildGridItem(
        context:context,
        icon: Icons.task,
        label: 'Add Task',
        color: Colors.orange,
        onTap: () => sl<Coordinator>().navigateToAddTaskPage(),
        isWeb: isWeb,
      ),
      _buildGridItem(
        context:context,
        icon: Icons.task,
        label: 'Task List',
        color: Colors.purple,
        onTap: () => sl<Coordinator>().navigateToTaskListPage(),
        isWeb: isWeb,
      ),
      _buildGridItem(
        context:context,
        icon: Icons.add_chart,
        label: 'Attendance',
        color: Colors.lightGreen,
        onTap: () => sl<Coordinator>().navigateToAttendancePage(),
        isWeb: isWeb,
      ),


    ];
  }

  Widget _buildGridItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool isWeb,
  }) {
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
                label,
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