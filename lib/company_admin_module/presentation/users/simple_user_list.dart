import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/simple_user_cubit.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

@RoutePage()
class SimpleUsersPage extends StatelessWidget {
  final UserType? userType;

  const SimpleUsersPage({Key? key, this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SimpleUserCubit>()
        ..fetchUsers()
        ..filterUsers(userType: userType),
      child: BlocConsumer<SimpleUserCubit, EmployeesState>(
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
            appBar: CustomAppBar(
              title: userType != null ? '${userType!.name} Accounts' : 'User List',
            ),
            body: Column(
              children: [
                if (userType == null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by name or email',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            context.read<SimpleUserCubit>().filterUsers(
                              searchQuery: value,
                              userType: context.read<SimpleUserCubit>().selectedUserType,
                              role: context.read<SimpleUserCubit>().selectedRole,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<UserType>(
                                decoration: InputDecoration(
                                  labelText: 'User Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                value: context.read<SimpleUserCubit>().selectedUserType,
                                items: UserType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<SimpleUserCubit>().filterUsers(
                                      searchQuery: context.read<SimpleUserCubit>().searchQuery,
                                      userType: value,
                                      role: value == UserType.Employee
                                          ? context.read<SimpleUserCubit>().selectedRole
                                          : null,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (context.watch<SimpleUserCubit>().selectedUserType == UserType.Employee)
                              Expanded(
                                child: DropdownButtonFormField<Role>(
                                  decoration: InputDecoration(
                                    labelText: 'Role',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  value: context.read<SimpleUserCubit>().selectedRole,
                                  items: Role.values.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<SimpleUserCubit>().filterUsers(
                                        searchQuery: context.read<SimpleUserCubit>().searchQuery,
                                        userType: context.read<SimpleUserCubit>().selectedUserType,
                                        role: value,
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: state is UserListLoading || state is UserDeleting
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  userType != null ? 'No ${userType!.name.toLowerCase()} accounts found' : 'No users found',
                                  style: const TextStyle(
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      if (userType != null)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.account_balance_wallet,
                                            color: AppColors.textPrimary,
                                          ),
                                          tooltip: 'View Ledger',
                                          onPressed: () {
                                            sl<Coordinator>().navigateToUserLedgerPage(user: user).then((result) {
                                              if (result is bool && result == true) {
                                                context.read<SimpleUserCubit>().fetchUsers();
                                                context.read<SimpleUserCubit>().filterUsers(
                                                  searchQuery: context.read<SimpleUserCubit>().searchQuery,
                                                  userType: context.read<SimpleUserCubit>().selectedUserType,
                                                  role: context.read<SimpleUserCubit>().selectedRole,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: AppColors.textSecondary,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            sl<Coordinator>().navigateToAddUserPage(user: user);
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(context, user.userId ?? '');
                                          } else if (value == 'details') {
                                            sl<Coordinator>().navigateToEmployeeDetailsPage(
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
                ),
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
            'Are you sure you want to delete this user?',
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
                context.read<SimpleUserCubit>().deleteUser(userId);
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