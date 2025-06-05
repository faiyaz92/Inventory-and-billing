import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

class EmployeeCubit extends Cubit<EmployeesState> {
  final UserServices _employeeServices;

  EmployeeCubit(this._employeeServices) : super(UserListInitial());

  Future<void> fetchUsers() async {
    try {
      emit(UserListLoading());
      final users = await _employeeServices.getUsersFromTenantCompany();
      final payableSalaries = <String, double>{};
      for (var user in users) {
        payableSalaries[user.userId!] = await _employeeServices.getPayableSalary(user.userId!);
      }
      emit(UserListLoaded(users, payableSalaries));
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

abstract class EmployeesState {}

class UserListInitial extends EmployeesState {}

class UserListLoading extends EmployeesState {}

class UserListLoaded extends EmployeesState {
  final List<UserInfo> users;
  final Map<String, double> payableSalaries;
  UserListLoaded(this.users, this.payableSalaries);
}

class UserListError extends EmployeesState {
  final String error;
  UserListError(this.error);
}

class UserDeleting extends EmployeesState {}