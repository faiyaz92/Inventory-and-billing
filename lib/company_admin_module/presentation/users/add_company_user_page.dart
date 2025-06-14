import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/store_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_user_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

@RoutePage()
class AddUserPage extends StatelessWidget {
  final UserInfo? user;

  const AddUserPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AddUserCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<StoreCubit>()..fetchStores(),
        ),
      ],
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
  final TextEditingController dailyWageController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController(); // Added mobile number controller
  Role? _selectedRole;
  String? _selectedStoreId;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      isEditing = true;
      nameController.text = widget.user?.name ?? '';
      emailController.text = widget.user?.email ?? '';
      userNameController.text = widget.user?.userName ?? '';
      dailyWageController.text = widget.user?.dailyWage?.toString() ?? '500.0';
      mobileNumberController.text = widget.user?.mobileNumber ?? ''; // Initialize mobile number
      _selectedRole = widget.user?.role;
      _selectedStoreId = widget.user?.storeId;
      print('initState (editing): _selectedStoreId = $_selectedStoreId, mobileNumber = ${mobileNumberController.text}');
    }
    print('AddUserView initState: _selectedStoreId = $_selectedStoreId, isEditing = $isEditing');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    dailyWageController.dispose();
    mobileNumberController.dispose(); // Dispose mobile number controller
    super.dispose();
  }

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    userNameController.clear();
    passwordController.clear();
    dailyWageController.clear();
    mobileNumberController.clear(); // Clear mobile number
    setState(() {
      _selectedRole = null;
      _selectedStoreId = null;
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
                if (!isEditing) {
                  sl<Coordinator>().navigateBack();
                }
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
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? "Edit User" : "Add User",
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: BlocListener<StoreCubit, StoreState>(
                  listener: (context, storeState) {
                    if (storeState is StoreLoaded && !isEditing && _selectedStoreId == null) {
                      final validStoreId = storeState.stores.any((store) => store.storeId == storeState.defaultStoreId)
                          ? storeState.defaultStoreId
                          : storeState.stores.isNotEmpty
                          ? storeState.stores.first.storeId
                          : null;
                      if (validStoreId != null) {
                        _selectedStoreId = validStoreId;
                        print('BlocListener: Set _selectedStoreId = $_selectedStoreId for adding');
                      }
                    }
                    print('StoreCubit state: $storeState');
                  },
                  child: BlocConsumer<AddUserCubit, AddUserState>(
                    listener: (context, state) {
                      if (state is AddUserSuccess) {
                        _showSuccessDialog(isEditing
                            ? "User updated successfully!"
                            : "User added successfully!");
                      } else if (state is AddUserFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: AppColors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return BlocBuilder<StoreCubit, StoreState>(
                        builder: (context, storeState) {
                          List<StoreDto> stores = [];
                          String? defaultStoreId;

                          if (storeState is StoreLoaded) {
                            stores = storeState.stores;
                            defaultStoreId = storeState.defaultStoreId;
                            print('BlocBuilder: _selectedStoreId = $_selectedStoreId, stores = ${stores.map((s) => s.storeId).toList()}, defaultStoreId = $defaultStoreId');
                          }

                          return Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: "Full Name",
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 16.0),
                                    validator: (value) =>
                                    value!.isEmpty ? "Name is required" : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: "Email",
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(fontSize: 16.0),
                                    validator: (value) =>
                                    value!.isEmpty ? "Email is required" : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: TextFormField(
                                    controller: userNameController,
                                    decoration: InputDecoration(
                                      labelText: "Username",
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 16.0),
                                    validator: (value) =>
                                    value!.isEmpty ? "Username is required" : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: TextFormField(
                                    controller: mobileNumberController,
                                    decoration: InputDecoration(
                                      labelText: "Mobile Number",
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(fontSize: 16.0),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Mobile number is required";
                                      }
                                      final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
                                      if (!phoneRegex.hasMatch(value)) {
                                        return "Enter a valid mobile number";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: TextFormField(
                                    controller: dailyWageController,
                                    decoration: InputDecoration(
                                      labelText: "Daily Wage",
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 16.0),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Daily wage is required";
                                      final wage = double.tryParse(value);
                                      if (wage == null || wage <= 0) return "Enter a valid wage";
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: DropdownButtonFormField<Role>(
                                    value: _selectedRole,
                                    decoration: InputDecoration(
                                      labelText: "Select Role",
                                      labelStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Colors.grey[400]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    items: Role.values.map((role) {
                                      return DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          role.name.toUpperCase(),
                                          style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole = value;
                                        print('Role Dropdown onChanged: _selectedRole = $_selectedRole');
                                      });
                                    },
                                    validator: (value) =>
                                    value == null ? "Role is required" : null,
                                    style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  ),
                                ),
                                if (storeState is StoreLoaded && stores.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: DropdownButtonFormField<String>(
                                      key: ValueKey(_selectedStoreId),
                                      value: _selectedStoreId,
                                      decoration: InputDecoration(
                                        labelText: "Select Store",
                                        labelStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 16.0,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey[400]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey[400]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                        ),
                                      ),
                                      items: stores.map((store) {
                                        return DropdownMenuItem(
                                          value: store.storeId,
                                          child: Text(
                                            store.name,
                                            style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        _selectedStoreId = value;
                                        print('Store Dropdown onChanged: _selectedStoreId = $_selectedStoreId');
                                      },
                                      validator: (value) =>
                                      value == null ? "Store is required" : null,
                                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                    ),
                                  ),
                                if (!isEditing)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: TextFormField(
                                      controller: passwordController,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        labelStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 16.0,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[100],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey[400]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey[400]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                        ),
                                      ),
                                      obscureText: true,
                                      style: const TextStyle(fontSize: 16.0),
                                      validator: (value) => value!.length < 6
                                          ? "Password must be at least 6 characters"
                                          : null,
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: state is AddUserLoading
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                        vertical: 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        final userInfo = UserInfo(
                                          userId: widget.user?.userId,
                                          email: emailController.text.trim(),
                                          role: _selectedRole,
                                          name: nameController.text.trim(),
                                          userName: userNameController.text.trim(),
                                          dailyWage: double.tryParse(dailyWageController.text.trim()),
                                          storeId: _selectedStoreId ?? defaultStoreId,
                                          mobileNumber: mobileNumberController.text.trim(), // Added mobile number
                                        );

                                        print('Submitting userInfo with storeId = ${userInfo.storeId}, mobileNumber = ${userInfo.mobileNumber}');

                                        if (isEditing) {
                                          context.read<AddUserCubit>().updateUser(userInfo);
                                        } else {
                                          context.read<AddUserCubit>().addUser(
                                            userInfo,
                                            passwordController.text.trim(),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(isEditing ? "Update User" : "Create User"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}