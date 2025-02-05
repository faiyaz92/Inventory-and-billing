import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/ai_module/ai_company_list_cubit.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/utils/AppColor.dart';
import 'package:requirment_gathering_app/utils/AppLabels.dart';
import 'package:requirment_gathering_app/utils/text_styles.dart';
import 'package:requirment_gathering_app/widget/custom_appbar.dart';

class AiCompanyListPage extends StatefulWidget {
  const AiCompanyListPage({super.key});

  @override
  State<AiCompanyListPage> createState() => _AiCompanyListPageState();
}

class _AiCompanyListPageState extends State<AiCompanyListPage> {
  final cubit = sl<AiCompanyListCubit>();

  @override
  void initState() {
    cubit.loadCompanySettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Ai Company List',
      ),
      body: BlocProvider(
        create: (context) => cubit,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<AiCompanyListCubit, AiCompanyListState>(
            buildWhen: (previous, current) =>
                current is CompanyListLoadedWithSettings ||
                current is CompanyListLoaded,
            builder: (context, state) {
              if (state is CompanyListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CompanyListLoadedWithSettings || state is CompanyListLoaded) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdownRow(context),
                    // Method for dropdown row
                    _buildBusinessTypeDropdown(context),
                    // Method for Business Type Dropdown
                    _buildSearchAndFindRow(context),
                    // Method for search and find button row
                    Expanded(child: _buildCompanyList(context)),
                    // Method for displaying company list
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

// Method for the dropdown row
  Widget _buildDropdownRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildCountryDropdown(context)),
        const SizedBox(width: 8),
        Expanded(child: _buildCityDropdown(context)),
        const SizedBox(width: 8),
        // Business Type Dropdown will be placed here as a separate widget
      ],
    );
  }

