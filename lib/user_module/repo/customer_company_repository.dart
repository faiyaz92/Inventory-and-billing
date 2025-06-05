import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/partner_dto.dart';

abstract class CustomerCompanyRepository {
  Future<Either<Exception, String>> addCompany(PartnerDto company);
  Future<Either<Exception, String>> updateCompany(String id, PartnerDto company);
  Future<Either<Exception, void>> deleteCompany(String id);
  Future<Either<Exception, PartnerDto>> getCompany(String id);
  Future<Either<Exception, List<PartnerDto>>> getAllCompanies();
  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName);
  Future<Either<Exception, List<PartnerDto>>> getFilteredCompanies(
      String? country, String? city, String? businessType);
  Future<Either<Exception, List<PartnerDto>>> saveCompaniesBulk(List<PartnerDto> companies);
  Future<Either<Exception, List<UserInfoDto>>> getUsersFromOwnCompany();
}