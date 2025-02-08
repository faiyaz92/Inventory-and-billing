import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/data/company_dto.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/services/firestore_provider.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final FirestorePathProvider _pathProvider;

  CompanyRepositoryImpl(this._pathProvider);

  @override
  Future<Either<Exception, void>> addCompany(Company company) async {
    try {
      final dto = CompanyDto.fromUiModel(company);
      await _pathProvider.basePath.collection('companies').add(dto.toMap());
      return const Right(null);
    } catch (e) {
      return Left(Exception("Failed to add company: $e"));
    }
  }

  @override
  Future<Either<Exception, void>> updateCompany(String id, Company company) async {
    try {
      final dto = CompanyDto.fromUiModel(company);
      await _pathProvider.basePath.collection('companies').doc(id).update(dto.toMap());
      return const Right(null);
    } catch (e) {
      return Left(Exception("Failed to update company: $e"));
    }
  }

  @override
  Future<Either<Exception, void>> deleteCompany(String id) async {
    try {
      await _pathProvider.basePath.collection('companies').doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(Exception("Failed to delete company: $e"));
    }
  }

  @override
  Future<Either<Exception, Company>> getCompany(String id) async {
    try {
      final doc = await _pathProvider.basePath.collection('companies').doc(id).get();
      if (doc.exists) {
        final dto = CompanyDto.fromMap(doc.data()!, doc.id);
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
      final snapshot = await _pathProvider.basePath.collection('companies').get();
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
  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName) async {
    try {
      final querySnapshot = await _pathProvider.basePath
          .collection('companies')
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
      Query<Map<String, dynamic>> query = _pathProvider.basePath.collection('companies');

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
  Future<Either<Exception, List<Company>>> saveCompaniesBulk(List<Company> companies) async {
    WriteBatch batch = _pathProvider.basePath.firestore.batch();
    List<Company> successfullySaved = [];
    List<Company> failedToSave = [];

    for (var company in companies) {
      try {
        final isUnique = await isCompanyNameUnique(company.companyName);

        isUnique.fold(
              (l) {
            failedToSave.add(company);
          },
              (r) {
            if (!r) {
              failedToSave.add(company);
              return;
            }

            final dto = CompanyDto.fromUiModel(company);
            final companyRef = _pathProvider.basePath.collection('companies').doc();
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
}
