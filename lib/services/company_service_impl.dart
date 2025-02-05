import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/data/company.dart';
import 'package:requirment_gathering_app/data/company_settings.dart';
import 'package:requirment_gathering_app/repositories/company_repository.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';

class CompanyService {
  final CompanyRepository companyRepository;
  final CompanySettingRepository companySettingRepository;

  CompanyService({
    required this.companyRepository,
    required this.companySettingRepository,
  });

  Future<Either<Exception, List<Company>>> fetchCompanies() async {
    try {
      final result = await companyRepository.getAllCompanies();
      return result; // Returns either List<Company> or Exception
    } catch (e) {
      return Left(Exception('Failed to fetch companies: $e'));
    }
  }

  Future<Either<Exception, void>> saveCompany(Company company) async {
    final result = company.id.isEmpty
        ? await companyRepository.addCompany(company)
        : await companyRepository.updateCompany(company.id, company);
    return result;
  }

  Future<Either<Exception, CompanySettingsUi>> fetchCompanySettings() async {
  return  await companySettingRepository.getSettings();
  }

  Future<Either<Exception, bool>> isCompanyNameUnique(String companyName) async {
   return await companyRepository.isCompanyNameUnique(companyName);
  }
}
