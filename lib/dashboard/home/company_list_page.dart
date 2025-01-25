import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/data/company_ui.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/service_locator/service_locator.dart';

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
              title: const Text("Company List"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () {
                    cubit.sortCompaniesByDate(ascending: true);
                  },
                  tooltip: "Sort Ascending",
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () {
                    cubit.sortCompaniesByDate(ascending: false);
                  },
                  tooltip: "Sort Descending",
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: cubit.searchCompanies,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search companies...",
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
                      "No companies found.",
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

  Widget _buildCompanyListTile(BuildContext context, CompanyCubit cubit, CompanyUi company) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Company Name: ${company.companyName}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Address: ${company.address ?? 'No Address'}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Email: ${company.email ?? 'No Email'}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Contact Number: ${company.contactNumber ?? 'No Contact Number'}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmation(context, cubit, company);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CompanyCubit cubit, CompanyUi company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete the company '${company.companyName}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                cubit.deleteCompany(company.id); // Call delete method
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
