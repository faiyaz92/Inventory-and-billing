import 'package:requirment_gathering_app/data/company_ui.dart';

abstract class CompanyRepository {
  Future<void> addCompany(CompanyUi company); // Accepts a UI Model
  Future<void> updateCompany(String id, CompanyUi company); // Accepts a UI Model for updates
  Future<void> deleteCompany(String id); // Deletes a company by ID
  Future<CompanyUi> getCompany(String id); // Returns a UI Model by ID
  Future<List<CompanyUi>> getAllCompanies(); // Returns a list of UI Models

  // New method to check the uniqueness of the company name
  Future<bool> isCompanyNameUnique(String companyName);
}
