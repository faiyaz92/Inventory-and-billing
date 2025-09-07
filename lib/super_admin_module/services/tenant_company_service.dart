import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';

abstract class TenantCompanyService {
  Future<void> createTenantCompany(
      TenantCompany company,
      String password, {
        required String adminUsername,
        required String adminName,
      });
  Future<void> updateTenantCompany(TenantCompany company);
  Future<void> addSuperAdmin();
  Future<List<TenantCompany>> getTenantCompanies();
  Future<TenantCompany?> getTenantCompanyById(String companyId);
}