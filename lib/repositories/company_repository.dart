import 'package:requirment_gathering_app/data/company.dart';

abstract class CompanyRepository {
  Future<void> addCompany(Company company); // Accepts a UI Model
  Future<void> updateCompany(String id, Company company); // Accepts a UI Model for updates
  Future<void> deleteCompany(String id); // Deletes a company by ID
  Future<Company> getCompany(String id); // Returns a UI Model by ID
  Future<List<Company>> getAllCompanies(); // Returns a list of UI Models

  // New method to check the uniqueness of the company name
  Future<bool> isCompanyNameUnique(String companyName);
}