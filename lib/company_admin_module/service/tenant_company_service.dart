import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

abstract class CompanyOperationsService {
  Future<void> addUserToCompany(UserInfo userInfo, String password); // ✅ Added method
  Future<List<UserInfo>> getUsersFromTenantCompany();
  Future<void> deleteUser(String userId);
}
