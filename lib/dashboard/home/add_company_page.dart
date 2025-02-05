// Updated AddCompanyPage class with edit functionality
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/utils/AppKeys.dart';
import 'package:requirment_gathering_app/utils/AppLabels.dart';
import 'package:requirment_gathering_app/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/widget/custom_button.dart';
import 'package:requirment_gathering_app/widget/custom_textfield.dart';

import '../../utils/text_styles.dart';

class AddCompanyPage extends StatefulWidget {
  final Company? company; // Optional company for editing

  const AddCompanyPage({Key? key, this.company}) : super(key: key);

  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  // Controllers for managing text fields
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController websiteLinkController = TextEditingController();
  final TextEditingController linkedInLinkController = TextEditingController();
  final TextEditingController clutchLinkController = TextEditingController();
  final TextEditingController goodFirmLinkController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Dynamic controllers for Contact Persons
  final List<Map<String, TextEditingController>> contactPersonControllers = [];
  late final CompanyCubit companyCubit;

  @override
  void initState() {
    super.initState();

    companyCubit = sl<CompanyCubit>()..loadCompanySettings();

    // If company is provided, pre-fill the data for editing
    if (widget.company != null) {
      final company = widget.company!;
      companyNameController.text = company.companyName;
      addressController.text = company.address ?? '';
      emailController.text = company.email ?? '';
      contactNumberController.text = company.contactNumber ?? '';
      websiteLinkController.text = company.websiteLink ?? '';
      linkedInLinkController.text = company.linkedInLink ?? '';
      clutchLinkController.text = company.clutchLink ?? '';
      goodFirmLinkController.text = company.goodFirmLink ?? '';
      descriptionController.text = company.description ?? '';

      for (final contact in company.contactPersons) {
        contactPersonControllers.add({
          AppKeys.companyNameKey: TextEditingController(text: contact.name),
          AppKeys.emailKey: TextEditingController(text: contact.email),
          AppKeys.contactNumberKey:
              TextEditingController(text: contact.phoneNumber),
        });
      }

      companyCubit.updateCompany(company);
    }
  }

  @override
  void dispose() {
    companyNameController.dispose();
    addressController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    websiteLinkController.dispose();
    linkedInLinkController.dispose();
    clutchLinkController.dispose();
    goodFirmLinkController.dispose();
    for (final controllers in contactPersonControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => companyCubit,
      child: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.isSaved) {
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
        builder: (context, state) {
          final cubit = context.read<CompanyCubit>();

          return Scaffold(
            appBar: CustomAppBar(
              title: widget.company == null ? "Add Company" : "Edit Company",
              automaticallyImplyLeading: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.list_alt), // You can use any icon you like
                  onPressed: () {
                    sl<Coordinator>().navigateToAiCompanyListPage();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Field 1: Company Name
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildCompanyNameField(),
                  ),
                  // Field 2: Address
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildAddressField(),
                  ),
                  // Field 3: Email
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildEmailField(),
                  ),
                  // Field 4: Contact Number
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildContactNumberField(),
                  ),
                  // Field 5: Dynamic Contact Persons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildDynamicContactPersonsField(cubit),
                  ),
                  // Field 6: Country
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildBusinessTypeField(cubit, state),
                  ),// Field 6: Country
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildCountryField(cubit, state),
                  ),
                  // Field 7: City
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildCityField(cubit, state),
                  ),
                  // Field 8: Source
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildSourceField(cubit, state),
                  ),
                  // Field 9: Email Sent
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildEmailSentField(cubit, state),
                  ),
                  // Field 10: They Replied
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildRepliedField(cubit, state),
                  ),
                  // Field 11: Interest Level
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildInterestLevelField(cubit, state),
                  ),
                  // Field 12: Priority
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildPriorityField(cubit, state),
                  ),
                  // Field 13: Assigned To
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildAssignedToField(cubit, state),
                  ),
                  // Field 14: Verified On
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildVerifiedOnField(cubit, state),
                  ),
                  // Field 15: Website Link
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildWebsiteLinkField(cubit),
                  ),
                  // Field 16: LinkedIn Link
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildLinkedInLinkField(cubit),
                  ),
                  // Field 17: Clutch Link
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildClutchLinkField(cubit),
                  ),
                  // Field 18: GoodFirm Link
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildGoodFirmLinkField(cubit),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildDescriptionField(),
                  ),
                  const SizedBox(height: 16),
                  // Save Button
                  _buildSaveButton(cubit),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Widget methods will be added in chunks as needed

  // Individual Field Builders
  // Individual Field Builders with Icons
  // Field 1: Company Name
  Widget _buildCompanyNameField() {
    return CustomTextField(
      controller: companyNameController,
      labelText: AppLabels.companyNameLabel,
      hintText: AppLabels.companyNameHint,
      prefixIcon: const Icon(Icons.business),
      maxLength: 50,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      labelStyle: defaultTextStyle(
        fontWeight: FontWeight.bold, // Bold for label
        fontSize: 14,
      ),
      hintStyle: defaultTextStyle(
        fontWeight: FontWeight.bold, // Bold for hint
        fontSize: 14,
        color: Colors.grey, // Hint color
      ),
    );
  }

