import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/data/company_ui.dart';
import 'package:requirment_gathering_app/data/company_dto.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final FirebaseFirestore _firestore;

  CompanyRepositoryImpl(this._firestore);

  @override
  Future<void> addCompany(CompanyUi company) async {
    try {
      // Convert UI Model to DTO and save to Firestore
      final dto = CompanyDto.fromUiModel(company);
      await _firestore.collection('companies').add(dto.toMap());
    } catch (e) {
      throw Exception("Failed to add company: $e");
    }
  }

  @override
  Future<void> updateCompany(String id, CompanyUi company) async {
    try {
      // Convert UI Model to DTO and update in Firestore
      final dto = CompanyDto.fromUiModel(company);
      await _firestore.collection('companies').doc(id).update(dto.toMap());
    } catch (e) {
      throw Exception("Failed to update company: $e");
    }
  }

  @override
  Future<void> deleteCompany(String id) async {
    try {
      await _firestore.collection('companies').doc(id).delete();
    } catch (e) {
      throw Exception("Failed to delete company: $e");
    }
  }

  @override
  Future<CompanyUi> getCompany(String id) async {
    try {
      final doc = await _firestore.collection('companies').doc(id).get();
      if (doc.exists) {
        final dto = CompanyDto.fromMap(doc.data()!, doc.id);
        return dto.toUiModel();
      } else {
        throw Exception("Company with ID $id not found");
      }
    } catch (e) {
      throw Exception("Failed to fetch company: $e");
    }
  }

  @override
  Future<List<CompanyUi>> getAllCompanies() async {
    try {
      final snapshot = await _firestore.collection('companies').get();

      // Map Firebase documents to a list of UI Models via DTO
      return snapshot.docs.map((doc) {
        final dto = CompanyDto.fromMap(doc.data(), doc.id);
        return dto.toUiModel();
      }).toList();
    } catch (e) {
      throw Exception("Failed to fetch companies: $e");
    }
  }

  @override
  Future<bool> isCompanyNameUnique(String companyName) async {
    try {
      final querySnapshot = await _firestore
          .collection('companies')
          .where('companyName', isEqualTo: companyName)
          .get();

      // Returns true if no documents match the company name
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw Exception("Failed to check company name uniqueness: $e");
    }
  }
}
