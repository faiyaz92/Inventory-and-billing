import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/dashboard/dashboard_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_page.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_list/company_list_page.dart';

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
                  _dashboardCubit.logout();
                },
                tooltip: "Logout",
              ),
            ],
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final pages = [
                const HomePage(),
                const CompanyListPage(),
              ];
              final index = state is DashboardTabState ? state.index : 0;
              return pages[index];
            },
          ),
          bottomNavigationBar: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final index = state is DashboardTabState ? state.index : 0;
              return BottomNavigationBar(
                // backgroundColor: Colors.white,
                // selectedItemColor: Colors.blue,
                // unselectedItemColor: Colors.grey,
                currentIndex: index,
                onTap: (index) => _dashboardCubit.updateIndex(index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: 'Companies',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}