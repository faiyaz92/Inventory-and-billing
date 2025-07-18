import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed; // New optional callback for back press

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.onBackPressed, // Add to constructor
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
      actions: actions,
      leading: automaticallyImplyLeading
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}