import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';

abstract class ITenantCompanyRepository {
  Future<String> generateTenantCompanyId(String companyName);

  Future<void> createTenantCompany(
    TenantCompanyDto dto,
    String password, {
    required String adminUsername,
    required String adminName,
  });

  Future<String> addUserToCompany(UserInfoDto userInfoDto, String password);

  Future<void> updateUser(
      String userId, String companyId, UserInfoDto userInfoDto);

  Future<UserInfoDto?> getUser(String userId, String companyId);

  Future<List<TenantCompanyDto>> getTenantCompanies();

  Future<void> updateTenantCompany(TenantCompanyDto updatedDto);

  Future<void> deleteTenantCompany(String companyId);

  Future<void> addSuperAdmin();

  Future<List<UserInfoDto>> getUsersFromTenantCompany(String companyId,
      {String? storeId});

  Future<void> deleteUser(String userId, String companyId);

  Future<void> updateUserLocation(
      String userId, String companyId, UserInfoDto userInfoDto);

  Future<void> markAttendance(
      String userId, String companyId, AttendanceDTO attendance);

  Future<List<AttendanceDTO>> getAttendance(
      String userId, String companyId, String month);

  Future<void> recordSalaryPayment(
      String userId, String companyId, double amount, String month);

  Future<void> recordAdvanceSalary(
      String userId, String companyId, double amount, String date);

  Future<List<Map<String, dynamic>>> getLedger(
      String userId, String companyId, String? month);

  Future<List<Map<String, dynamic>>> getSalaryHistory(
      String userId, String companyId);

  Future<void> finalizeMonth(String userId, String companyId, String month);
}
