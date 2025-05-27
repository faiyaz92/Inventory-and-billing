import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository_impl.dart';

class TenantCompanyState {
  final List<TenantCompany> companies;
  final bool isLoading;
  final String? error;

  TenantCompanyState({required this.companies, this.isLoading = false, this.error});

  TenantCompanyState copyWith({List<TenantCompany>? companies, bool? isLoading, String? error}) {
    return TenantCompanyState(
      companies: companies ?? this.companies,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TenantCompanyCubit extends Cubit<TenantCompanyState> {
  final TenantCompanyRepository _repository;

  TenantCompanyCubit(this._repository) : super(TenantCompanyState(companies: []));

  Future<void> fetchCompanies() async {
    emit(state.copyWith(isLoading: true));
    try {
      final companies = await _repository.getTenantCompanies();
      emit(state.copyWith(companies: companies.map((dto) => TenantCompany.fromDto(dto)).toList(), isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }



  Future<void> updateCompany(TenantCompany company) async {
    try {
      await _repository.updateTenantCompany( company.toDto());
      fetchCompanies(); // Refresh list
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      await _repository.deleteTenantCompany(companyId);
      fetchCompanies(); // Refresh list
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
