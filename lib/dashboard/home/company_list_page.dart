import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/utils/AppColor.dart';
import 'package:requirment_gathering_app/utils/AppLabels.dart';
import 'package:requirment_gathering_app/utils/text_styles.dart';

class CompanyListPage extends StatelessWidget {
  const CompanyListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompanyCubit>()..loadCompanies(),
      child: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          final cubit = context.read<CompanyCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text(AppLabels.companyListTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {
                    cubit.sortCompaniesByDate(ascending: true);
                  },
                  tooltip: AppLabels.sortAscendingTooltip,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () {
                    cubit.sortCompaniesByDate(ascending: false);
                  },
                  tooltip: AppLabels.sortDescendingTooltip,
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: cubit.searchCompanies,
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
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.companies.isEmpty
                          ? const Center(
                              child: Text(
                                AppLabels.noCompaniesFound,
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.companies.length,
                              itemBuilder: (context, index) {
                                final company = state.companies[index];
                                return _buildCompanyListTile(
                                    context, cubit, company);
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, CompanyCubit cubit, Company company) {
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
                cubit.deleteCompany(company.id);
                Navigator.of(context).pop();
              },
              child: const Text(AppLabels.deleteButtonText),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompanyListTile(
      BuildContext context, CompanyCubit cubit, Company company) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Added consistent margin
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Details Column
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailedBox(
                      AppLabels.companyNameLabel, company.companyName),
                  _buildDetailedBox(AppLabels.addressLabel,
                      company.address ?? AppLabels.noAddress),
                  _buildDetailedBox(
                      AppLabels.emailLabel, company.email ?? AppLabels.noEmail),
                  _buildDetailedBox(AppLabels.contactNumberLabel,
                      company.contactNumber ?? AppLabels.noContactNumber),
                ],
              ),
            ),
            const SizedBox(width: 16), // Added spacing between columns

            // Action Buttons Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIconButton(
                  icon: Icons.remove_red_eye,
                  color: AppColors.viewButtonColor,
                  tooltip: AppLabels.viewCompanyTooltip,
                  onPressed: () =>
                      sl<Coordinator>().navigateToCompanyDetailsPage(company),
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
                      _showDeleteConfirmation(context, cubit, company),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Utility Methods

// Builds a detailed row with a label and value
  Widget _buildDetailedBox(String label, String? value) {
    final displayValue = sl<CompanyCubit>().validateValue(value); // Validate value using cubit

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
              onTap: (label == AppLabels.emailLabel && value != null && value.trim().isNotEmpty)
                  ? () async {
                await sl<CompanyCubit>().launchUrl("mailto:$value");
              }
                  : (label == AppLabels.contactNumberLabel && value != null && value.trim().isNotEmpty)
                  ? () async {
                await sl<CompanyCubit>().launchUrl("tel:$value");
              }
                  : null,
              child: Text(
                displayValue,
                style: defaultTextStyle(
                  fontSize: 14,
                  color: (label == AppLabels.emailLabel || label == AppLabels.contactNumberLabel)
                      ? Colors.blue
                      : AppColors.textFieldColor,
                  decoration: (label == AppLabels.emailLabel || label == AppLabels.contactNumberLabel)
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

// Builds a reusable icon button with consistent styling
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
}
