import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/dashboard/home/home_cubit.dart';
import 'package:requirment_gathering_app/core_module/services/user_service.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return BlocProvider(
      create: (context) => sl<HomeCubit>()..fetchUserInfo(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          String userName = '';
          if (state is HomeLoaded) {
            userName = state.userName;
          }

          return AppBar(
            automaticallyImplyLeading: automaticallyImplyLeading,
            centerTitle: true, // Always center the title
            title: Text(
              title,
              style: defaultTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.appBarTitleColor,
              ),
            ),
            iconTheme: const IconThemeData(color: AppColors.appBarIconColor),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appBarStartColor,
                    AppColors.appBarMiddleColor,
                    AppColors.appBarEndColor,
                  ],
                  stops: [0.0, 0.8, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            actions: [
              if (userName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: Text(
                      isWeb ? 'Welcome, $userName' : userName.split(RegExp(r'[._]')).first, // First part in mobile, original in web
                      style: defaultTextStyle(
                        fontSize: isWeb ? 16 : 14, // Smaller on mobile, regular on web
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              if (actions != null) ...actions!,
              if (!isWeb) // Overflow menu with logout for mobile only
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.appBarIconColor),
                  onSelected: (value) {
                    if (value == 'logout') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context), // No action on confirm
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
            ],
            leading: automaticallyImplyLeading
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
                : null,
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}