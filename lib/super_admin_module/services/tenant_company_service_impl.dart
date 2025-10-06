import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company_dto.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service.dart';

class TenantCompanyServiceImpl implements TenantCompanyService {
  final ITenantCompanyRepository _tenantCompanyRepository;

  TenantCompanyServiceImpl(this._tenantCompanyRepository);

  @override
  Future<void> createTenantCompany(
      TenantCompany company,
      String password, {
        required String adminUsername,
        required String adminName,
      }) async {
    final dto = TenantCompanyDto(
      companyId: company.id ?? '',
      name: company.name,
      email: company.email,
      mobileNumber: company.mobileNumber,
      gstin: company.gstin,
      country: company.country,
      state: company.state,
      city: company.city,
      zipCode: company.zipCode,
      address: company.address,
    );

    await _tenantCompanyRepository.createTenantCompany(
      dto,
      password,
      adminUsername: adminUsername,
      adminName: adminName,
    );
  }

  @override
  Future<void> updateTenantCompany(TenantCompany company) async {
    final dto = TenantCompanyDto(
      companyId: company.id ?? '',
      name: company.name,
      email: company.email,
      mobileNumber: company.mobileNumber,
      gstin: company.gstin,
      country: company.country,
      state: company.state,
      city: company.city,
      zipCode: company.zipCode,
      address: company.address,
    );

    await _tenantCompanyRepository.updateTenantCompany(dto);
  }

  @override
  Future<void> addSuperAdmin() async {
    await _tenantCompanyRepository.addSuperAdmin();
  }

  @override
  Future<List<TenantCompany>> getTenantCompanies() async {
    try {
      final dtos = await _tenantCompanyRepository.getTenantCompanies();
      return dtos.map((dto) => TenantCompany.fromDto(dto)).toList();
    } catch (e) {
      if (e.toString().contains('index')) {
        print('Index issue detected in getTenantCompanies: $e');
      }
      throw Exception('Failed to fetch tenant companies: $e');
    }
  }

  @override
  Future<TenantCompany?> getTenantCompanyById(String companyId) async {
    try {
      final dto = await _tenantCompanyRepository.getTenantCompanyById(companyId);
      if (dto == null) {
        return null;
      }
      return TenantCompany.fromDto(dto);
    } catch (e) {
      if (e.toString().contains('index')) {
        print('Index issue detected in getTenantCompanyById: $e');
      }
      throw Exception('Failed to fetch tenant company by ID: $e');
    }
  }
}