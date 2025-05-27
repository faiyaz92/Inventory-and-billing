import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

abstract class UserServices {
  Future<void> addUserToCompany(UserInfo userInfo, String password);
  Future<void> updateUser(UserInfo userInfo);
  Future<List<UserInfo>> getUsersFromTenantCompany();
  Future<void> deleteUser(String userId);
  Future<void> updateUserLocation(double latitude, double longitude);
  Future<void> markAttendance(String userId, AttendanceModel attendance);
  Future<List<AttendanceModel>> getAttendance(String userId, String month);
  Future<void> recordSalaryPayment(String userId, double amount, String month);
  Future<void> recordAdvanceSalary(String userId, double amount, String date);
  Future<List<Map<String, dynamic>>> getLedger(String userId, String? month);
  Future<double> getPayableSalary(String userId);
  Future<double> getAdvanceBalance(String userId);
  Future<void> finalizeMonth(String userId, String month);
}