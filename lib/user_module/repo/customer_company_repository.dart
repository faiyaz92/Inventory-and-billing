import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';
import 'package:dartz/dartz.dart';

abstract class CustomerCompanyRepository {
  Future<Either<Exception, void>> addCompany(Company company); // Accepts a UI Model
  Future<Either<Exception, void>> updateCompany(String id, Company company); // Accepts a UI Model for updates
  Future<Either<Exception, void>> deleteCompany(String id); // Deletes a company by ID
  Future<Either<Exception, Company>> getCompany(String id); // Returns a UI Model by ID
  Future<Either<Exception, List<Company>>> getAllCompanies(); // Returns a list of UI Models

  // New method to check the uniqueness of the company name
  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName);

  Future<Either<Exception, List<Company>>> getFilteredCompanies(
      String? country, String? city, String? businessType);

  Future<Either<Exception, List<Company>>> saveCompaniesBulk(
      List<Company> companies); // Returns a map of successful and failed companies

  Future<List<UserInfoDto>> getUsersFromOwnCompany();
}
