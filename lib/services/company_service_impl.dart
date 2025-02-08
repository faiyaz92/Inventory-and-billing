import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/data/company_settings.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';
import 'package:requirment_gathering_app/services/company_service.dart';

class CompanyServiceImpl implements CompanyService {
  final CompanyRepository _companyRepository;
  final CompanySettingRepository companySettingRepository;

  CompanyServiceImpl(
    this._companyRepository, {
    required this.companySettingRepository,
  });

  @override
  Future<Either<Exception, List<Company>>> fetchCompanies() async {
    try {
      final result = await _companyRepository.getAllCompanies();
      return result; // Returns either List<Company> or Exception
    } catch (e) {
      return Left(Exception('Failed to fetch companies: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> saveCompany(Company company) async {
    final result = company.id.isEmpty
        ? await _companyRepository.addCompany(company)
        : await _companyRepository.updateCompany(company.id, company);
    return result;
  }

  @override
  Future<Either<Exception, CompanySettingsUi>> fetchCompanySettings() async {
    return await companySettingRepository.getSettings();
  }

  @override
  Future<Either<Exception, bool>> isCompanyNameUnique(
      String companyName) async {
    return await _companyRepository.isCompanyNameUnique(companyName);
  }

  @override
  Future<void> addCompany(Company company) async {
    await _companyRepository.addCompany(company);
  }

  @override
  Future<void> updateCompany(String id, Company company) async {
    _companyRepository.updateCompany(company.id, company);
  }

  @override
  Future<Either<Exception, List<Company>>> getAllCompanies() async {
    return _companyRepository.getAllCompanies();
  }

  @override
  Future<void> deleteCompany(String id) async {
    _companyRepository.deleteCompany(id);
  }

  @override
  Future<Either<Exception, CompanySettingsUi>> getSettings() {
    return companySettingRepository.getSettings();
  }

  @override
  Future<Either<Exception, void>> updateSettings(CompanySettingsUi settings) {
    return companySettingRepository.updateSettings(settings);
  }
}
