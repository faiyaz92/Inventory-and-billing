import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/dashboard/home/add_company_state.dart';
import 'package:requirment_gathering_app/dashboard/home/company_cubit.dart';
import 'package:requirment_gathering_app/dashboard/home/filter_section.dart';
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
      create: (_) => sl<CompanyCubit>()
        ..loadCompanySettings()
        ..loadCompanies(),
      child: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          final cubit = context.read<CompanyCubit>();

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // Collapsible Filter Section
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  expandedHeight: state.isFilterVisible ? 436 : 76,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: TextField(
                                    onChanged: cubit.searchCompanies,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: AppLabels.searchHint,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        borderSide: const BorderSide(
                                            color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_alt,
                                    color: Colors.blue),
                                tooltip: AppLabels.filterTooltip,
                                onPressed: () => cubit.toggleFilterVisibility(),
                              ),
                              TextButton(
                                onPressed: () {
                                  cubit.clearFilters();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          if (state.isFilterVisible)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FiltersSection(
                                onCountrySelected: (value) {
                                  cubit.updateCountry(value);
                                  cubit.applyGeneralFilters();
                                },
                                onCitySelected: (value) {
                                  cubit.updateCity(value);
                                  cubit.applyGeneralFilters();
                                },
                                onInterestLevelSelected: (value) {
                                  cubit.updateInterestLevel(value);
                                  cubit.applyGeneralFilters();
                                },
                                onEmailSentSelected: (value) {
                                  cubit.updateEmailSent(value);
                                  cubit.applyGeneralFilters();
                                },
                                onEmailRepliedSelected: (value) {
                                  cubit.updateEmailReplied(value);
                                  cubit.applyGeneralFilters();
                                },
                                onPrioritySelected: (value) {
                                  cubit.updatePriority(value);
                                  cubit.applyGeneralFilters();
                                },
                                onSourceSelected: (value) {
                                  cubit.updateSource(value);
                                  cubit.applyGeneralFilters();
                                },
                                onSortSelected: (value) {
                                  cubit.sortCompaniesBy(value);
                                },
                                onClearFilters: cubit.clearFilters,
                                countries: state
                                        .company?.settings?.countryCityMap.keys
                                        .toList() ??
                                    [],
                                cities: cubit.getCitiesForCountry(
                                    state.company?.country),
                                interestLevels: [
                                  '0-20',
                                  '21-40',
                                  '41-60',
                                  '61-80',
                                  '81-100'
                                ],
                                priorities:
                                    state.company?.settings?.priorities ?? [],
                                sources: state.company?.settings?.sources ?? [],
                                company: state.company,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky Company Count
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    companyCount: state.companies.length,
                    totalCompanyCount:state.originalCompanies.length,
                  ),
                ),

                // Loading or Empty State
                if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.companies.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        AppLabels.noCompaniesFound,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                else
                  // Company List Section
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final company = state.companies[index];
                        return _buildCompanyListTile(context, cubit, company);
                      },
                      childCount: state.companies.length,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompanyListTile(
      BuildContext context, CompanyCubit cubit, Company company) {
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
                          _showDeleteConfirmation(context, cubit, company),
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
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int companyCount;
  final int totalCompanyCount;

  _StickyHeaderDelegate({
    required this.companyCount,
    required this.totalCompanyCount,
  });

  @override
  double get minExtent => 25; // Minimum height of the sticky header
  @override
  double get maxExtent => 25; // Maximum height

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.blue, // Background color
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        'Total Companies: $companyCount/$totalCompanyCount',
        style: const TextStyle(
            fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Ensures updates when company count changes
  }
}
