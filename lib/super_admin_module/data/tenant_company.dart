
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company_dto.dart';

class TenantCompany {
  final String? id;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? gstin;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;
  final String? address;

  TenantCompany({
    this.id,
    this.name,
    this.email,
    this.mobileNumber,
    this.gstin,
    this.country,
    this.state,
    this.city,
    this.zipCode,
    this.address,
  });

  /// 🔹 Convert DTO to TenantCompany Model
  factory TenantCompany.fromDto(TenantCompanyDto dto) {
    return TenantCompany(
      id: dto.companyId,
      name: dto.name,
      email: dto.email,
      mobileNumber: dto.mobileNumber,
      gstin: dto.gstin,
      country: dto.country,
      state: dto.state,
      city: dto.city,
      zipCode: dto.zipCode,
      address: dto.address,
    );
  }

  /// 🔹 Convert TenantCompany to DTO
  TenantCompanyDto toDto() {
    return TenantCompanyDto(
      companyId: id,
      name: name,
      email: email,
      mobileNumber: mobileNumber,
      gstin: gstin,
      country: country,
      state: state,
      city: city,
      zipCode: zipCode,
      address: address,
    );
  }
}
