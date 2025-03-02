import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_user_cubit.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';


class AddUserPage extends StatelessWidget {
  final UserInfo? user; // Nullable: Used for editing

  const AddUserPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AddUserCubit>(),
      child: _AddUserView(user: user),
    );
  }
}

class _AddUserView extends StatefulWidget {
  final UserInfo? user;

  const _AddUserView({required this.user});

  @override
  State<_AddUserView> createState() => _AddUserViewState();
}

class _AddUserViewState extends State<_AddUserView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Role? _selectedRole;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      isEditing = true;
      nameController.text = widget.user?.name ?? '';
      emailController.text = widget.user?.email ?? '';
      userNameController.text = widget.user?.userName ?? '';
      _selectedRole = widget.user?.role;
    }
  }

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    userNameController.clear();
    passwordController.clear();
    setState(() {
      _selectedRole = null;
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coordinator = GetIt.I<Coordinator>();

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit User" : "Add User")),
      body: BlocConsumer<AddUserCubit, AddUserState>(
        listener: (context, state) {
          if (state is AddUserSuccess) {
            _showSuccessDialog(isEditing ? "User updated successfully!" : "User added successfully!");
          } else if (state is AddUserFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final addUserCubit = context.read<AddUserCubit>();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (value) => value!.isEmpty ? "Name is required" : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty ? "Email is required" : null,
                    ),
                    TextFormField(
                      controller: userNameController,
                      decoration: const InputDecoration(labelText: "Username"),
                      validator: (value) => value!.isEmpty ? "Username is required" : null,
                    ),
                    DropdownButtonFormField<Role>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: "Select Role"),
                      items: Role.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      validator: (value) => value == null ? "Role is required" : null,
                    ),

                    if (!isEditing) // Show password field only for new user creation
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: "Password"),
                        obscureText: true,
                        validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                      ),

                    const SizedBox(height: 20),

                    state is AddUserLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final userInfo = UserInfo(
                            userId: widget.user?.userId, // Keep userId if editing
                            email: emailController.text.trim(),
                            role: _selectedRole,
                            name: nameController.text.trim(),
                            userName: userNameController.text.trim(),
                          );

                          if (isEditing) {
                            addUserCubit.addUser(userInfo, ""); // Password not needed for updates
                          } else {
                            addUserCubit.addUser(userInfo, passwordController.text.trim());
                          }
                        }
                      },
                      child: Text(isEditing ? "Update User" : "Create User"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
