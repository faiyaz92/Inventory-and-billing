import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/super_admin_module/data/tenant_company.dart';
import 'package:requirment_gathering_app/super_admin_module/services/tenant_company_service.dart';

class AddTenantCompanyState {}

class AddTenantCompanyLoading extends AddTenantCompanyState {}

class AddTenantCompanySuccess extends AddTenantCompanyState {}

class AddTenantCompanyUpdated extends AddTenantCompanyState {}

class AddTenantCompanyError extends AddTenantCompanyState {
  final String message;
  AddTenantCompanyError(this.message);
}

class AddTenantCompanyCubit extends Cubit<AddTenantCompanyState> {
  final TenantCompanyService _tenantCompanyService;

  AddTenantCompanyCubit(this._tenantCompanyService) : super(AddTenantCompanyState());

  Future<void> addTenantCompany(TenantCompany company, String password) async {
    emit(AddTenantCompanyLoading());
    try {
      await _tenantCompanyService.createTenantCompany(company, password);
      emit(AddTenantCompanySuccess());
    } catch (e) {
      emit(AddTenantCompanyError(e.toString()));
    }
  }

  Future<void> updateTenantCompany(TenantCompany company) async {
    emit(AddTenantCompanyLoading());
    try {
      await _tenantCompanyService.updateTenantCompany(company);
      emit(AddTenantCompanyUpdated());
    } catch (e) {
      emit(AddTenantCompanyError(e.toString()));
    }
  }
}