// Field 2: Address
  Widget _buildAddressField() {
    return CustomTextField(
      controller: addressController,
      labelText: AppLabels.addressLabel,
      hintText: AppLabels.addressHint,
      prefixIcon: const Icon(Icons.location_on),
      maxLength: 100,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization
          .sentences, // Capitalize first letter of each sentence
    );
  }

// Field 3: Email
  Widget _buildEmailField() {
    return CustomTextField(
      controller: emailController,
      labelText: AppLabels.emailLabel,
      hintText: AppLabels.emailHint,
      prefixIcon: const Icon(Icons.email),
      maxLength: 50,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none, // No capitalization
    );
  }

// Field 4: Contact Number
  Widget _buildContactNumberField() {
    return CustomTextField(
      controller: contactNumberController,
      labelText: AppLabels.contactNumberLabel,
      hintText: AppLabels.contactNumberHint,
      prefixIcon: const Icon(Icons.phone),
      maxLength: 15,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.none, // No capitalization
    );
  }

  // Field 5: Dynamic Contact Persons
  Widget _buildDynamicContactPersonsField(CompanyCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppLabels.contactPersonLabel,
            style: TextStyle(fontWeight: FontWeight.bold)),
        ...List.generate(contactPersonControllers.length, (index) {
          final controllers = contactPersonControllers[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: controllers[AppKeys.companyNameKey]!,
                    labelText: AppLabels.contactPersonNameLabel,
                    hintText: AppLabels.contactPersonNameHint,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: controllers[AppKeys.emailKey]!,
                    labelText: AppLabels.emailLabel,
                    hintText: AppLabels.emailHint,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: controllers[AppKeys.contactNumberKey]!,
                    labelText: AppLabels.contactNumberLabel,
                    hintText: AppLabels.contactNumberHint,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  Center(
                    child: IconButton(
                      onPressed: () => setState(() {
                        contactPersonControllers.removeAt(index);
                      }),
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
          onPressed: () => setState(() {
            contactPersonControllers.add({
              AppKeys.companyNameKey: TextEditingController(),
              AppKeys.emailKey: TextEditingController(),
              AppKeys.contactNumberKey: TextEditingController(),
            });
          }),
          child: const Text("Add Contact Person"),
        ),
      ],
    );
  }

  // Field 6: Country
  Widget _buildCountryField(CompanyCubit cubit, CompanyState state) {
    final countries =
        state.company?.settings?.countryCityMap.keys.toList() ?? [];
    return DropdownButtonFormField<String>(
      value: state.company?.country,
      items: countries
          .map((country) =>
              DropdownMenuItem(value: country, child: Text(country)))
          .toList(),
      onChanged: (selectedCountry) {
        if (selectedCountry != null) {
          cubit.updateCountry(selectedCountry);
          cubit.updateCity(null); // Reset city when country changes
        }
      },
      decoration: const InputDecoration(
        labelText: AppLabels.countryLabel,
        hintText: AppLabels.countryHint,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Field 7: City
  Widget _buildCityField(CompanyCubit cubit, CompanyState state) {
    final selectedCountry = state.company?.country;
    final cities =
        state.company?.settings?.countryCityMap[selectedCountry] ?? [];
    return DropdownButtonFormField<String>(
      value: cities.contains(state.company?.city) ? state.company?.city : null,
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

  // Field 8: Source
  Widget _buildSourceField(CompanyCubit cubit, CompanyState state) {
    final sources = state.company?.settings?.sources ?? [];
    return DropdownButtonFormField<String>(
      value: state.company?.source,
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

// Field 9: Email Sent
  Widget _buildEmailSentField(CompanyCubit cubit, CompanyState state) {
    return _buildRadioField(
      AppLabels.emailSentLabel,
      state.company?.emailSent ?? false,
      cubit.updateEmailSent,
    );
  }

// Field 10: They Replied
  Widget _buildRepliedField(CompanyCubit cubit, CompanyState state) {
    return _buildRadioField(
      AppLabels.theyRepliedLabel, // Use label from AppLabels
      state.company?.theyReplied ?? false,
      cubit.updateRepliedTo,
    );
  }

// Field 11: Interest Level
  Widget _buildInterestLevelField(CompanyCubit cubit, CompanyState state) {
    return DropdownButtonFormField<String>(
      value: state.company?.interestLevel,
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

// Field 12: Priority
  Widget _buildPriorityField(CompanyCubit cubit, CompanyState state) {
    final priorities = state.company?.settings?.priorities ?? [];
    return DropdownButtonFormField<String>(
      value: state.company?.priority,
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

// Field 13: Assigned To
  Widget _buildAssignedToField(CompanyCubit cubit, CompanyState state) {
    return DropdownButtonFormField<String>(
      value: state.company?.assignedTo,
      items: ['Faiyaz', 'Faizan']
          .map((user) => DropdownMenuItem(value: user, child: Text(user)))
          .toList(),
      onChanged: cubit.updateAssignedTo,
      decoration: const InputDecoration(
        labelText: AppLabels.assignedToLabel,
        border: OutlineInputBorder(),
      ),
    );
  }

// Field 14: Verified On
  Widget _buildVerifiedOnField(CompanyCubit cubit, CompanyState state) {
    final verifiedPlatforms = state.company?.settings?.verifiedOn ?? [];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity, // Ensures the card matches the screen width
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
                  final isChecked =
                      state.company?.verifiedOn.contains(platform) ?? false;
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

  Widget _buildWebsiteLinkField(CompanyCubit cubit) {
    websiteLinkController.text = cubit.state.company?.websiteLink ?? '';
    return CustomTextField(
      controller: websiteLinkController,
      labelText: AppLabels.websiteLinkLabel,
      // Use label from AppLabels
      hintText: AppLabels.websiteLinkHint,
      // Use hint from AppLabels
      prefixIcon: const Icon(Icons.link),
      maxLength: 100,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
    );
  }

// Field 16: LinkedIn Link
  Widget _buildLinkedInLinkField(CompanyCubit cubit) {
    linkedInLinkController.text = cubit.state.company?.linkedInLink ?? '';
    return CustomTextField(
      controller: linkedInLinkController,
      labelText: AppLabels.linkedInLinkLabel,
      // Use label from AppLabels
      hintText: AppLabels.linkedInLinkHint,
      // Use hint from AppLabels
      prefixIcon: const Icon(Icons.link),
      maxLength: 100,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
    );
  }

// Field 17: Clutch Link
  Widget _buildClutchLinkField(CompanyCubit cubit) {
    clutchLinkController.text = cubit.state.company?.clutchLink ?? '';
    return CustomTextField(
      controller: clutchLinkController,
      labelText: AppLabels.clutchLinkLabel,
      // Use label from AppLabels
      hintText: AppLabels.clutchLinkHint,
      // Use hint from AppLabels
      prefixIcon: const Icon(Icons.link),
      maxLength: 100,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
    );
  }

// Field 18: GoodFirm Link
  Widget _buildGoodFirmLinkField(CompanyCubit cubit) {
    goodFirmLinkController.text = cubit.state.company?.goodFirmLink ?? '';
    return CustomTextField(
      controller: goodFirmLinkController,
      labelText: AppLabels.goodFirmLinkLabel,
      // Use label from AppLabels
      hintText: AppLabels.goodFirmLinkHint,
      // Use hint from AppLabels
      prefixIcon: const Icon(Icons.link),
      maxLength: 100,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
    );
  }

  //Field 18: GoodFirm Link: Description
  Widget _buildDescriptionField() {
    return CustomTextField(
      controller: descriptionController,
      // Use controller from the page for edit capability
      labelText: AppLabels.descriptionLabel,
      hintText: AppLabels.descriptionHint,
      maxLength: 500,
      // maxLines: 5,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
    );
  }
  // Field 19: Source
  Widget _buildBusinessTypeField(CompanyCubit cubit, CompanyState state) {
    final sources = state.company?.settings?.businessTypes ?? [];
    return DropdownButtonFormField<String>(
      value: state.company?.businessType,
      items: sources
          .map((source) => DropdownMenuItem(value: source, child: Text(source)))
          .toList(),
      onChanged: cubit.updateBusinessType,
      decoration: const InputDecoration(
        labelText: AppLabels.businessTypeLabel,
        border: OutlineInputBorder(),
      ),
    );
  }
// Save Button
  Widget _buildSaveButton(
    CompanyCubit cubit,
  ) {
    return Center(
      child: CustomButton(
        text: AppLabels.saveButtonText, // Use label from AppLabels
        isLoading: cubit.state.isSaving,
        onPressed: () {
          // Collect data locally and save it
          final contactPersons = contactPersonControllers.map((controllers) {
            return ContactPerson(
              name: controllers[AppKeys.companyNameKey]!.text,
              email: controllers[AppKeys.emailKey]!.text,
              phoneNumber: controllers[AppKeys.contactNumberKey]!.text,
            );
          }).toList();

          final updatedCompany = cubit.state.company?.copyWith(
            companyName: companyNameController.text,
            address: addressController.text,
            email: emailController.text,
            contactNumber: contactNumberController.text,
            contactPersons: contactPersons,
            websiteLink: websiteLinkController.text,
            linkedInLink: linkedInLinkController.text,
            clutchLink: clutchLinkController.text,
            goodFirmLink: goodFirmLinkController.text,
            description: descriptionController.text,
            // Use description controller's text
            createdBy: "Faizan",
            lastUpdatedBy: "Faizan",
          );
          if (updatedCompany != null) {
            cubit.updateCompany(updatedCompany);
            cubit.saveCompany();
          }
        },
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: defaultTextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 16,
        ),
      ),
    );
  }
}
