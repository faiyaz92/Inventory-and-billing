import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';

abstract class CustomerCompanyService {
  Future<Either<Exception, List<Company>>> fetchCompanies();

  Future<Either<Exception, void>> saveCompany(Company company);

  Future<Either<Exception, CompanySettingsUi>> fetchCompanySettings();

  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName);

  Future<void> addCompany(Company company);

  Future<void> updateCompany(String id, Company company);

  Future<Either<Exception, List<Company>>> getAllCompanies();

  Future<void> deleteCompany(String id);

  Future<Either<Exception, CompanySettingsUi>> getSettings();

  Future<Either<Exception, void>> updateSettings(CompanySettingsUi settings);
  Future<List<UserInfoDto>> getUsersFromOwnCompany();
}
