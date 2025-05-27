import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

// Reusing the same EmployeesState classes from the original EmployeeCubit
abstract class EmployeesState {}

class UserListInitial extends EmployeesState {}

class UserListLoading extends EmployeesState {}

class UserListLoaded extends EmployeesState {
  final List<UserInfo> users;
  UserListLoaded(this.users);
}

class UserListError extends EmployeesState {
  final String error;
  UserListError(this.error);
}

class UserDeleting extends EmployeesState {}

class SimpleEmployeeCubit extends Cubit<EmployeesState> {
  final UserServices _employeeServices;

  SimpleEmployeeCubit(this._employeeServices) : super(UserListInitial());

  Future<void> fetchUsers() async {
    try {
      emit(UserListLoading());
      final users = await _employeeServices.getUsersFromTenantCompany();
      emit(UserListLoaded(users));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      emit(UserDeleting());
      await _employeeServices.deleteUser(userId);
      await fetchUsers();
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }
}