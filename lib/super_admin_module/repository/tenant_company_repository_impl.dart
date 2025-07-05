import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TenantCompanyRepository implements ITenantCompanyRepository {
  final IFirestorePathProvider _firestoreProvider;
  final FirebaseAuth _auth;
  final AccountRepository _accountRepository;

  TenantCompanyRepository(
      this._firestoreProvider, this._auth, this._accountRepository);

  @override
  Future<String> generateTenantCompanyId(String companyName) async {
    String companyId = companyName.toLowerCase().replaceAll(' ', '_');
    bool exists = await _firestoreProvider.checkCompanyExists(companyId);
    if (exists) {
      companyId += '_${DateTime.now().millisecondsSinceEpoch}';
    }
    return companyId;
  }

  @override
  Future<void> createTenantCompany(
    TenantCompanyDto dto,
    String password, {
    required String adminUsername,
    required String adminName,
  }) async {
    final userInfo = await _accountRepository.getUserInfo();
    String? superAdminId = userInfo?.userId;
    if (superAdminId == null) {
      throw Exception('Super Admin not logged in.');
    }
    String companyId = await generateTenantCompanyId(dto.name ?? '');
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: dto.email ?? '',
      password: password,
    );
    String userId = userCredential.user!.uid;
    final updatedDto = dto.copyWith(
      companyId: companyId,
      createdBy: superAdminId,
      createdAt: Timestamp.now(),
    );
    final companyRef = _firestoreProvider.getTenantCompanyRef(companyId);
    await companyRef.set(updatedDto.toMap());
    UserInfoDto adminUser = UserInfoDto(
      userId: userId,
      email: dto.email ?? '',
      role: Role.COMPANY_ADMIN,
      companyId: companyId,
      name: adminName,
      userName: adminUsername,
    );
    await _firestoreProvider
        .getTenantUsersRef(companyId)
        .doc(userId)
        .set(adminUser.toMap());
    await _firestoreProvider
        .getCommonUsersPath()
        .doc(userId)
        .set(adminUser.toMap());
  }
  @override
  Future<String> addUserToCompany(UserInfoDto userInfoDto, String? password) async {
    if (userInfoDto.companyId == null || userInfoDto.companyId!.isEmpty) {
      throw Exception('Company ID is missing. Cannot add user.');
    }

    String userId;
    UserInfoDto updatedUserInfo;

    if (userInfoDto.userType == UserType.Employee) {
      // For Employees: Create Firebase Auth credentials
      if (password == null || password.isEmpty) {
        throw Exception('Password is required for Employee users.');
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userInfoDto.email ?? '',
        password: password,
      );
      userId = userCredential.user!.uid;
      updatedUserInfo = userInfoDto.copyWith(userId: userId);
    } else {
      // For non-Employees: Generate custom userId, no Firebase Auth
      userId = const Uuid().v4(); // Generate unique userId
      updatedUserInfo = userInfoDto.copyWith(userId: userId);
    }

    // Add to tenant users collection (all users)
    await _firestoreProvider
        .getTenantUsersRef(userInfoDto.companyId!)
        .doc(userId)
        .set(updatedUserInfo.toMap());

    // Only add Employees to common users collection
    if (userInfoDto.userType == UserType.Employee) {
      await _firestoreProvider
          .getCommonUsersPath()
          .doc(userId)
          .set(updatedUserInfo.toMap());
    }

    return userId;
  }

  @override
  Future<void> updateUser(
      String userId, String companyId, UserInfoDto userInfoDto) async {
    try {
      final updateData = userInfoDto.toPartialMap();
      await _firestoreProvider
          .getTenantUsersRef(companyId)
          .doc(userId)
          .update(updateData);
      await _firestoreProvider
          .getCommonUsersPath()
          .doc(userId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  @override
  Future<UserInfoDto?> getUser(String userId, String companyId) async {
    try {
      final userSnapshot = await _firestoreProvider
          .getTenantUsersRef(companyId)
          .doc(userId)
          .get();
      if (!userSnapshot.exists) {
        return null;
      }
      return UserInfoDto.fromMap(userSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  @override
  Future<List<TenantCompanyDto>> getTenantCompanies() async {
    final snapshot =
        await _firestoreProvider.basePath.collection('tenantCompanies').get();
    return snapshot.docs
        .map((doc) => TenantCompanyDto.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> updateTenantCompany(TenantCompanyDto updatedDto) async {
    await _firestoreProvider
        .getTenantCompanyRef(updatedDto.companyId ?? '')
        .update(updatedDto.toMap());
  }

  @override
  Future<void> deleteTenantCompany(String companyId) async {
    await _firestoreProvider.getTenantCompanyRef(companyId).delete();
  }

  @override
  Future<void> addSuperAdmin() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in.');
      }
      UserInfoDto superAdminUser = UserInfoDto(
        userId: currentUser.uid,
        email: currentUser.email ?? '',
        role: Role.SUPER_ADMIN,
        userName: 'faiyaz92',
        name: 'Faiyaz Meghreji',
        companyId: 'Easy2Solutions',
      );
      await _firestoreProvider.superAdminPath
          .doc(currentUser.uid)
          .set(superAdminUser.toMap());
      await _firestoreProvider
          .getTenantCompanyRef('Easy2Solutions')
          .collection('users')
          .doc(currentUser.uid)
          .set(superAdminUser.toMap());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('superAdminId', currentUser.uid);
    } catch (e) {
      print('Error adding super admin: $e');
    }
  }

  @override
  Future<List<UserInfoDto>> getUsersFromTenantCompany(String companyId, {String? storeId}) async {
    try {
      final userInfo = await _accountRepository.getUserInfo();
      final loggedInUserRole = userInfo?.role;
      final loggedInUserStoreId = userInfo?.storeId;

      CollectionReference usersRef = _firestoreProvider.getTenantUsersRef(companyId);
      QuerySnapshot querySnapshot;

      if (storeId != null && storeId.isNotEmpty) {
        // Filter by provided storeId, regardless of role
        querySnapshot = await usersRef
            .where('storeId', isEqualTo: storeId)
            .get();
      } else {
        // No storeId provided, use existing role-based logic
        if (loggedInUserRole == Role.COMPANY_ADMIN) {
          // COMPANY_ADMIN sees all users in the company
          querySnapshot = await usersRef.get();
        } else {
          // Other roles (USER, STORE_ADMIN, SUPER_ADMIN) see only users with the same storeId
          if (loggedInUserStoreId == null || loggedInUserStoreId.isEmpty) {
            throw Exception('Logged-in user has no store ID assigned.');
          }
          querySnapshot = await usersRef
              .where('storeId', isEqualTo: loggedInUserStoreId)
              .get();
        }
      }

      return querySnapshot.docs
          .map((doc) => UserInfoDto.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users from tenant company: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId, String companyId) async {
    try {
      await _firestoreProvider
          .getTenantUsersRef(companyId)
          .doc(userId)
          .delete();
      await _firestoreProvider.basePath
          .collection('users')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  @override
  Future<void> updateUserLocation(
      String userId, String companyId, UserInfoDto userInfoDto) async {
    await _firestoreProvider.getTenantUserRef(companyId, userId).update({
      'latitude': userInfoDto.latitude,
      'longitude': userInfoDto.longitude,
    });
  }

  @override
  Future<void> markAttendance(
      String userId, String companyId, AttendanceDTO attendance) async {
    final attendanceRef = _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('attendance')
        .doc(attendance.date);
    await attendanceRef.set(attendance.toJson());
  }

  @override
  Future<List<AttendanceDTO>> getAttendance(
      String userId, String companyId, String month) async {
    final snapshot = await _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: '$month-01')
        .where('date', isLessThanOrEqualTo: '$month-31')
        .orderBy('date')
        .get();

    final models = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return AttendanceModel(
        date: DateFormat('dd-MM-yyyy').format(DateTime.parse(data['date'])),
        status: data['status'],
      );
    }).toList();

    return models.map((model) {
      final dateTime = DateFormat('dd-MM-yyyy').parse(model.date);
      return AttendanceDTO(
        date: DateFormat('yyyy-MM-dd').format(dateTime),
        status: model.status,
        year: DateFormat('yyyy').format(dateTime),
        month: DateFormat('MM').format(dateTime),
        day: DateFormat('dd').format(dateTime),
      );
    }).toList();
  }

  @override
  Future<void> recordSalaryPayment(
      String userId, String companyId, double amount, String month) async {
    final ledgerRef = _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('ledger')
        .doc('${month}_${Timestamp.now().millisecondsSinceEpoch}_payment');
    await ledgerRef.set({
      'type': 'payment',
      'amount': -amount,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'month': month,
      'timestamp': FieldValue.serverTimestamp(),
    });
    final salaryHistoryRef = _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('salary_history')
        .doc(month);
    await salaryHistoryRef.update({'paid': true});
  }

  @override
  Future<void> recordAdvanceSalary(
      String userId, String companyId, double amount, String date) async {
    final ledgerRef = _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('ledger')
        .doc('${date}_advance');
    await ledgerRef.set({
      'type': 'advance',
      'amount': amount,
      'date': date,
      'month': date.substring(0, 7),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getLedger(
      String userId, String companyId, String? month) async {
    Query<Map<String, dynamic>> query = _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('ledger')
        .orderBy('timestamp', descending: true);
    if (month != null) {
      query = query
          .where('month', isEqualTo: month)
          .where('date', isGreaterThanOrEqualTo: '$month-01')
          .where('date', isLessThanOrEqualTo: '$month-31');
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSalaryHistory(
      String userId, String companyId) async {
    final snapshot = await _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('salary_history')
        .orderBy('month', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> finalizeMonth(
      String userId, String companyId, String month) async {
    final attendanceDTOs = await getAttendance(userId, companyId, month);
    final models = attendanceDTOs.map((dto) {
      return AttendanceModel(
        date: DateFormat('dd-MM-yyyy').format(DateTime.parse(dto.date)),
        status: dto.status,
      );
    }).toList();

    final userSnapshot =
        await _firestoreProvider.getTenantUserRef(companyId, userId).get();
    final userData = userSnapshot.data() as Map<String, dynamic>;
    final dailyWage = (userData['dailyWage'] as num?)?.toDouble() ?? 500.0;
    int presentDays = models.where((model) => model.status == 'present').length;
    int halfDays = models.where((model) => model.status == 'half_day').length;
    double totalEarned = (presentDays * dailyWage) + (halfDays * dailyWage / 2);
    final salaryHistoryRef = _firestoreProvider
        .getTenantUserRef(companyId, userId)
        .collection('salary_history')
        .doc(month);
    await salaryHistoryRef.set({
      'month': month,
      'presentDays': presentDays,
      'halfDays': halfDays,
      'totalEarned': totalEarned,
      'paid': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
