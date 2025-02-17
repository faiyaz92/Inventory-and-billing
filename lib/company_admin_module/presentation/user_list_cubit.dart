import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/tenant_company_service.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

class UserListCubit extends Cubit<UserListState> {
  final CompanyOperationsService _companyOperationsService;

  UserListCubit(this._companyOperationsService) : super(UserListInitial());

  Future<void> fetchUsers() async {
    try {
      emit(UserListLoading());
      final users = await _companyOperationsService.getUsersFromTenantCompany();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      emit(UserDeleting());
      // ✅ Implement delete function in service (if not done already)
      await _companyOperationsService.deleteUser(userId);
      fetchUsers(); // Refresh the user list after deletion
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }
}

/// 🔹 Cubit States
abstract class UserListState {}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<UserInfo> users;
  UserListLoaded(this.users);
}

class UserListError extends UserListState {
  final String error;
  UserListError(this.error);
}

class UserDeleting extends UserListState {}
