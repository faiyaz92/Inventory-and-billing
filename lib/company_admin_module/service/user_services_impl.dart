import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart'
    show UserServices;
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class UserServiceImpl implements UserServices {
  final ITenantCompanyRepository _tenantCompanyRepository;
  final AccountRepository _accountRepository;
  final IAccountLedgerService _accountLedgerService;

  UserServiceImpl(this._tenantCompanyRepository, this._accountRepository,
      this._accountLedgerService);

  @override
  Future<UserInfo?> addUserToCompany(UserInfo userInfo, String password) async {
    try {
      final loggedInUserInfo = await _accountRepository.getUserInfo();

      final ledgerId = await _accountLedgerService.createLedger(AccountLedger(
        totalOutstanding: 0,
        promiseAmount: null,
        promiseDate: null,
        transactions: [],
        entityType: userInfo.userType,
      ));

      final updatedUserInfo = userInfo.copyWith(
        companyId: loggedInUserInfo?.companyId ?? '',
        latitude: userInfo.latitude ?? 0.0,
        longitude: userInfo.longitude ?? 0.0,
        dailyWage: userInfo.dailyWage ?? 500.0,
        storeId: userInfo.storeId,
        userType: userInfo.userType ?? UserType.Customer,
        accountLedgerId: ledgerId??''// Default to Customer
      );
      print(
          'UserServiceImpl addUserToCompany: userType = ${updatedUserInfo.userType?.name ?? "null"}');
      final json = updatedUserInfo.toJson();

     final userId = await _tenantCompanyRepository.addUserToCompany(
          updatedUserInfo.toDto(), password);
       return updatedUserInfo.copyWith(userId: userId);
    } catch (e) {
      print('UserServiceImpl addUserToCompany error: $e');
      throw Exception('Failed to add user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(UserInfo userInfo) async {
    try {
      final loggedInUserInfo = await _accountRepository.getUserInfo();
      final companyId = loggedInUserInfo?.companyId ?? '';
      if (userInfo.userId == null || userInfo.userId!.isEmpty) {
        throw Exception("User ID is missing. Cannot update user.");
      }

      // Fetch existing user data from repository
      final existingUser =
          await _tenantCompanyRepository.getUser(userInfo.userId!, companyId);
      if (existingUser == null) {
        throw Exception("User does not exist.");
      }

      // Merge provided userInfo with existing data
      final updatedUserInfo = UserInfoDto(
        userId: userInfo.userId ?? existingUser.userId,
        companyId: existingUser.companyId,
        name: userInfo.name ?? existingUser.name,
        email: userInfo.email ?? existingUser.email,
        userName: userInfo.userName ?? existingUser.userName,
        role: userInfo.role ?? existingUser.role,
        userType:
            userInfo.userType ?? existingUser.userType ?? UserType.Customer,
        // Default to Customer
        latitude: userInfo.latitude ?? existingUser.latitude,
        longitude: userInfo.longitude ?? existingUser.longitude,
        dailyWage: userInfo.dailyWage ?? existingUser.dailyWage,
        storeId: userInfo.storeId ?? existingUser.storeId,
        accountLedgerId:
            userInfo.accountLedgerId ?? existingUser.accountLedgerId,
      );

      print(
          'UserServiceImpl updateUser: userType = ${updatedUserInfo.userType?.name ?? "null"}');
      final json = updatedUserInfo.toMap();
      print('UserServiceImpl updateUser: Sending to Firestore = $json');

      await _tenantCompanyRepository.updateUser(
        userInfo.userId!,
        companyId,
        updatedUserInfo,
      );
    } catch (e) {
      print('UserServiceImpl updateUser error: $e');
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserLocation(double latitude, double longitude) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      final updatedUserInfo = UserInfo(
        userId: userInfo?.userId,
        latitude: latitude,
        longitude: longitude,
        companyId: companyId,
        userType: userInfo?.userType ??
            UserType.Customer, // Preserve or default to Customer
      );
      print(
          'UserServiceImpl updateUserLocation: userType = ${updatedUserInfo.userType?.name ?? "null"}');
      await _tenantCompanyRepository.updateUserLocation(
        userInfo?.userId ?? '',
        companyId,
        updatedUserInfo.toDto(),
      );
    } catch (e) {
      print('UserServiceImpl updateUserLocation error: $e');
      throw Exception('Failed to update user location: ${e.toString()}');
    }
  }

  @override
  Future<List<UserInfo>> getUsersFromTenantCompany({String? storeId}) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final userDtos = await _tenantCompanyRepository.getUsersFromTenantCompany(
          userInfo?.companyId ?? '',
          storeId: storeId);
      final users = userDtos.map((dto) {
        final user = UserInfo.fromDto(dto);
        print(
            'UserServiceImpl getUsersFromTenantCompany: userId = ${user.userId}, userType = ${user.userType?.name ?? "null"}');
        return user;
      }).toList();
      return users;
    } catch (e) {
      print('UserServiceImpl getUsersFromTenantCompany error: $e');
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      await _tenantCompanyRepository.deleteUser(
          userId, userInfo?.companyId ?? '');
    } catch (e) {
      print('UserServiceImpl deleteUser error: $e');
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<void> markAttendance(String userId, AttendanceModel attendance) async {
    try {
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
    } catch (e) {
      print('UserServiceImpl markAttendance error: $e');
      throw Exception('Failed to mark attendance: ${e.toString()}');
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendance(
      String userId, String month) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      final attendanceDTOs = await _tenantCompanyRepository.getAttendance(
          userId, companyId, month);
      return attendanceDTOs.map((dto) {
        return AttendanceModel(
          date: DateFormat('dd-MM-yyyy').format(DateTime.parse(dto.date)),
          status: dto.status,
        );
      }).toList();
    } catch (e) {
      print('UserServiceImpl getAttendance error: $e');
      throw Exception('Failed to fetch attendance: ${e.toString()}');
    }
  }

  @override
  Future<void> recordSalaryPayment(
      String userId, double amount, String month) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      await _tenantCompanyRepository.recordSalaryPayment(
          userId, companyId, amount, month);
    } catch (e) {
      print('UserServiceImpl recordSalaryPayment error: $e');
      throw Exception('Failed to record salary payment: ${e.toString()}');
    }
  }

  @override
  Future<void> recordAdvanceSalary(
      String userId, double amount, String date) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      await _tenantCompanyRepository.recordAdvanceSalary(
          userId, companyId, amount, date);
    } catch (e) {
      print('UserServiceImpl recordAdvanceSalary error: $e');
      throw Exception('Failed to record advance salary: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLedger(
      String userId, String? month) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      return await _tenantCompanyRepository.getLedger(userId, companyId, month);
    } catch (e) {
      print('UserServiceImpl getLedger error: $e');
      throw Exception('Failed to fetch ledger: ${e.toString()}');
    }
  }

  @override
  Future<double> getPayableSalary(String userId) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      final salaryHistory =
          await _tenantCompanyRepository.getSalaryHistory(userId, companyId);
      double unpaidTotal = salaryHistory
          .where((h) => !(h['paid'] as bool))
          .fold(0.0, (sum, h) => sum + (h['totalEarned'] as double));

      final currentMonth = DateTime.now().toIso8601String().substring(0, 7);
      final attendance = await getAttendance(userId, currentMonth);
      final user = (await getUsersFromTenantCompany())
          .firstWhere((u) => u.userId == userId);
      final dailyWage = user.dailyWage ?? 500.0;
      int presentDays = attendance.where((a) => a.status == 'present').length;
      int halfDays = attendance.where((a) => a.status == 'half_day').length;
      double currentMonthSalary =
          (presentDays * dailyWage) + (halfDays * dailyWage / 2);

      return unpaidTotal + currentMonthSalary;
    } catch (e) {
      print('UserServiceImpl getPayableSalary error: $e');
      throw Exception('Failed to fetch payable salary: ${e.toString()}');
    }
  }

  @override
  Future<double> getAdvanceBalance(String userId) async {
    try {
      final ledger = await getLedger(userId, null);
      double totalAdvances = ledger
          .where((e) => e['type'] == 'advance')
          .fold(0.0, (sum, e) => sum + (e['amount'] as double));
      final userInfo = await _accountRepository.getUserInfo();
      final salaryHistory = await _tenantCompanyRepository.getSalaryHistory(
          userId, userInfo?.companyId ?? '');
      double totalEarned = salaryHistory.fold(
          0.0, (sum, h) => sum + (h['totalEarned'] as double));
      return totalAdvances - totalEarned > 0
          ? totalAdvances - totalEarned
          : 0.0;
    } catch (e) {
      print('UserServiceImpl getAdvanceBalance error: $e');
      throw Exception('Failed to fetch advance balance: ${e.toString()}');
    }
  }

  @override
  Future<void> finalizeMonth(String userId, String month) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final companyId = userInfo?.companyId ?? '';
      await _tenantCompanyRepository.finalizeMonth(userId, companyId, month);
    } catch (e) {
      print('UserServiceImpl finalizeMonth error: $e');
      throw Exception('Failed to finalize month: ${e.toString()}');
    }
  }
}