// Country Dropdown
  Widget _buildCountryDropdown(BuildContext context) {
    return BlocBuilder<AiCompanyListCubit, AiCompanyListState>(
      buildWhen: (previous, current) =>
          current is CompanyListLoadedWithSettings ||
          current is CountrySelected,
      builder: (context, state) {
        if (state is CountrySelected ||
            state is CompanyListLoadedWithSettings) {
          List<String> countries = state is CompanyListLoadedWithSettings
              ? state.countries
              : state is CountrySelected
                  ? state.countries
                  : [];
          return _buildDropdown<String>(
            value: context.read<AiCompanyListCubit>().selectedCountry,
            items: countries.isEmpty
                ? []
                : countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
            onChanged: (newCountry) {
              if (newCountry != null) {
                context.read<AiCompanyListCubit>().updateCountry(newCountry);
              }
            },
            hint: "Country",
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

// City Dropdown
  Widget _buildCityDropdown(BuildContext context) {
    return BlocBuilder<AiCompanyListCubit, AiCompanyListState>(
      buildWhen: (previous, current) =>
          current is CitySelected ||
          current is CitiesUpdated ||
          current is CompanyListLoadedWithSettings,
      builder: (context, state) {
        if (state is CitiesUpdated) {
          final cities = state.cities;
          return _buildDropdown<String>(
            value: context.read<AiCompanyListCubit>().selectedCity,
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (newCity) {
              context.read<AiCompanyListCubit>().updateCity(newCity!);
            },
            hint: "City",
          );
        } else if (state is CitySelected) {
          final selectedCity = state.selectedCity;
          final cities = state.cities;
          return _buildDropdown<String>(
            value: selectedCity.isNotEmpty ? selectedCity : null,
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (newCity) {
              context.read<AiCompanyListCubit>().updateCity(newCity!);
            },
            hint: "City",
          );
        }
        return _buildDropdown<String>(
          value: null,
          items: [],
          onChanged: (newCity) {},
          hint: "City",
        );
      },
    );
  }

// Business Type Dropdown
  Widget _buildBusinessTypeDropdown(BuildContext context) {
    return BlocBuilder<AiCompanyListCubit, AiCompanyListState>(
      buildWhen: (previous, current) =>
          current is CompanyListLoadedWithSettings ||
          current is BusinessTypeSelected,
      builder: (context, state) {
        final List<String> businessTypes =
            state is CompanyListLoadedWithSettings
                ? state.businessTypes
                : state is BusinessTypeSelected
                    ? state.businessTypes
                    : [];
        return _buildDropdown<String>(
          value: context.read<AiCompanyListCubit>().selectedBusinessType,
          items: businessTypes.map((businessType) {
            return DropdownMenuItem<String>(
              value: businessType,
              child: Text(businessType),
            );
          }).toList(),
          onChanged: (newBusinessType) {
            if (newBusinessType != null) {
              context
                  .read<AiCompanyListCubit>()
                  .updateBusinessType(newBusinessType);
            }
          },
          hint: "Business Type",
        );
      },
    );
  }

// Search and Find Button Row
  Widget _buildSearchAndFindRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: TextField(
              onChanged: (_) {},
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppLabels.searchHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            context.read<AiCompanyListCubit>().fetchCompanyList('');
          },
          child: const Text('Find'),
        ),
      ],
    );
  }

// Company List Display Section
  Widget _buildCompanyList(BuildContext context) {
    return BlocBuilder<AiCompanyListCubit, AiCompanyListState>(
      buildWhen: (previous, current) => current is CompanyListLoaded,
      builder: (context, state) {
        if (state is CompanyListLoaded) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.companies.length,
            itemBuilder: (context, index) {
              final company = state.companies[index];
              return _buildCompanyListTile(
                context,
                company,
              );
            },
          );
        }
        return Container();
      },
    );
  }

  // Helper method to build a dropdown with decoration and observing state
  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    // Ensure the selected value is in the list, or null if not
    T? validValue;
    if (value != null) {
      // Check if the value exists in the list, if not, set to null
      bool valueExists = items.any((item) => item.value == value);
      validValue = valueExists ? value : null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: DropdownButtonFormField<T>(
        value: validValue,
        // Set valid value (either matched or null)
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: hint,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          filled: true,
          fillColor: Colors.white,
        ),
        hint: Text(hint),
      ),
    );
  }

  Widget _buildCompanyListTile(
      BuildContext context,
      /*CompanyCubit cubit,*/
      Company company) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Labels and Squares
            /*  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppLabels.interestLevelLabel,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      StatusSquare(
                        text: company.interestLevel ?? AppLabels.notAvailable,
                        backgroundColor: cubit.getInterestLevelColor(company.interestLevel),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppLabels.priorityLabel,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      StatusSquare(
                        text: company.priority ?? AppLabels.notAvailable,
                        backgroundColor: cubit.getPriorityColor(company.priority),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppLabels.emailSentLabel,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      StatusSquare(
                        text: company.emailSent
                            ? AppLabels.emailSentYesLabel
                            : AppLabels.emailSentNoLabel,
                        backgroundColor: cubit.getEmailSentColor(company.emailSent),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppLabels.theyRepliedLabel,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      StatusSquare(
                        text: company.theyReplied
                            ? AppLabels.emailSentYesLabel
                            : AppLabels.emailSentNoLabel,
                        backgroundColor: cubit.getRepliedColor(company.theyReplied),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),*/

            // Details and Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailedBox(
                          AppLabels.companyNameLabel, company.companyName),
                      _buildDetailedBox(AppLabels.addressLabel,
                          company.address ?? AppLabels.noAddress),
                      _buildDetailedBox(AppLabels.emailLabel,
                          company.email ?? AppLabels.noEmail),
                      _buildDetailedBox(AppLabels.contactNumberLabel,
                          company.contactNumber ?? AppLabels.noContactNumber),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      icon: Icons.remove_red_eye,
                      color: AppColors.viewButtonColor,
                      tooltip: AppLabels.viewCompanyTooltip,
                      onPressed: () => sl<Coordinator>()
                          .navigateToCompanyDetailsPage(company),
                    ),
                    const SizedBox(height: 8),
                    _buildIconButton(
                      icon: Icons.edit,
                      color: AppColors.editButtonColor,
                      tooltip: AppLabels.editCompanyTooltip,
                      onPressed: () =>
                          sl<Coordinator>().navigateToEditCompanyPage(company),
                    ),
                    const SizedBox(height: 8),
                    _buildIconButton(
                      icon: Icons.delete,
                      color: AppColors.deleteButtonColor,
                      tooltip: AppLabels.deleteCompanyTooltip,
                      onPressed: () =>
                          _showDeleteConfirmation(context, company),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBox(String label, String? value) {
    final displayValue = sl<CompanyCubit>().validateValue(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: defaultTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.labelColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: (label == AppLabels.emailLabel &&
                      value != null &&
                      value.trim().isNotEmpty)
                  ? () async {
                      await sl<CompanyCubit>().launchUrl("mailto:$value");
                    }
                  : (label == AppLabels.contactNumberLabel &&
                          value != null &&
                          value.trim().isNotEmpty)
                      ? () async {
                          await sl<CompanyCubit>().launchUrl("tel:$value");
                        }
                      : null,
              child: Text(
                displayValue,
                style: defaultTextStyle(
                  fontSize: 14,
                  color: (label == AppLabels.emailLabel ||
                          label == AppLabels.contactNumberLabel)
                      ? Colors.blue
                      : AppColors.textFieldColor,
                  decoration: (label == AppLabels.emailLabel ||
                          label == AppLabels.contactNumberLabel)
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Company company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppLabels.deleteConfirmationTitle),
          content: Text(
              "${AppLabels.deleteConfirmationMessage} '${company.companyName}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppLabels.cancelButtonText),
            ),
            TextButton(
              onPressed: () {
                // cubit.deleteCompany(company.id);
                Navigator.of(context).pop();
              },
              child: const Text(AppLabels.deleteButtonText),
            ),
          ],
        );
      },
    );
  }
}
