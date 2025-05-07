import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_textfield.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/add_company_state.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';
import 'package:requirment_gathering_app/user_module/presentation/company_list/filter_section.dart';

@RoutePage()
class CompanyListPage extends StatelessWidget {
  const CompanyListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PartnerCubit>()
        ..loadCompanies()
        ..filterByCompanyType("Site"),
      child: BlocBuilder<PartnerCubit, CompanyState>(
        buildWhen: (previous, current) =>
            current is LoadingState ||
            current is CompaniesLoadedState ||
            current is CompaniesFilteredState ||
            current is CompaniesSortedState ||
            current is CompanyDeletedState ||
            current is FilterToggledState ||
            current is CompanyDataState,
        builder: (context, state) {
          final cubit = context.read<PartnerCubit>();
          List<Partner> companies = [];
          List<Partner> originalCompanies = [];
          bool isFilterVisible = false;
          CompanySettingsUi? settings;
          Partner? currentCompany;

          if (state is CompaniesLoadedState) {
            companies = state.companies;
            originalCompanies = state.originalCompanies;
          } else if (state is CompaniesFilteredState) {
            companies = state.companies;
            originalCompanies = state.originalCompanies;
          } else if (state is CompaniesSortedState) {
            companies = state.companies;
            originalCompanies = state.originalCompanies;
          } else if (state is CompanyDeletedState) {
            companies = state.companies;
            originalCompanies = state.originalCompanies;
          } else if (state is FilterToggledState) {
            companies = state.companies;
            originalCompanies = state.originalCompanies;
            isFilterVisible = state.isFilterVisible;
          } else if (state is CompanyDataState) {
            settings = state.settings;
            currentCompany = state.company;
            isFilterVisible = state.isFilterVisible;
          }

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  expandedHeight: isFilterVisible ? 436 + 68 : 76,
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
                                  child: CustomTextField(
                                    labelText: AppLabels.searchHint,
                                    hintText: AppLabels.searchHint,
                                    prefixIcon: const Icon(Icons.search),
                                    textInputAction: TextInputAction.search,
                                    onChanged: cubit.searchCompanies,
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
                                onPressed: () => cubit.clearFilters(),
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
                          if (isFilterVisible)
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
                                  cubit.updateRepliedTo(value);
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
                                countries:
                                    settings?.countryCityMap.keys.toList() ??
                                        [],
                                cities: cubit.getCitiesForCountry(
                                    currentCompany?.country),
                                interestLevels: List.generate(
                                    11, (index) => '${index * 10}%'),
                                priorities: settings?.priorities ?? [],
                                sources: settings?.sources ?? [],
                                company: currentCompany,
                                onBusinessTypeSelected: (value) {
                                  cubit.updateBusinessType(value);
                                  cubit.applyGeneralFilters();
                                },
                                businessTypes: settings?.businessTypes ?? [],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    companyCount: companies.length,
                    totalCompanyCount: originalCompanies.length,
                  ),
                ),
                if (state is LoadingState)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (companies.isEmpty)
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
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final company = companies[index];
                        return _buildCompanyListTile(context, cubit, company);
                      },
                      childCount: companies.length,
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
      BuildContext context, PartnerCubit cubit, Partner company) {
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
    final displayValue = sl<PartnerCubit>().validateValue(value);

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
                      await sl<PartnerCubit>().launchUrl("mailto:$value");
                    }
                  : (label == AppLabels.contactNumberLabel &&
                          value != null &&
                          value.trim().isNotEmpty)
                      ? () async {
                          await sl<PartnerCubit>().launchUrl("tel:$value");
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
      BuildContext context, PartnerCubit cubit, Partner company) {
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
                cubit.deleteCompany(company.id!);
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
  double get minExtent => 25;

  @override
  double get maxExtent => 25;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.blue,
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
    return true;
  }
}
