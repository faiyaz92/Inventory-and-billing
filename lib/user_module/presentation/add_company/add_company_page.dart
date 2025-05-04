import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_button.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_textfield.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_state.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';

class AddCompanyPage extends StatefulWidget {
  final Partner? company;

  const AddCompanyPage({Key? key, this.company}) : super(key: key);

  @override
  _AddCompanyPageState createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  late PartnerCubit _partnerCubit;

  @override
  void initState() {
    _initializeCubit();
    super.initState();
  }

  _initializeCubit() {
    _partnerCubit = sl<PartnerCubit>()
      ..initializeWithCompany(widget.company)
      ..loadCompanySettings()
      ..loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _partnerCubit,
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.company == null ? "Add Site" : "Edit Site",
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: () => sl<Coordinator>().navigateToAiCompanyListPage(),
            ),
          ],
        ),
        body: BlocListener<PartnerCubit, CompanyState>(
          listener: (context, state) {
            if (state is ErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is SavedState) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Success"),
                  content: Text(widget.company == null
                      ? "Company details saved successfully!"
                      : "Company details updated successfully!"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Name
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.companyName !=
                          previous.company?.companyName,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.companyName,
                        labelText: AppLabels.companyNameLabel,
                        hintText: AppLabels.companyNameHint,
                        prefixIcon: const Icon(Icons.business),
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        onChanged:
                        context.read<PartnerCubit>().updateCompanyName,
                      ),
                    );
                  },
                ),
                // Address
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.address != previous.company?.address,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.address,
                        labelText: AppLabels.addressLabel,
                        hintText: AppLabels.addressHint,
                        prefixIcon: const Icon(Icons.location_on),
                        maxLength: 100,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: context.read<PartnerCubit>().updateAddress,
                      ),
                    );
                  },
                ),
                // Email
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.email != previous.company?.email,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.email,
                        labelText: AppLabels.emailLabel,
                        hintText: AppLabels.emailHint,
                        prefixIcon: const Icon(Icons.email),
                        maxLength: 50,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        onChanged: context.read<PartnerCubit>().updateEmail,
                      ),
                    );
                  },
                ),
                // Contact Number
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.contactNumber !=
                          previous.company?.contactNumber,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.contactNumber,
                        labelText: AppLabels.contactNumberLabel,
                        hintText: AppLabels.contactNumberHint,
                        prefixIcon: const Icon(Icons.phone),
                        maxLength: 15,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                        onChanged:
                        context.read<PartnerCubit>().updateContactNumber,
                      ),
                    );
                  },
                ),
                // Contact Persons
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.contactPersons !=
                          previous.company?.contactPersons,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildDynamicContactPersonsField(
                        context.read<PartnerCubit>(),
                        company?.contactPersons ?? [],
                      ),
                    );
                  },
                ),
                // Business Type Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      (current.settings !=
                          (previous is CompanyDataState
                              ? previous.settings
                              : null) ||
                          current.company?.businessType !=
                              (previous is CompanyDataState
                                  ? previous.company?.businessType
                                  : null)),
                  builder: (context, state) {
                    final settings =
                    state is CompanyDataState ? state.settings : null;
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildBusinessTypeField(
                        context.read<PartnerCubit>(),
                        settings,
                        company?.businessType,
                      ),
                    );
                  },
                ),
                // Country Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      (current.settings !=
                          (previous is CompanyDataState
                              ? previous.settings
                              : null) ||
                          current.company?.country !=
                              (previous is CompanyDataState
                                  ? previous.company?.country
                                  : null)),
                  builder: (context, state) {
                    final settings =
                    state is CompanyDataState ? state.settings : null;
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildCountryField(
                        context.read<PartnerCubit>(),
                        settings,
                        company?.country,
                      ),
                    );
                  },
                ),
                // City Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      (current.settings !=
                          (previous is CompanyDataState
                              ? previous.settings
                              : null) ||
                          current.company?.country !=
                              (previous is CompanyDataState
                                  ? previous.company?.country
                                  : null) ||
                          current.company?.city !=
                              (previous is CompanyDataState
                                  ? previous.company?.city
                                  : null)),
                  builder: (context, state) {
                    final settings =
                    state is CompanyDataState ? state.settings : null;
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildCityField(
                        context.read<PartnerCubit>(),
                        settings,
                        company?.country,
                        company?.city,
                      ),
                    );
                  },
                ),
                // Interest Level Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.interestLevel !=
                          previous.company?.interestLevel,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildInterestLevelField(
                        context.read<PartnerCubit>(),
                        company?.interestLevel,
                      ),
                    );
                  },
                ),
                // Priority Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      (current.settings !=
                          (previous is CompanyDataState
                              ? previous.settings
                              : null) ||
                          current.company?.priority !=
                              (previous is CompanyDataState
                                  ? previous.company?.priority
                                  : null)),
                  builder: (context, state) {
                    final settings =
                    state is CompanyDataState ? state.settings : null;
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildPriorityField(
                        context.read<PartnerCubit>(),
                        settings,
                        company?.priority,
                      ),
                    );
                  },
                ),
                // Assigned To Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      (current.users !=
                          (previous is CompanyDataState
                              ? previous.users
                              : null) ||
                          current.company?.assignedTo !=
                              (previous is CompanyDataState
                                  ? previous.company?.assignedTo
                                  : null)),
                  builder: (context, state) {
                    final users = state is CompanyDataState ? state.users : [];
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildAssignedToField(
                        context.read<PartnerCubit>(),
                        users as List<UserInfo>,
                        company?.assignedTo,
                      ),
                    );
                  },
                ),
                // Description
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.description !=
                          previous.company?.description,
                  builder: (context, state) {
                    final company =
                    state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.description,
                        labelText: AppLabels.descriptionLabel,
                        hintText: AppLabels.descriptionHint,
                        maxLength: 500,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged:
                        context.read<PartnerCubit>().updateDescription,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Save Button
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                  current is SavingState || previous is SavingState,
                  builder: (context, state) {
                    return Center(
                      child: CustomButton(
                        text: AppLabels.saveButtonText,
                        isLoading: state is SavingState,
                        onPressed: () async {
                          await context.read<PartnerCubit>().saveCompany('Site');
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicContactPersonsField(
      PartnerCubit cubit, List<ContactPerson> contactPersons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppLabels.contactPersonLabel,
            style: TextStyle(fontWeight: FontWeight.bold)),
        ...List.generate(contactPersons.length, (index) {
          final contact = contactPersons[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    initialValue: contact.name,
                    labelText: AppLabels.contactPersonNameLabel,
                    hintText: AppLabels.contactPersonNameHint,
                    prefixIcon: const Icon(Icons.person),
                    onChanged: (value) => cubit.updateContactPerson(
                        index, value, contact.email, contact.phoneNumber),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    initialValue: contact.email,
                    labelText: AppLabels.emailLabel,
                    hintText: AppLabels.emailHint,
                    prefixIcon: const Icon(Icons.email),
                    onChanged: (value) => cubit.updateContactPerson(
                        index, contact.name, value, contact.phoneNumber),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    initialValue: contact.phoneNumber,
                    labelText: AppLabels.contactNumberLabel,
                    hintText: AppLabels.contactNumberHint,
                    prefixIcon: const Icon(Icons.phone),
                    onChanged: (value) => cubit.updateContactPerson(
                        index, contact.name, contact.email, value),
                  ),
                  Center(
                    child: IconButton(
                      onPressed: () => cubit.removeContactPerson(index),
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        ElevatedButton(
          onPressed: () => cubit.addContactPerson('', '', ''),
          child: const Text("Add Contact Person"),
        ),
      ],
    );
  }

  Widget _buildBusinessTypeField(
      PartnerCubit cubit, CompanySettingsUi? settings, String? selectedValue) {
    final businessTypes = settings?.businessTypes ?? [];
    return DropdownButtonFormField<String>(
      value: businessTypes.contains(selectedValue) ? selectedValue : null,
      items: businessTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: cubit.updateBusinessType,
      decoration: const InputDecoration(
        labelText: AppLabels.businessTypeLabel,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCountryField(
      PartnerCubit cubit, CompanySettingsUi? settings, String? selectedValue) {
    final countries = settings?.countryCityMap.keys.toList() ?? [];
    return DropdownButtonFormField<String>(
      value: countries.contains(selectedValue) ? selectedValue : null,
      items: countries
          .map((country) =>
          DropdownMenuItem(value: country, child: Text(country)))
          .toList(),
      onChanged: cubit.updateCountry,
      decoration: const InputDecoration(
        labelText: AppLabels.countryLabel,
        hintText: AppLabels.countryHint,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCityField(PartnerCubit cubit, CompanySettingsUi? settings,
      String? selectedCountry, String? selectedCity) {
    final cities = settings?.countryCityMap[selectedCountry] ?? [];
    return DropdownButtonFormField<String>(
      value: cities.contains(selectedCity) ? selectedCity : null,
      items: cities
          .map((city) => DropdownMenuItem(value: city, child: Text(city)))
          .toList(),
      onChanged: cubit.updateCity,
      decoration: const InputDecoration(
        labelText: AppLabels.cityLabel,
        hintText: AppLabels.cityHint,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildInterestLevelField(PartnerCubit cubit, String? value) {
    return DropdownButtonFormField<String>(
      value: value,
      items: List.generate(11, (index) => '${index * 10}%')
          .map((percentage) =>
          DropdownMenuItem(value: percentage, child: Text(percentage)))
          .toList(),
      onChanged: cubit.updateInterestLevel,
      decoration: const InputDecoration(
        labelText: AppLabels.interestLevelLabel,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPriorityField(
      PartnerCubit cubit, CompanySettingsUi? settings, String? selectedValue) {
    final priorities = settings?.priorities ?? [];
    return DropdownButtonFormField<String>(
      value: priorities.contains(selectedValue) ? selectedValue : null,
      items: priorities
          .map((priority) =>
          DropdownMenuItem(value: priority, child: Text(priority)))
          .toList(),
      onChanged: cubit.updatePriority,
      decoration: const InputDecoration(
        labelText: AppLabels.priorityLabel,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAssignedToField(
      PartnerCubit cubit, List<UserInfo> users, String? selectedValue) {
    return DropdownButtonFormField<String>(
      value: users.any((user) => user.userId == selectedValue)
          ? selectedValue
          : null,
      items: users.map((user) {
        return DropdownMenuItem(
          value: user.userId,
          child: Text(user.userName ?? "Unknown"),
        );
      }).toList(),
      onChanged: cubit.updateAssignedTo,
      decoration: const InputDecoration(
        labelText: "Assigned To",
        border: OutlineInputBorder(),
      ),
    );
  }
}