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
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

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
  final TextEditingController mobileNumberController = TextEditingController(); // New
  final TextEditingController businessNameController = TextEditingController(); // New
  final TextEditingController addressController = TextEditingController(); // New
  Role? _selectedRole;
  String? _selectedStoreId;
  UserType? _selectedUserType;
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
      mobileNumberController.text = widget.user?.mobileNumber ?? ''; // New
      businessNameController.text = widget.user?.businessName ?? ''; // New
      addressController.text = widget.user?.address ?? ''; // New
      _selectedRole = widget.user?.role;
      _selectedStoreId = widget.user?.storeId;
      _selectedUserType = widget.user?.userType ?? UserType.Employee;
      print('initState (editing): _selectedStoreId = $_selectedStoreId, _selectedUserType = $_selectedUserType');
    }
    print('AddUserView initState: _selectedStoreId = $_selectedStoreId, _selectedUserType = $_selectedUserType, isEditing = $isEditing');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    dailyWageController.dispose();
    mobileNumberController.dispose(); // New
    businessNameController.dispose(); // New
    addressController.dispose(); // New
    super.dispose();
  }

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    userNameController.clear();
    passwordController.clear();
    dailyWageController.clear();
    mobileNumberController.clear(); // New
    businessNameController.clear(); // New
    addressController.clear(); // New
    setState(() {
      _selectedRole = null;
      _selectedStoreId = null;
      _selectedUserType = null;
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
                    if (storeState is StoreLoaded && !isEditing && _selectedStoreId == null && _selectedUserType == UserType.Employee) {
                      final validStoreId = storeState.stores.any((store) => store.storeId == storeState.defaultStoreId)
                          ? storeState.defaultStoreId
                          : storeState.stores.isNotEmpty
                          ? storeState.stores.first.storeId
                          : null;
                      if (validStoreId != null) {
                        setState(() {
                          _selectedStoreId = validStoreId;
                        });
                        print('BlocListener: Set _selectedStoreId = $_selectedStoreId for adding employee');
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
                                // Full Name Field (Common for both)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: TextFormField(
                                    controller: nameController,
                                    textCapitalization: TextCapitalization.words,
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
                                // Email Field (Common for both)
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email is required";
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                        return "Enter a valid email";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                // UserType Dropdown (Common for both)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: DropdownButtonFormField<UserType>(
                                    value: _selectedUserType,
                                    decoration: InputDecoration(
                                      labelText: "Select User Type",
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
                                    items: UserType.values.map((userType) {
                                      return DropdownMenuItem(
                                        value: userType,
                                        child: Text(
                                          userType.name,
                                          style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedUserType = value;
                                        // Reset fields not relevant to the new user type
                                        if (value == UserType.Customer) {
                                          userNameController.clear();
                                          dailyWageController.clear();
                                          passwordController.clear();
                                          _selectedRole = null;
                                          _selectedStoreId = null;
                                        } else {
                                          mobileNumberController.clear();
                                          businessNameController.clear();
                                          addressController.clear();
                                        }
                                        print('UserType Dropdown onChanged: _selectedUserType = $_selectedUserType');
                                      });
                                    },
                                    validator: (value) =>
                                    value == null ? "User Type is required" : null,
                                    style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  ),
                                ),
                                // Fields for Customer
                                if (_selectedUserType == UserType.Customer) ...[
                                  // Mobile Number Field
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
                                          return "Mobile number is required for Customer";
                                        }
                                        if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                                          return "Enter a valid mobile number";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  // Business Name Field
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: TextFormField(
                                      controller: businessNameController,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: InputDecoration(
                                        labelText: "Business Name",
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
                                      value!.isEmpty ? "Business name is required for Customer" : null,
                                    ),
                                  ),
                                  // Address Field
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: TextFormField(
                                      controller: addressController,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        labelText: "Address",
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
                                      value!.isEmpty ? "Address is required for Customer" : null,
                                    ),
                                  ),
                                ],
                                // Fields for Employee
                                if (_selectedUserType == UserType.Employee) ...[
                                  // Username Field
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Username is required for Employee";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  // Daily Wage Field
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
                                        if (value == null || value.isEmpty) {
                                          return "Daily wage is required for Employee";
                                        }
                                        final wage = double.tryParse(value);
                                        if (wage == null || wage <= 0) {
                                          return "Enter a valid wage";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  // Role Dropdown
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
                                      validator: (value) {
                                        if (value == null) {
                                          return "Role is required for Employee";
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                    ),
                                  ),
                                  // Store Dropdown
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
                                          setState(() {
                                            _selectedStoreId = value;
                                            print('Store Dropdown onChanged: _selectedStoreId = $_selectedStoreId');
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return "Store is required for Employee";
                                          }
                                          return null;
                                        },
                                        style: const TextStyle(fontSize: 16.0, color: Colors.black),
                                      ),
                                    ),
                                  // Password Field
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
                                        validator: (value) {
                                          if (value == null || value.length < 6) {
                                            return "Password must be at least 6 characters for Employee";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                ],
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
                                          companyId: widget.user?.companyId,
                                          name: nameController.text.trim(),
                                          email: emailController.text.trim(),
                                          userName: _selectedUserType == UserType.Employee
                                              ? userNameController.text.trim().isEmpty
                                              ? null
                                              : userNameController.text.trim()
                                              : null,
                                          role: _selectedUserType == UserType.Employee ? _selectedRole : null,
                                          userType: _selectedUserType ?? UserType.Employee,
                                          dailyWage: _selectedUserType == UserType.Employee
                                              ? dailyWageController.text.trim().isEmpty
                                              ? null
                                              : double.tryParse(dailyWageController.text.trim())
                                              : null,
                                          storeId: _selectedUserType == UserType.Employee ? (_selectedStoreId ?? defaultStoreId) : null,
                                          accountLedgerId: widget.user?.accountLedgerId,
                                          mobileNumber: _selectedUserType == UserType.Customer
                                              ? mobileNumberController.text.trim().isEmpty
                                              ? null
                                              : mobileNumberController.text.trim()
                                              : null,
                                          businessName: _selectedUserType == UserType.Customer
                                              ? businessNameController.text.trim().isEmpty
                                              ? null
                                              : businessNameController.text.trim()
                                              : null,
                                          address: _selectedUserType == UserType.Customer
                                              ? addressController.text.trim().isEmpty
                                              ? null
                                              : addressController.text.trim()
                                              : null,
                                        );

                                        print('Submitting userInfo with userType = ${userInfo.userType}, '
                                            'storeId = ${userInfo.storeId}, mobileNumber = ${userInfo.mobileNumber}, '
                                            'businessName = ${userInfo.businessName}, address = ${userInfo.address}');

                                        if (isEditing) {
                                          context.read<AddUserCubit>().updateUser(userInfo);
                                        } else {
                                          context.read<AddUserCubit>().addUser(
                                            userInfo,
                                            _selectedUserType == UserType.Employee ? passwordController.text.trim() : '',
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