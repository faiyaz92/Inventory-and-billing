import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/dashboard/dashboard_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/profile_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardCubit _dashboardCubit;

  @override
  void initState() {
    _dashboardCubit = sl<DashboardCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _dashboardCubit,
      child: BlocListener<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLogout) {
            sl<Coordinator>().navigateToLoginPage();
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: "Dashboard",
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
                tooltip: "Logout",
              ),
            ],
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final pages = [
                const HomePage(),
                const ProfilePage(),
              ];
              final index = state is DashboardTabState ? state.index : 0;
              return pages[index];
            },
          ),
          bottomNavigationBar: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final index = state is DashboardTabState ? state.index : 0;
              return BottomNavigationBar(
                currentIndex: index,
                onTap: (index) => _dashboardCubit.updateIndex(index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _dashboardCubit.logout();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}