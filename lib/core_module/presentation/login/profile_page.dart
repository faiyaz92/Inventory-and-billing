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
    final double scaleFactor = MediaQuery.of(context).size.width > 600 ? 1.2 : 1.0;
    final double basePadding = 16.0 * scaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2526), // Match TaxiBookingPage background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2F32), // Darker shade to align with TaxiBookingPage
              Color(0xFF1C2526), // Primary background color
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(basePadding),
            child: BlocProvider(
              create: (context) => _profileCubit,
              child: BlocListener<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16 * scaleFactor,
                            color: const Color(0xFFE4E4E7),
                          ),
                        ),
                        backgroundColor: const Color(0xFF2A2F32),
                      ),
                    );
                  }
                  if (state.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.error!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16 * scaleFactor,
                            color: const Color(0xFFE4E4E7),
                          ),
                        ),
                        backgroundColor: const Color(0xFF2A2F32),
                      ),
                    );
                  }
                  if (state.logoutRequested) {
                    context.read<DashboardCubit>().logout();
                  }
                },
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFACC15)), // Match accent
                          strokeWidth: 5 * scaleFactor,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(context, state.userInfo, scaleFactor, basePadding),
                        SizedBox(height: basePadding),
                        Expanded(
                          child: _buildOptionsList(context, state.userInfo, scaleFactor, basePadding),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserInfo? userInfo, double scaleFactor, double basePadding) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F32), // Match TaxiBookingPage card background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      padding: EdgeInsets.all(basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30 * scaleFactor,
                backgroundColor: const Color(0xFFFACC15).withOpacity(0.2), // Match accent
                child: Text(
                  userInfo?.name?.isNotEmpty == true
                      ? userInfo!.name![0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFACC15), // Match accent
                  ),
                ),
              ),
              SizedBox(width: basePadding),
              Expanded(
                child: Text(
                  userInfo?.name ?? 'User Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: basePadding * 0.75),
          _buildProfileRow(
            icon: Icons.email,
            label: 'Email',
            value: userInfo?.email ?? 'N/A',
            scaleFactor: scaleFactor,
          ),
          SizedBox(height: basePadding * 0.5),
          _buildProfileRow(
            icon: Icons.work,
            label: 'Role',
            value: userInfo?.role?.name ?? 'N/A',
            scaleFactor: scaleFactor,
          ),
          if (userInfo?.userType != null) ...[
            SizedBox(height: basePadding * 0.5),
            _buildProfileRow(
              icon: Icons.category,
              label: 'User Type',
              value: userInfo?.userType?.name ?? 'N/A',
              scaleFactor: scaleFactor,
            ),
          ],
          if (userInfo?.dailyWage != null) ...[
            SizedBox(height: basePadding * 0.5),
            _buildProfileRow(
              icon: Icons.attach_money,
              label: 'Daily Wage',
              value: '\$${userInfo?.dailyWage?.toStringAsFixed(2)}',
              scaleFactor: scaleFactor,
            ),
          ],
          if (userInfo?.storeId != null) ...[
            SizedBox(height: basePadding * 0.5),
            _buildProfileRow(
              icon: Icons.store,
              label: 'Store ID',
              value: userInfo?.storeId ?? 'N/A',
              scaleFactor: scaleFactor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
    required double scaleFactor,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB0B0B0), size: 20 * scaleFactor), // Match TaxiBookingPage label
        SizedBox(width: 8 * scaleFactor),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB0B0B0), // Match TaxiBookingPage label
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16 * scaleFactor,
              color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsList(BuildContext context, UserInfo? userInfo, double scaleFactor, double basePadding) {
    return ListView(
      children: [
        _buildListTile(
          context: context,
          icon: Icons.receipt,
          title: 'My Orders',
          onTap: () => context.read<DashboardCubit>().updateIndex(1),
          scaleFactor: scaleFactor,
        ),
        SizedBox(height: basePadding * 0.75),
        _buildListTile(
          context: context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Settings page not implemented',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16 * scaleFactor,
                    color: const Color(0xFFE4E4E7),
                  ),
                ),
                backgroundColor: const Color(0xFF2A2F32),
              ),
            );
          },
          scaleFactor: scaleFactor,
        ),
        SizedBox(height: basePadding * 0.75),
        _buildListTile(
          context: context,
          icon: Icons.lock_reset,
          title: 'Reset Password',
          onTap: () {
            if (userInfo?.email != null) {
              sl<Coordinator>().navigateToForgotPasswordPage();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Email not available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16 * scaleFactor,
                      color: const Color(0xFFE4E4E7),
                    ),
                  ),
                  backgroundColor: const Color(0xFF2A2F32),
                ),
              );
            }
          },
          scaleFactor: scaleFactor,
        ),
        SizedBox(height: basePadding * 0.75),
        _buildListTile(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: () => _showLogoutConfirmationDialog(context, scaleFactor, basePadding),
          scaleFactor: scaleFactor,
        ),
      ],
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double scaleFactor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F32), // Match TaxiBookingPage card background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFACC15), // Match TaxiBookingPage accent
          size: 24 * scaleFactor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color: const Color(0xFFFACC15), // Match TaxiBookingPage accent
          size: 24 * scaleFactor,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, double scaleFactor, double basePadding) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF18181B), // Match TaxiBookingPage dialog background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Container(
          padding: EdgeInsets.all(basePadding),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF27272A)), // Match TaxiBookingPage dialog border
            borderRadius: BorderRadius.circular(24.0),
          ),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24 * scaleFactor,
                  color: const Color(0xFFFACC15), // Match TaxiBookingPage accent
                ),
              ),
              SizedBox(height: 16 * scaleFactor),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16 * scaleFactor,
                  color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                ),
              ),
              SizedBox(height: 24 * scaleFactor),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16 * scaleFactor,
                        color: const Color(0xFFE4E4E7), // Match TaxiBookingPage text
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF27272A), // Match TaxiBookingPage dialog cancel button
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * scaleFactor,
                        vertical: 8 * scaleFactor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * scaleFactor),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _profileCubit.initiateLogout();
                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16 * scaleFactor,
                        color: Colors.black,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFACC15), // Match TaxiBookingPage button
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * scaleFactor,
                        vertical: 8 * scaleFactor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}