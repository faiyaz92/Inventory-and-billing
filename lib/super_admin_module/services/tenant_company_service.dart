
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';

abstract class TenantCompanyService {
  Future<void> createTenantCompany(TenantCompany company, String password);
  Future<void> updateTenantCompany(TenantCompany company); // ✅ Added Update Method
  Future<void> addSuperAdmin();
}
