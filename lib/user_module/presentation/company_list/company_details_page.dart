import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/square_box_rounded_corner.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class CompanyDetailsPage extends StatelessWidget {
  final Partner company;

  const CompanyDetailsPage({Key? key, required this.company}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppLabels.companyListTitle,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              sl<Coordinator>().navigateToEditCompanyPage(company);
            },
            tooltip: AppLabels.editCompanyTooltip,
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return IconButton(
                icon: Icon(
                  company.accountLedgerId == null ||
                          company.accountLedgerId!.isEmpty
                      ? Icons.add // Create Ledger Icon
                      : Icons.receipt_long, // Go to Ledger Icon
                ),
                onPressed: () async {
                  if (company.accountLedgerId == null ||
                      company.accountLedgerId!.isEmpty) {
                    // 🔥 Ledger Create Karna
                    final newLedgerId =
                        await _createAccountLedger(context, company);
                    setState(() {
                      company.copyWith(accountLedgerId: newLedgerId);
                    });
                  } else {
                    // 🔥 Ledger Page Pe Jaana
                    _goToAccountLedger(context, company);
                  }
                },
                tooltip: company.accountLedgerId == null ||
                        company.accountLedgerId!.isEmpty
                    ? "Create Ledger"
                    : "Go to Ledger",
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow(AppLabels.companyNameLabel, company.companyName),
            _buildDetailRow(AppLabels.addressLabel, company.address),
            _buildClickableDetailRow(AppLabels.emailLabel, company.email),
            _buildClickableDetailRow(
                AppLabels.contactNumberLabel, company.contactNumber),
            _buildDetailRow(AppLabels.sourceLabel, company.source),
            _buildInterestLevelRow(
                AppLabels.interestLevelLabel, company.interestLevel),
            _buildDetailRow(AppLabels.countryLabel, company.country),
            _buildDetailRow(AppLabels.cityLabel, company.city),
            _buildDetailRow(AppLabels.priorityLabel, company.priority),
            _buildRepliedRow(AppLabels.theyRepliedLabel, company.theyReplied),
            _buildEmailSentRow(AppLabels.emailSentLabel, company.emailSent),
            _buildDetailRow(AppLabels.assignedToLabel, company.assignedTo),
            _buildClickableDetailRow(
                AppLabels.websiteLinkLabel, company.websiteLink),
            _buildClickableDetailRow(
                AppLabels.linkedInLinkLabel, company.linkedInLink),
            _buildClickableDetailRow(
                AppLabels.clutchLinkLabel, company.clutchLink),
            _buildClickableDetailRow(
                AppLabels.goodFirmLinkLabel, company.goodFirmLink),
            _buildDetailRow(AppLabels.descriptionLabel, company.description),
            _buildVerifiedOnRow(AppLabels.verifiedOnLabel, company.verifiedOn),
            _buildDetailRow(AppLabels.createdByLabel, company.createdBy),
            _buildDetailRow(
                AppLabels.lastUpdatedByLabel, company.lastUpdatedBy),
            const SizedBox(height: 16),
            const Text(
              AppLabels.contactPersonLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...company.contactPersons
                .map((person) => _buildContactPersonRow(person))
                .toList(),
          ],
        ),
      ),
    );
  }

  Future<String> _createAccountLedger(
      BuildContext context, Partner company) async {
    final ledgerCubit = sl<AccountLedgerCubit>();

    try {
      await ledgerCubit.createLedger(
        company,
        0.0, // Initial outstanding balance
        null,
        null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account Ledger Created Successfully!")));

      return "GENERATED_LEDGER_ID"; // 🔥 Return the newly created ledger ID
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create Account Ledger: $e")));
      return "";
    }
  }

  void _goToAccountLedger(BuildContext context, Partner company) {
    sl<Coordinator>().navigateToAccountLedgerPage(company: company);
  }

  Widget _buildDetailRow(String label, String? value) {
    final displayValue = sl<PartnerCubit>().validateValue(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            child: Text(
              displayValue,
              style: defaultTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textFieldColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableDetailRow(String label, String? value) {
    final displayValue = sl<PartnerCubit>().validateValue(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              onTap: () async {
                // await sl<CompanyCubit>().launchUrl(displayValue);
              },
              child: Text(
                displayValue,
                style: defaultTextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPersonRow(ContactPerson person) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${AppLabels.contactPersonNameLabel}:",
            style: defaultTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.labelColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              person.name,
              style: defaultTextStyle(
                fontSize: 14,
                color: AppColors.textFieldColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${AppLabels.contactPersonEmailLabel}:",
            style: defaultTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.labelColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () async {
                // await sl<CompanyCubit>().launchUrl("mailto:${person.email}");
              },
              child: Text(
                person.email,
                style: defaultTextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${AppLabels.contactPersonPhoneLabel}:",
            style: defaultTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.labelColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () async {
                // await sl<CompanyCubit>().launchUrl("tel:${person.phoneNumber}");
              },
              child: Text(
                person.phoneNumber,
                style: defaultTextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedOnRow(String label, List<String> platforms) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: defaultTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.labelColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: platforms.isNotEmpty
                ? platforms.map((platform) {
                    return Chip(
                      label: Text(
                        platform,
                        style: defaultTextStyle(
                          fontSize: 14,
                          color: AppColors.textFieldColor,
                        ),
                      ),
                      backgroundColor: Colors.grey[300],
                    );
                  }).toList()
                : [
                    Text(AppLabels.notAvailable,
                        style: defaultTextStyle(fontSize: 14))
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestLevelRow(String label, String? interestLevel) {
    final color = sl<PartnerCubit>().getInterestLevelColor(interestLevel);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: StatusSquare(
              text: interestLevel ?? AppLabels.notAvailable,
              backgroundColor: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepliedRow(String label, bool replied) {
    final color = sl<PartnerCubit>().getRepliedColor(replied);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: StatusSquare(
              text: replied
                  ? AppLabels.emailSentYesLabel
                  : AppLabels.emailSentNoLabel,
              backgroundColor: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentRow(String label, bool emailSent) {
    final color = sl<PartnerCubit>().getEmailSentColor(emailSent);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: StatusSquare(
              text: emailSent
                  ? AppLabels.emailSentYesLabel
                  : AppLabels.emailSentNoLabel,
              backgroundColor: color,
            ),
          ),
        ],
      ),
    );
  }

  void launchDialer(String phoneNumber) async {
    final telUri = "tel:$phoneNumber";

    if (await canLaunch(telUri)) {
      await launch(telUri);
    } else {
      print("Could not launch dialer for $phoneNumber");
    }
  }
}
