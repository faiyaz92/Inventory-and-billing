import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/user_list_cubit.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserListCubit>()..fetchUsers(),
      child: Scaffold(
        appBar: AppBar(title: const Text("User Management")),
        body: BlocBuilder<UserListCubit, UserListState>(
          builder: (context, state) {
            if (state is UserListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserListLoaded) {
              return _buildUserList(context, state.users);
            } else if (state is UserListError) {
              return Center(child: Text("Error: ${state.error}"));
            }
            return const Center(child: Text("No Users Available"));
          },
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<UserInfo> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        UserInfo user = users[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(user.name ?? "No Name"),
            subtitle: Text(user.email ?? "No Email"),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  GetIt.I<Coordinator>().navigateToAddUserPage(user: user);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, user.userId ?? '');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<UserListCubit>().deleteUser(userId);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
