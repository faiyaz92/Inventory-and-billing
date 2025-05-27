import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart' show UserServices;
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';

class UserServiceImpl implements UserServices {
  final ITenantCompanyRepository _tenantCompanyRepository;
  final AccountRepository _accountRepository;

  UserServiceImpl(this._tenantCompanyRepository, this._accountRepository);

  @override
  Future<void> addUserToCompany(UserInfo userInfo, String password) async {
    final loggedInUserInfo = await _accountRepository.getUserInfo();
    userInfo = userInfo.copyWith(
      companyId: loggedInUserInfo?.companyId ?? '',
      latitude: userInfo.latitude ?? 0.0,
      longitude: userInfo.longitude ?? 0.0,
      dailyWage: userInfo.dailyWage ?? 500.0,
    );
    await _tenantCompanyRepository.addUserToCompany(userInfo.toDto(), password);
  }

  @override
  Future<void> updateUser(UserInfo userInfo) async {
    final loggedInUserInfo = await _accountRepository.getUserInfo();
    final companyId = loggedInUserInfo?.companyId ?? '';
    if (userInfo.userId == null || userInfo.userId!.isEmpty) {
      throw Exception("User ID is missing. Cannot update user.");
    }

    // Fetch existing user data from repository
    final existingUser = await _tenantCompanyRepository.getUser(userInfo.userId!, companyId);
    if (existingUser == null) {
      throw Exception("User does not exist.");
    }

    // Merge provided userInfo with existing data
    final updatedUserInfo = UserInfoDto(
      userId: userInfo.userId ?? existingUser.userId,
      companyId: existingUser.companyId, // Preserve existing companyId
      name: userInfo.name ?? existingUser.name,
      email: userInfo.email ?? existingUser.email,
      userName: userInfo.userName ?? existingUser.userName,
      role: userInfo.role ?? existingUser.role,
      latitude: userInfo.latitude ?? existingUser.latitude,
      longitude: userInfo.longitude ?? existingUser.longitude,
      dailyWage: userInfo.dailyWage ?? existingUser.dailyWage,
    );

    await _tenantCompanyRepository.updateUser(
      userInfo.userId!,
      companyId,
      updatedUserInfo,
    );
  }

  @override
  Future<void> updateUserLocation(double latitude, double longitude) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    final updatedUserInfo = UserInfo(
      userId: userInfo?.userId,
      latitude: latitude,
      longitude: longitude,
      companyId: companyId,
    );
    await _tenantCompanyRepository.updateUserLocation(
      userInfo?.userId ?? '',
      companyId,
      updatedUserInfo.toDto(),
    );
  }

  @override
  Future<List<UserInfo>> getUsersFromTenantCompany() async {
    final userInfo = await _accountRepository.getUserInfo();
    final userDtos = await _tenantCompanyRepository.getUsersFromTenantCompany(userInfo?.companyId ?? '');
    return userDtos.map((dto) => UserInfo.fromDto(dto)).toList();
  }

  @override
  Future<void> deleteUser(String userId) async {
    final userInfo = await _accountRepository.getUserInfo();
    await _tenantCompanyRepository.deleteUser(userId, userInfo?.companyId ?? '');
  }

  @override
  Future<void> markAttendance(String userId, AttendanceModel attendance) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    final dateTime = DateFormat('dd-MM-yyyy').parse(attendance.date);
    final dto = AttendanceDTO(
      date: DateFormat('yyyy-MM-dd').format(dateTime),
      status: attendance.status,
      year: DateFormat('yyyy').format(dateTime),
      month: DateFormat('MM').format(dateTime),
      day: DateFormat('dd').format(dateTime),
    );
    await _tenantCompanyRepository.markAttendance(userId, companyId, dto);
  }

  @override
  Future<List<AttendanceModel>> getAttendance(String userId, String month) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    final attendanceDTOs = await _tenantCompanyRepository.getAttendance(userId, companyId, month);
    return attendanceDTOs.map((dto) {
      return AttendanceModel(
        date: DateFormat('dd-MM-yyyy').format(DateTime.parse(dto.date)),
        status: dto.status,
      );
    }).toList();
  }

  @override
  Future<void> recordSalaryPayment(String userId, double amount, String month) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    await _tenantCompanyRepository.recordSalaryPayment(userId, companyId, amount, month);
  }

  @override
  Future<void> recordAdvanceSalary(String userId, double amount, String date) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    await _tenantCompanyRepository.recordAdvanceSalary(userId, companyId, amount, date);
  }

  @override
  Future<List<Map<String, dynamic>>> getLedger(String userId, String? month) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    return await _tenantCompanyRepository.getLedger(userId, companyId, month);
  }

  @override
  Future<double> getPayableSalary(String userId) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    final salaryHistory = await _tenantCompanyRepository.getSalaryHistory(userId, companyId);
    double unpaidTotal = salaryHistory.where((h) => !(h['paid'] as bool)).fold(0.0, (sum, h) => sum + (h['totalEarned'] as double));

    final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
    final attendance = await getAttendance(userId, currentMonth);
    final user = (await getUsersFromTenantCompany()).firstWhere((u) => u.userId == userId);
    final dailyWage = user.dailyWage ?? 500.0;
    int presentDays = attendance.where((a) => a.status == 'present').length;
    int halfDays = attendance.where((a) => a.status == 'half_day').length;
    double currentMonthSalary = (presentDays * dailyWage) + (halfDays * dailyWage / 2);

    return unpaidTotal + currentMonthSalary;
  }

  @override
  Future<double> getAdvanceBalance(String userId) async {
    final ledger = await getLedger(userId, null);
    double totalAdvances = ledger.where((e) => e['type'] == 'advance').fold(0.0, (sum, e) => sum + (e['amount'] as double));
    final userInfo = await _accountRepository.getUserInfo();
    final salaryHistory = await _tenantCompanyRepository.getSalaryHistory(userId, userInfo?.companyId ?? '');
    double totalEarned = salaryHistory.fold(0.0, (sum, h) => sum + (h['totalEarned'] as double));
    return totalAdvances - totalEarned > 0 ? totalAdvances - totalEarned : 0.0;
  }

  @override
  Future<void> finalizeMonth(String userId, String month) async {
    final userInfo = await _accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    await _tenantCompanyRepository.finalizeMonth(userId, companyId, month);
  }
}