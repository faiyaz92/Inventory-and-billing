import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_cubit.dart';

@RoutePage()
class AddTenantCompanyPage extends StatelessWidget {
  final TenantCompany? company; // Nullable: Used for editing

  const AddTenantCompanyPage({super.key, this.company});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddTenantCompanyCubit>(),
      child: _AddTenantCompanyView(company: company),
    );
  }
}

class _AddTenantCompanyView extends StatefulWidget {
  final TenantCompany? company;

  const _AddTenantCompanyView({required this.company});

  @override
  State<_AddTenantCompanyView> createState() => _AddTenantCompanyViewState();
}

class _AddTenantCompanyViewState extends State<_AddTenantCompanyView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      nameController.text = widget.company?.name ?? '';
      emailController.text = widget.company?.email ?? '';
      phoneController.text = widget.company?.mobileNumber ?? '';
      gstController.text = widget.company?.gstin ?? "";
      countryController.text = widget.company?.country ?? "";
      cityController.text = widget.company?.city ?? "";
      addressController.text = widget.company?.address ?? "";
      zipCodeController.text = widget.company?.zipCode ?? "";
      stateController.text = widget.company?.state ?? "";
    }
  }

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    gstController.clear();
    countryController.clear();
    cityController.clear();
    addressController.clear();
    zipCodeController.clear();
    stateController.clear();
    passwordController.clear();
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
    bool isEditing = widget.company != null;
    final coordinator = sl<Coordinator>();

    return Scaffold(
      appBar: CustomAppBar(
          title: isEditing ? "Edit Tenant Company" : "Add Tenant Company"),
      body: BlocConsumer<AddTenantCompanyCubit, AddTenantCompanyState>(
        listener: (context, state) {
          if (state is AddTenantCompanySuccess) {
            _showSuccessDialog("Company added successfully!");
          } else if (state is AddTenantCompanyUpdated) {
            _showSuccessDialog("Company updated successfully!");
          } else if (state is AddTenantCompanyError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, state) {
          final addTenantCompanyCubit = context.read<AddTenantCompanyCubit>();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: "Company Name")),
                  TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email")),
                  TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: "Phone Number")),
                  TextField(
                      controller: gstController,
                      decoration: const InputDecoration(labelText: "GSTIN")),
                  TextField(
                      controller: countryController,
                      decoration: const InputDecoration(labelText: "Country")),
                  TextField(
                      controller: stateController,
                      decoration: const InputDecoration(labelText: "State")),
                  TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: "City")),
                  TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: "Address")),
                  TextField(
                      controller: zipCodeController,
                      decoration: const InputDecoration(labelText: "Zip Code")),
                  if (!isEditing) // Show password field only when adding a new company
                    TextField(
                        controller: passwordController,
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        obscureText: true),
                  const SizedBox(height: 20),
                  state is AddTenantCompanyLoading
                      ? const CircularProgressIndicator() // Show loading indicator
                      : ElevatedButton(
                          onPressed: () {
                            final tenantCompany = TenantCompany(
                              name: nameController.text,
                              email: emailController.text,
                              mobileNumber: phoneController.text,
                              gstin: gstController.text,
                              country: countryController.text,
                              state: stateController.text,
                              city: cityController.text,
                              address: addressController.text,
                              zipCode: zipCodeController.text,
                            );

                            if (isEditing) {
                              addTenantCompanyCubit
                                  .updateTenantCompany(tenantCompany);
                            } else {
                              addTenantCompanyCubit.addTenantCompany(
                                  tenantCompany, passwordController.text);
                            }
                          },
                          child: Text(
                              isEditing ? "Update Company" : "Create Company"),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
