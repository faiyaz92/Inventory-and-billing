
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';

abstract class ITenantCompanyRepository {
  /// 🔹 Create a new tenant company with the given details.
  Future<void> createTenantCompany(TenantCompanyDto dto, String password);

  /// 🔹 Generate a unique company ID based on the company name.
  Future<String> generateTenantCompanyId(String companyName);

  /// 🔹 Fetch all tenant companies from Firestore.
  Future<List<TenantCompanyDto>> getTenantCompanies();

  /// 🔹 Update an existing tenant company.
  Future<void> updateTenantCompany( TenantCompanyDto updatedDto);

  /// 🔹 Delete a tenant company.
  Future<void> deleteTenantCompany(String companyId);

  /// 🔹 Allow a company admin to add a user to their company.
  Future<void> addUserToCompany(UserInfoDto userInfoDto, String password);
  Future<void> addSuperAdmin();
  Future<List<UserInfoDto>> getUsersFromTenantCompany(String companyId);
  Future<void> deleteUser(String companyId,String userId);
}
