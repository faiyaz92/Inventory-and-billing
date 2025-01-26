import 'package:flutter/material.dart';
import 'package:requirment_gathering_app/data/company.dart';

class CompanyDetailsPage extends StatelessWidget {
  final Company company;

  const CompanyDetailsPage({Key? key, required this.company}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to AddCompanyPage for editing
              // sl<Coordinator>().navigateToEditCompanyPage(company);
            },
            tooltip: "Edit Company",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow("Company Name", company.companyName),
            _buildDetailRow("Address", company.address ?? "No Address"),
            _buildDetailRow("Email", company.email ?? "No Email"),
            _buildDetailRow("Contact Number", company.contactNumber ?? "No Contact Number"),
            _buildDetailRow("Source", company.source ?? "No Source"),
            _buildDetailRow("Interest Level", company.interestLevel ?? "No Interest Level"),
            _buildDetailRow("Country", company.country ?? "No Country"),
            _buildDetailRow("City", company.city ?? "No City"),
            _buildDetailRow("Priority", company.priority ?? "No Priority"),
            _buildDetailRow("Assigned To", company.assignedTo ?? "Not Assigned"),
            _buildDetailRow("Website Link", company.websiteLink ?? "No Website Link"),
            _buildDetailRow("LinkedIn Link", company.linkedInLink ?? "No LinkedIn Link"),
            _buildDetailRow("Clutch Link", company.clutchLink ?? "No Clutch Link"),
            _buildDetailRow("GoodFirm Link", company.goodFirmLink ?? "No GoodFirm Link"),
            const SizedBox(height: 16),
            const Text(
              "Contact Persons:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...company.contactPersons.map((person) => _buildContactPersonRow(person)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
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
            "Name: ${person.name}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text("Email: ${person.email}", style: const TextStyle(fontSize: 16)),
          Text("Phone: ${person.phoneNumber}", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
