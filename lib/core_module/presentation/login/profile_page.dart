import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/dashboard/dashboard_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/login/profile_cubit.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit(accountRepository: sl<AccountRepository>())
      ..loadUserInfo();
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _profileCubit,
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          if (state.logoutRequested) {
            context.read<DashboardCubit>().logout();
          }
        },
        child: Container(
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
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(context, state.userInfo),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildOptionsList(context, state.userInfo),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserInfo? userInfo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    userInfo?.name?.isNotEmpty == true
                        ? userInfo!.name![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userInfo?.name ?? 'User Profile',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProfileRow(
              icon: Icons.email,
              label: 'Email',
              value: userInfo?.email ?? 'N/A',
            ),
            const SizedBox(height: 8),
            _buildProfileRow(
              icon: Icons.work,
              label: 'Role',
              value: userInfo?.role?.name ?? 'N/A',
            ),
            if (userInfo?.userType != null) ...[
              const SizedBox(height: 8),
              _buildProfileRow(
                icon: Icons.category,
                label: 'User Type',
                value: userInfo?.userType?.name ?? 'N/A',
              ),
            ],
            if (userInfo?.dailyWage != null) ...[
              const SizedBox(height: 8),
              _buildProfileRow(
                icon: Icons.attach_money,
                label: 'Daily Wage',
                value: '\$${userInfo?.dailyWage?.toStringAsFixed(2)}',
              ),
            ],
            if (userInfo?.storeId != null) ...[
              const SizedBox(height: 8),
              _buildProfileRow(
                icon: Icons.store,
                label: 'Store ID',
                value: userInfo?.storeId ?? 'N/A',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsList(BuildContext context, UserInfo? userInfo) {
    return ListView(
      children: [
        _buildListTile(
          context: context,
          icon: Icons.receipt,
          title: 'My Orders',
          onTap: () => context.read<DashboardCubit>().updateIndex(1),
        ),
        const SizedBox(height: 12),
        _buildListTile(
          context: context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings page not implemented')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildListTile(
          context: context,
          icon: Icons.lock_reset,
          title: 'Reset Password',
          onTap: () {
            if (userInfo?.email != null) {
              sl<Coordinator>().navigateToForgotPasswordPage();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email not available')),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _buildListTile(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () => _showLogoutConfirmationDialog(context),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).primaryColor,
        ),
        onTap: onTap,
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
              _profileCubit.initiateLogout();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
