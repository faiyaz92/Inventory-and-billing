import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantCompanyRepository implements ITenantCompanyRepository {
  final IFirestorePathProvider _firestoreProvider;
  final FirebaseAuth _auth;
  final AccountRepository _accountRepository;

  TenantCompanyRepository(
      this._firestoreProvider, this._auth, this._accountRepository);

  @override
  Future<String> generateTenantCompanyId(String companyName) async {
    String companyId = companyName.toLowerCase().replaceAll(' ', '_');

    // ✅ Check if the company already exists
    bool exists = await _firestoreProvider.checkCompanyExists(companyId);
    if (exists) {
      companyId += "_${DateTime.now().millisecondsSinceEpoch}";
    }
    return companyId;
  }

  @override
  Future<void> createTenantCompany(
      TenantCompanyDto dto, String password) async {
    final userInfo = await _accountRepository.getUserInfo();
    String? superAdminId = userInfo?.userId;

    if (superAdminId == null) {
      throw Exception("Super Admin not logged in.");
    }

    String companyId = await generateTenantCompanyId(dto.name ?? '');

    // ✅ Create a new Firebase user for the company admin
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: dto.email ?? '',
      password: password,
    );

    String userId = userCredential.user!.uid;

    // ✅ Update DTO with new company ID and createdBy details
    final updatedDto = dto.copyWith(
      companyId: companyId,
      createdBy: superAdminId,
      createdAt: Timestamp.now(),
    );

    // ✅ Save Tenant Company Data
    final companyRef = _firestoreProvider.getTenantCompanyRef(companyId);
    await companyRef.set(updatedDto.toMap());

    // ✅ Create Admin User Info DTO
    UserInfoDto adminUser = UserInfoDto(
      userId: userId,
      email: dto.email ?? '',
      role: Role.COMPANY_ADMIN,
      // ✅ Assign Admin Role
      companyId: companyId,
      name: '',
      userName: '',
    );

    // ✅ Save Admin User Under Tenant Company
    await _firestoreProvider
        .getTenantUsersRef(companyId)
        .doc(userId)
        .set(adminUser.toMap());

    await _firestoreProvider.getCommonUsersPath()
        .doc(userId)
        .set(adminUser.toMap());
  }

  // ✅ Allow Tenant Company Admin to Add Users
  @override
  Future<void> addUserToCompany(
      UserInfoDto userInfoDto, String password) async {
    // ✅ Create a new Firebase user
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: userInfoDto.email ?? '',
      password: password,
    );
    String userId = userCredential.user!.uid;

    // ✅ Ensure company ID is available
    if (userInfoDto.companyId == null || userInfoDto.companyId!.isEmpty) {
      throw Exception("Company ID is missing. Cannot add user.");
    }

    // ✅ Update userInfoDto with generated userId
    UserInfoDto updatedUserInfo = userInfoDto.copyWith(userId: userId);

    // ✅ Save the user under the tenant company collection
    await _firestoreProvider
        .getTenantUsersRef(userInfoDto.companyId!)
        .doc(userId)
        .set(updatedUserInfo.toMap());

    // ✅ Save the user in the global users collection
    await _firestoreProvider.getCommonUsersPath()
        .doc(userId)
        .set(updatedUserInfo.toMap());
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
      // Get the current logged-in user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in.");
      }

      // Create Super Admin User Info DTO
      UserInfoDto superAdminUser = UserInfoDto(
          userId: currentUser.uid,
          email: currentUser.email ?? '',
          role: Role.SUPER_ADMIN,
          userName: 'faiyaz92',
          name: 'Faiyaz Meghreji',
          companyId: 'Easy2Solutions'
          // Assign Super Admin Role
          );

      // Save Super Admin User to Firestore
      await _firestoreProvider.superAdminPath
          .doc(currentUser
              .uid) // Ensure we're using the correct doc method instead of add
          .set(superAdminUser.toMap());

      await _firestoreProvider
          .getTenantCompanyRef('Easy2Solutions')
          .collection('users')
          .doc(currentUser.uid)
          .set(superAdminUser.toMap());
      // Save Super Admin ID to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('superAdminId', currentUser.uid);
    } catch (e) {
      // Handle errors (e.g., network issues, Firestore errors)
      print('Error adding super admin: $e');
    }
  }

  @override
  Future<List<UserInfoDto>> getUsersFromTenantCompany(String companyId) async {
    try {
      // Get reference to the tenant company
      CollectionReference usersRef =
          _firestoreProvider.getTenantUsersRef(companyId);

      // Fetch all users in the tenant company
      QuerySnapshot querySnapshot = await usersRef.get();

      // Convert Firestore documents to UserInfoDto
      List<UserInfoDto> users = querySnapshot.docs.map((doc) {
        return UserInfoDto.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return users;
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users from tenant company.');
    }
  }

  @override
  Future<void> deleteUser(String companyId,String userId) async {
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
      throw Exception("Error deleting user: $e");
    }
  }
}
