import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';
import 'package:requirment_gathering_app/user_module/data/partner_dto.dart';
import 'package:requirment_gathering_app/user_module/repo/customer_company_repository.dart';

class CustomerCompanyRepositoryImpl implements CustomerCompanyRepository {
  final IFirestorePathProvider _pathProvider;
  final AccountRepository _accountRepository;

  UserInfo? _userInfo;

  CustomerCompanyRepositoryImpl(this._pathProvider, this._accountRepository);

  Future<UserInfo?> get userInfo async {
    _userInfo ??= await _accountRepository.getUserInfo();
    return _userInfo;
  }

  @override
  Future<Either<Exception, String>> addCompany(PartnerDto company) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

     final companyId =await _pathProvider
          .getCustomerCompanyRef(currentUser.companyId!)
          .add(company.toMap());
      return  Right(companyId.id);
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error adding company: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to add company: $e"));
    }
  }

  @override
  Future<Either<Exception, String>> updateCompany(String id, PartnerDto company) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      await _pathProvider
          .getSingleCustomerCompanyRef(currentUser.companyId!, id)
          .update(company.toMap());
      return  Right(id);
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error updating company: ${e.message}"));
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
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error deleting company: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to delete company: $e"));
    }
  }

  @override
  Future<Either<Exception, PartnerDto>> getCompany(String id) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      final doc = await _pathProvider
          .getSingleCustomerCompanyRef(currentUser.companyId!, id)
          .get();

      if (doc.exists) {
        return Right(PartnerDto.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      } else {
        return Left(Exception("Company with ID $id not found"));
      }
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error fetching company: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to fetch company: $e"));
    }
  }

  @override
  Future<Either<Exception, List<PartnerDto>>> getAllCompanies() async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      final snapshot = await _pathProvider
          .getCustomerCompanyRef(currentUser.companyId!)
          .get();

      final companies = snapshot.docs.map((doc) {
        return PartnerDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return Right(companies);
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error fetching companies: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to fetch companies: $e"));
    }
  }

  @override
  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName) async {
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
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error checking company name: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to check company name uniqueness: $e"));
    }
  }

  @override
  Future<Either<Exception, List<PartnerDto>>> getFilteredCompanies(
      String? country, String? city, String? businessType) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      Query<Map<String, dynamic>> query = _pathProvider
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
        return PartnerDto.fromMap(doc.data(), doc.id);
      }).toList();

      return Right(companies);
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error fetching filtered companies: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to fetch filtered companies: $e"));
    }
  }

  @override
  Future<Either<Exception, List<PartnerDto>>> saveCompaniesBulk(List<PartnerDto> companies) async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      WriteBatch batch = _pathProvider
          .getTenantCompanyRef(currentUser.companyId!)
          .firestore
          .batch();

      List<PartnerDto> failedCompanies = [];

      for (var company in companies) {
        final querySnapshot = await _pathProvider
            .getCustomerCompanyRef(currentUser.companyId!)
            .where('companyName', isEqualTo: company.companyName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          failedCompanies.add(company);
          continue;
        }

        final companyRef = _pathProvider
            .getTenantCompanyRef(currentUser.companyId!)
            .collection('companies')
            .doc();
        batch.set(companyRef, company.toMap());
      }

      if (companies.length > failedCompanies.length) {
        await batch.commit();
      }

      return Right(failedCompanies);
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error saving bulk companies: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to save bulk companies: $e"));
    }
  }

  @override
  Future<Either<Exception, List<UserInfoDto>>> getUsersFromOwnCompany() async {
    try {
      final currentUser = await userInfo;
      if (currentUser == null || currentUser.companyId == null) {
        return Left(Exception("User not associated with any company."));
      }

      final querySnapshot = await _pathProvider
          .getTenantUsersRef(currentUser.companyId!)
          .get();

      final users = querySnapshot.docs.map((doc) {
        return UserInfoDto.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return Right(users);
    } on FirebaseException catch (e) {
      return Left(Exception("Firestore error fetching users: ${e.message}"));
    } catch (e) {
      return Left(Exception("Failed to fetch users: $e"));
    }
  }
}