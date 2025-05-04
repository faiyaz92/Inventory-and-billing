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

class AddSupplierPage extends StatefulWidget {
  final Partner? company;

  const AddSupplierPage({Key? key, this.company}) : super(key: key);

  @override
  _AddSupplierPageState createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  @override
  void initState() {
    super.initState();
    _initializeCubit();
  }

  Future<void> _initializeCubit() async {
    final cubit = sl<PartnerCubit>();
    await cubit.initializeWithCompany(widget.company);
    await cubit.loadCompanySettings();
    await cubit.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PartnerCubit>(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: widget.company == null ? "Add Supplier" : "Edit Supplier",
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
                // Source Dropdown
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      (current.settings !=
                              (previous is CompanyDataState
                                  ? previous.settings
                                  : null) ||
                          current.company?.source !=
                              (previous is CompanyDataState
                                  ? previous.company?.source
                                  : null)),
                  builder: (context, state) {
                    final settings =
                        state is CompanyDataState ? state.settings : null;
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildSourceField(
                        context.read<PartnerCubit>(),
                        settings,
                        company?.source,
                      ),
                    );
                  },
                ),
                // Email Sent Radio
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.emailSent != previous.company?.emailSent,
                  builder: (context, state) {
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildEmailSentField(
                        context.read<PartnerCubit>(),
                        company?.emailSent ?? false,
                      ),
                    );
                  },
                ),
                // Replied Radio
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.theyReplied !=
                          previous.company?.theyReplied,
                  builder: (context, state) {
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildRepliedField(
                        context.read<PartnerCubit>(),
                        company?.theyReplied ?? false,
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
                // Verified On Chips
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      (current.settings !=
                              (previous is CompanyDataState
                                  ? previous.settings
                                  : null) ||
                          current.company?.verifiedOn !=
                              (previous is CompanyDataState
                                  ? previous.company?.verifiedOn
                                  : null)),
                  builder: (context, state) {
                    final settings =
                        state is CompanyDataState ? state.settings : null;
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _buildVerifiedOnField(
                        context.read<PartnerCubit>(),
                        settings,
                        company?.verifiedOn ?? [],
                      ),
                    );
                  },
                ),
                // Website Link
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.websiteLink !=
                          previous.company?.websiteLink,
                  builder: (context, state) {
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.websiteLink,
                        labelText: AppLabels.websiteLinkLabel,
                        hintText: AppLabels.websiteLinkHint,
                        prefixIcon: const Icon(Icons.link),
                        maxLength: 100,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        onChanged:
                            context.read<PartnerCubit>().updateWebsiteLink,
                      ),
                    );
                  },
                ),
                // LinkedIn Link
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.linkedInLink !=
                          previous.company?.linkedInLink,
                  builder: (context, state) {
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.linkedInLink,
                        labelText: AppLabels.linkedInLinkLabel,
                        hintText: AppLabels.linkedInLinkHint,
                        prefixIcon: const Icon(Icons.link),
                        maxLength: 100,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        onChanged:
                            context.read<PartnerCubit>().updateLinkedInLink,
                      ),
                    );
                  },
                ),
                // Clutch Link
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.clutchLink !=
                          previous.company?.clutchLink,
                  builder: (context, state) {
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.clutchLink,
                        labelText: AppLabels.clutchLinkLabel,
                        hintText: AppLabels.clutchLinkHint,
                        prefixIcon: const Icon(Icons.link),
                        maxLength: 100,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        onChanged:
                            context.read<PartnerCubit>().updateClutchLink,
                      ),
                    );
                  },
                ),
                // GoodFirm Link
                BlocBuilder<PartnerCubit, CompanyState>(
                  buildWhen: (previous, current) =>
                      current is CompanyDataState &&
                      previous is CompanyDataState &&
                      current.company?.goodFirmLink !=
                          previous.company?.goodFirmLink,
                  builder: (context, state) {
                    final company =
                        state is CompanyDataState ? state.company : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CustomTextField(
                        initialValue: company?.goodFirmLink,
                        labelText: AppLabels.goodFirmLinkLabel,
                        hintText: AppLabels.goodFirmLinkHint,
                        prefixIcon: const Icon(Icons.link),
                        maxLength: 100,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        onChanged:
                            context.read<PartnerCubit>().updateGoodFirmLink,
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
                        onPressed: () async{
                          await context
                              .read<PartnerCubit>()
                              .saveCompany('Site');
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

  Widget _buildSourceField(
      PartnerCubit cubit, CompanySettingsUi? settings, String? selectedValue) {
    final sources = settings?.sources ?? [];
    return DropdownButtonFormField<String>(
      value: sources.contains(selectedValue) ? selectedValue : null,
      items: sources
          .map((source) => DropdownMenuItem(value: source, child: Text(source)))
          .toList(),
      onChanged: cubit.updateSource,
      decoration: const InputDecoration(
        labelText: AppLabels.sourceLabel,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildEmailSentField(PartnerCubit cubit, bool value) {
    return _buildRadioField(
        AppLabels.emailSentLabel, value, cubit.updateEmailSent);
  }

  Widget _buildRepliedField(PartnerCubit cubit, bool value) {
    return _buildRadioField(
        AppLabels.theyRepliedLabel, value, cubit.updateRepliedTo);
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

  Widget _buildVerifiedOnField(PartnerCubit cubit, CompanySettingsUi? settings,
      List<String> verifiedOn) {
    final verifiedPlatforms = settings?.verifiedOn ?? [];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppLabels.verifiedOnLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: verifiedPlatforms.map((platform) {
                  final isChecked = verifiedOn.contains(platform);
                  return FilterChip(
                    label: Text(
                      platform,
                      style: defaultTextStyle(
                          color: isChecked ? Colors.white : Colors.black),
                    ),
                    selected: isChecked,
                    onSelected: (value) =>
                        cubit.updateVerification(platform, value),
                    selectedColor: Colors.green,
                    checkmarkColor: isChecked ? Colors.white : Colors.black,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioField(
      String title, bool groupValue, Function(bool?) onChanged) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: defaultTextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(
                      AppLabels.emailSentYesLabel,
                      style: defaultTextStyle(fontSize: 14),
                    ),
                    value: true,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(
                      AppLabels.emailSentNoLabel,
                      style: defaultTextStyle(fontSize: 14),
                    ),
                    value: false,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
