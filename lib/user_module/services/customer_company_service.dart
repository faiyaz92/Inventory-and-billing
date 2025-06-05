import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';

abstract class CustomerCompanyService {
  Future<Either<Exception, List<Partner>>> fetchCompanies();
  // Future<Either<Exception, void>> saveCompany(Partner company);
  Future<Either<Exception, CompanySettingsUi>> fetchCompanySettings();
  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName);
  Future<String> addCompany(Partner company);
  Future<void> updateCompany(String id, Partner company);
  Future<Either<Exception, List<Partner>>> getAllCompanies();
  Future<void> deleteCompany(String id);
  Future<Either<Exception, CompanySettingsUi>> getSettings();
  Future<Either<Exception, void>> updateSettings(CompanySettingsUi settings);
  Future<List<UserInfoDto>> getUsersFromOwnCompany();
}