import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';
import 'package:requirment_gathering_app/user_module/data/company_dto.dart';
import 'package:requirment_gathering_app/user_module/repo/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final IFirestorePathProvider _pathProvider;
  final AccountRepository _accountRepository;

  UserInfo? _userInfo; // Private nullable field

  CompanyRepositoryImpl(this._pathProvider, this._accountRepository);

  // ✅ Lazy Initialization for userInfo
  Future<UserInfo?> get userInfo async {
    _userInfo ??= await _accountRepository.getUserInfo();
    return _userInfo;
  }

  @override
  Future<Either<Exception, void>> addCompany(Company company) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }
      company.copyWith(
          createdBy: currentUser.userName, lastUpdatedBy: currentUser.userName);
      final dto = CompanyDto.fromUiModel(company);
      await _pathProvider
          .getCustomerCompanyRef(currentUser.companyId!)
          .add(dto.toMap());

      return const Right(null);
    } catch (e) {
      return Left(Exception("Failed to add company: $e"));
    }
  }

  @override
  Future<Either<Exception, void>> updateCompany(
      String id, Company company) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }
      company.copyWith(lastUpdatedBy: currentUser.userName);
      final dto = CompanyDto.fromUiModel(company);
      await _pathProvider
          .getSingleCustomerCompanyRef(currentUser.companyId!, id)
          .update(dto.toMap());

      return const Right(null);
    } catch (e) {
      return Left(Exception("Failed to update company: $e"));
    }
  }

  @override
  Future<Either<Exception, void>> deleteCompany(String id) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }
      await _pathProvider
          .getSingleCustomerCompanyRef(currentUser.companyId!, id)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(Exception("Failed to delete company: $e"));
    }
  }

  @override
  Future<Either<Exception, Company>> getCompany(String id) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      final doc = await _pathProvider
          .getSingleCustomerCompanyRef(currentUser.companyId!, id)
          .get();

      if (doc.exists) {
        final dto =
            CompanyDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return Right(dto.toUiModel());
      } else {
        return Left(Exception("Company with ID $id not found"));
      }
    } catch (e) {
      return Left(Exception("Failed to fetch company: $e"));
    }
  }

  @override
  Future<Either<Exception, List<Company>>> getAllCompanies() async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      final snapshot = await _pathProvider
          .getCustomerCompanyRef(currentUser.companyId!)
          .get();


      final companies = snapshot.docs.map((doc) {
        final dto = CompanyDto.fromMap(doc.data() as Map<String,dynamic>, doc.id);
        return dto.toUiModel();
      }).toList();

      return Right(companies);
    } catch (e) {
      return Left(Exception("Failed to fetch companies: $e"));
    }
  }

  @override
  Future<Either<Exception, bool>> isCompanyNameUnique(
      String companyName) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      final querySnapshot = await _pathProvider
          .getCustomerCompanyRef(currentUser.companyId!)
          .where('companyName', isEqualTo: companyName)
          .get();


      return Right(querySnapshot.docs.isEmpty);
    } catch (e) {
      return Left(Exception("Failed to check company name uniqueness: $e"));
    }
  }

  @override
  Future<Either<Exception, List<Company>>> getFilteredCompanies(
      String? country, String? city, String? businessType) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      Query<Map<String, dynamic>> query =  _pathProvider
          .getTenantCompanyRef(currentUser.companyId!)
          .collection('companies');

      if (country != null && country.isNotEmpty) {
        query = query.where('country', isEqualTo: country);
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (businessType != null && businessType.isNotEmpty) {
        query = query.where('businessType', isEqualTo: businessType);
      }

      final snapshot = await query.get();
      final companies = snapshot.docs.map((doc) {
        final dto = CompanyDto.fromMap(doc.data(), doc.id);
        return dto.toUiModel();
      }).toList();

      return Right(companies);
    } catch (e) {
      return Left(Exception("Failed to fetch companies: $e"));
    }
  }

  @override
  Future<Either<Exception, List<Company>>> saveCompaniesBulk(
      List<Company> companies) async {
    final currentUser = await userInfo;
    if (currentUser == null || currentUser.companyId == null) {
      return Left(Exception("User not associated with any company."));
    }

    WriteBatch batch = _pathProvider
        .getTenantCompanyRef(currentUser.companyId!)
        .firestore
        .batch();

    List<Company> successfullySaved = [];
    List<Company> failedToSave = [];

    for (var company in companies) {
      try {
        final isUnique = await isCompanyNameUnique(company.companyName);

        isUnique.fold(
          (l) => failedToSave.add(company),
          (r) {
            if (!r) {
              failedToSave.add(company);
              return;
            }

            final dto = CompanyDto.fromUiModel(company);
            final companyRef = _pathProvider
                .getTenantCompanyRef(currentUser.companyId!)
                .collection('companies')
                .doc();
            batch.set(companyRef, dto.toMap());
            successfullySaved.add(company);
          },
        );
      } catch (e) {
        failedToSave.add(company);
      }
    }

    if (successfullySaved.isNotEmpty) {
      await batch.commit();
    }

    return Right(failedToSave);
  }

  @override
  Future<List<UserInfoDto>> getUsersFromTenantCompany() async {
    try {
      // Get reference to the tenant company
      final currentUser = await userInfo;

      CollectionReference usersRef =
          _pathProvider.getTenantUsersRef(currentUser?.companyId ?? '');

      // Fetch all users in the tenant company
      QuerySnapshot querySnapshot = await usersRef.get();

      // Convert Firestore documents to UserInfoDto
      List<UserInfoDto> users = querySnapshot.docs.map((doc) {
        return UserInfoDto.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return users;
    } catch (e) {
      print('❌ Error fetching users: $e');
      throw Exception('Failed to fetch users from tenant company.');
    }
  }
}
