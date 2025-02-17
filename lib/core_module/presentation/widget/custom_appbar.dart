import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions; // Optional actions for the AppBar

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true, // Enables back button by default
    this.actions, // Accepts a list of actions
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: defaultTextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.appBarTitleColor, // Use centralized title color
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.appBarIconColor), // Use centralized icon color
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.appBarStartColor, // Gradient start
              AppColors.appBarMiddleColor, // Gradient middle
              AppColors.appBarEndColor, // Gradient end
            ],
            stops: [0.0, 0.8, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      actions: actions, // Add actions to the AppBar
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
