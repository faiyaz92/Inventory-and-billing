import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/presentation/add_tenant_company/add_tenant_company_cubit.dart';

@RoutePage()
class AddTenantCompanyPage extends StatelessWidget {
  final TenantCompany? company;

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
  final TextEditingController adminUsernameController = TextEditingController();
  final TextEditingController adminNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      nameController.text = widget.company?.name ?? '';
      emailController.text = widget.company?.email ?? '';
      phoneController.text = widget.company?.mobileNumber ?? '';
      gstController.text = widget.company?.gstin ?? '';
      countryController.text = widget.company?.country ?? '';
      cityController.text = widget.company?.city ?? '';
      addressController.text = widget.company?.address ?? '';
      zipCodeController.text = widget.company?.zipCode ?? '';
      stateController.text = widget.company?.state ?? '';
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
    adminUsernameController.clear();
    adminNameController.clear();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Success',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.company != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Tenant Company' : 'Add Tenant Company',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AddTenantCompanyCubit, AddTenantCompanyState>(
          listener: (context, state) {
            if (state is AddTenantCompanySuccess) {
              _showSuccessDialog('Company added successfully!');
            } else if (state is AddTenantCompanyUpdated) {
              _showSuccessDialog('Company updated successfully!');
            } else if (state is AddTenantCompanyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            final addTenantCompanyCubit = context.read<AddTenantCompanyCubit>();

            return SingleChildScrollView(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(nameController, 'Company Name', context),
                    _buildTextField(emailController, 'Email', context),
                    _buildTextField(phoneController, 'Phone Number', context),
                    _buildTextField(gstController, 'GSTIN', context),
                    _buildTextField(countryController, 'Country', context),
                    _buildTextField(stateController, 'State', context),
                    _buildTextField(cityController, 'City', context),
                    _buildTextField(addressController, 'Address', context),
                    _buildTextField(zipCodeController, 'Zip Code', context),
                    if (!isEditing) ...[
                      _buildTextField(
                          adminUsernameController, 'Admin Username', context),
                      _buildTextField(adminNameController, 'Admin Name', context),
                      _buildPasswordField(passwordController, 'Password', context),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          final tenantCompany = TenantCompany(
                            id: widget.company?.id,
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
                            addTenantCompanyCubit.updateTenantCompany(tenantCompany);
                          } else {
                            addTenantCompanyCubit.addTenantCompany(
                              tenantCompany,
                              passwordController.text,
                              adminUsernameController.text,
                              adminNameController.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Company' : 'Create Company',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
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
      ),
    );
  }
}