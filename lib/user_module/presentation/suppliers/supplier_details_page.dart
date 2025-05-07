import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/square_box_rounded_corner.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/presentation/add_company/customer_company_cubit.dart';

@RoutePage()
class SupplierDetailsPage extends StatelessWidget {
  final Partner company;

  const SupplierDetailsPage({Key? key, required this.company})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Supplier Details",
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              sl<Coordinator>().navigateToEditCompanyPage(company);
            },
            tooltip: "Edit Supplier",
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              sl<Coordinator>().navigateToAccountLedgerPage(company: company);
            },
            tooltip: "Go to Ledger",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow("Supplier Name", company.companyName),
            _buildDetailRow("Address", company.address),
            _buildClickableDetailRow("Email", company.email),
            _buildClickableDetailRow("Contact Number", company.contactNumber),
            _buildDetailRow("Source", company.source),
            _buildInterestLevelRow("Interest Level", company.interestLevel),
            _buildDetailRow("Country", company.country),
            _buildDetailRow("City", company.city),
            _buildDetailRow("Priority", company.priority),
            _buildRepliedRow("They Replied", company.theyReplied),
            _buildEmailSentRow("Email Sent", company.emailSent),
            _buildDetailRow("Assigned To", company.assignedTo),
            _buildClickableDetailRow("Website", company.websiteLink),
            _buildClickableDetailRow("LinkedIn", company.linkedInLink),
            _buildClickableDetailRow("Clutch", company.clutchLink),
            _buildClickableDetailRow("GoodFirm", company.goodFirmLink),
            _buildDetailRow("Description", company.description),
            _buildVerifiedOnRow("Verified On", company.verifiedOn),
            _buildDetailRow("Created By", company.createdBy),
            _buildDetailRow("Last Updated By", company.lastUpdatedBy),
            const SizedBox(height: 16),
            const Text(
              "Contact Person",
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
                // Handle URL launch
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
            "Name:",
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
            "Email:",
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
                // Handle email
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
            "Phone:",
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
                // Handle phone
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
                    Text("Not Available", style: defaultTextStyle(fontSize: 14))
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
              text: interestLevel ?? "Not Available",
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
              text: replied ? "Yes" : "No",
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
              text: emailSent ? "Yes" : "No",
              backgroundColor: color,
            ),
          ),
        ],
      ),
    );
  }
}
