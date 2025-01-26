import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/utils/AppColor.dart';
import 'package:requirment_gathering_app/utils/AppLabels.dart';

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
                      return _buildCompanyListTile(context, cubit, company);
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

  Widget _buildCompanyListTile(BuildContext context, CompanyCubit cubit, Company company) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailedBox(AppLabels.companyNameLabel, company.companyName),
                  _buildDetailedBox(AppLabels.addressLabel, company.address ?? AppLabels.noAddress),
                  _buildDetailedBox(AppLabels.emailLabel, company.email ?? AppLabels.noEmail),
                  _buildDetailedBox(AppLabels.contactNumberLabel, company.contactNumber ?? AppLabels.noContactNumber),
                ],
              ),
            ),
            Column(
              children: [
                // View Button
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: AppColors.viewButtonColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                    onPressed: () {
                      sl<Coordinator>().navigateToCompanyDetailsPage(company);
                    },
                    tooltip: AppLabels.viewCompanyTooltip,
                  ),
                ),

                // Edit Button
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: AppColors.editButtonColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      sl<Coordinator>().navigateToEditCompanyPage(company);
                    },
                    tooltip: AppLabels.editCompanyTooltip,
                  ),
                ),

                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.deleteButtonColor,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      _showDeleteConfirmation(context, cubit, company);
                    },
                    tooltip: AppLabels.deleteCompanyTooltip,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAlignedDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, CompanyCubit cubit, Company company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppLabels.deleteConfirmationTitle),
          content: Text("${AppLabels.deleteConfirmationMessage} '${company.companyName}'?"),
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
}
