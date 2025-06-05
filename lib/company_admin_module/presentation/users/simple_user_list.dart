import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/simple_employee_cubit.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';

@RoutePage()
class SimpleEmployeesPage extends StatelessWidget {
  const SimpleEmployeesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SimpleEmployeeCubit>()..fetchUsers(),
      child: BlocConsumer<SimpleEmployeeCubit, EmployeesState>(
        listenWhen: (previous, current) => current is UserListError,
        listener: (context, state) {
          if (state is UserListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
        current is UserListLoading ||
            current is UserListLoaded ||
            current is UserListError ||
            current is UserDeleting ||
            previous is UserListLoading ||
            previous is UserListLoaded ||
            previous is UserDeleting,
        builder: (context, state) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: "Employee List",
            ),
            body: state is UserListLoading || state is UserDeleting
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
              slivers: [
                if (state is UserListLoaded && state.users.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No employees found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (state is UserListLoaded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final user = state.users[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name ?? "No Name",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        user.email ?? "No Email",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: AppColors.textSecondary,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      sl<Coordinator>()
                                          .navigateToAddUserPage(
                                          user: user);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmation(
                                          context, user.userId ?? '');
                                    } else if (value == 'details') {
                                      sl<Coordinator>()
                                          .navigateToEmployeeDetailsPage(
                                        userId: user.userId,
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'details',
                                      child: Text(
                                        'Details',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: state.users.length,
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this employee?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<SimpleEmployeeCubit>().deleteUser(userId);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}