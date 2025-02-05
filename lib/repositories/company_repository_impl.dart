import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/data/company_dto.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final FirebaseFirestore _firestore;

  CompanyRepositoryImpl(this._firestore);

  @override
  Future<Either<Exception, void>> addCompany(Company company) async {
    try {
      final dto = CompanyDto.fromUiModel(company);
      await _firestore.collection('companies').add(dto.toMap());
      return Right(null); // Successfully added, returning a successful result with no value
    } catch (e) {
      return Left(Exception("Failed to add company: $e"));
    }
  }

  @override
  Future<Either<Exception, void>> updateCompany(String id, Company company) async {
    try {
      final dto = CompanyDto.fromUiModel(company);
      await _firestore.collection('companies').doc(id).update(dto.toMap());
      return Right(null); // Successfully updated, returning a successful result with no value
    } catch (e) {
      return Left(Exception("Failed to update company: $e"));
    }
  }

  @override
  Future<Either<Exception, void>> deleteCompany(String id) async {
    try {
      await _firestore.collection('companies').doc(id).delete();
      return Right(null); // Successfully deleted, returning a successful result with no value
    } catch (e) {
      return Left(Exception("Failed to delete company: $e"));
    }
  }

  @override
  Future<Either<Exception, Company>> getCompany(String id) async {
    try {
      final doc = await _firestore.collection('companies').doc(id).get();
      if (doc.exists) {
        final dto = CompanyDto.fromMap(doc.data()!, doc.id);
        return Right(dto.toUiModel()); // Successfully fetched, return company data
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
      final snapshot = await _firestore.collection('companies').get();
      final companies = snapshot.docs.map((doc) {
        final dto = CompanyDto.fromMap(doc.data(), doc.id);
        return dto.toUiModel();
      }).toList();
      return Right(companies); // Successfully fetched all companies
    } catch (e) {
      return Left(Exception("Failed to fetch companies: $e"));
    }
  }

  @override
  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName) async {
    try {
      final querySnapshot = await _firestore
          .collection('companies')
          .where('companyName', isEqualTo: companyName)
          .get();

      return Right(querySnapshot.docs.isEmpty); // Returns true if unique
    } catch (e) {
      return Left(Exception("Failed to check company name uniqueness: $e"));
    }
  }

  @override
  Future<Either<Exception, List<Company>>> getFilteredCompanies(
      String? country, String? city, String? businessType) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('companies');

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

      return Right(companies); // Successfully fetched filtered companies
    } catch (e) {
      return Left(Exception("Failed to fetch companies: $e"));
    }
  }

  @override
  Future<Either<Exception, List<Company>>> saveCompaniesBulk(List<Company> companies) async {
    WriteBatch batch = _firestore.batch();
    List<Company> successfullySaved = [];
    List<Company> failedToSave = [];

    for (var company in companies) {
      try {
        final isUnique = await isCompanyNameUnique(company.companyName);

        // If the company name is not unique, add to failedToSave and continue
        isUnique.fold(
              (l) {
            // Handle error from isCompanyNameUnique if needed
            failedToSave.add(company); // or handle specific error logic here
          },
              (r) {
            if (!r) {
              failedToSave.add(company);
              return; // Skip this company and move to the next iteration
            }

            final dto = CompanyDto.fromUiModel(company);
            final companyRef = _firestore.collection('companies').doc();
            batch.set(companyRef, dto.toMap());
            successfullySaved.add(company);
          },
        );
      } catch (e) {
        failedToSave.add(company); // Catching any exception in the process
      }
    }

    if (successfullySaved.isNotEmpty) {
      await batch.commit();
    }

    return Right(failedToSave); // Return list of failed companies
  }

}
