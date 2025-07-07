import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class EmployeeCubit extends Cubit<EmployeesState> {
  final UserServices _employeeServices;

  EmployeeCubit(this._employeeServices) : super(UserListInitial());

  Future<void> fetchUsers() async {
    try {
      emit(UserListLoading());
      final allUsers = await _employeeServices.getUsersFromTenantCompany();
      // Filter users to include only those with UserType.Employee
      final employees = allUsers.where((user) {
        final isEmployee = user.userType == UserType.Employee;
        print('EmployeeCubit fetchUsers: userId = ${user.userId}, userType = ${user.userType?.name ?? "null"}, isEmployee = $isEmployee');
        return isEmployee;
      }).toList();

      final payableSalaries = <String, double>{};
      for (var employee in employees) {
        if (employee.userId != null) {
          payableSalaries[employee.userId!] = await _employeeServices.getPayableSalary(employee.userId!);
          print('EmployeeCubit fetchUsers: userId = ${employee.userId}, payableSalary = ${payableSalaries[employee.userId!]}');
        }
      }

      emit(UserListLoaded(employees, payableSalaries));
    } catch (e) {
      final errorMessage = e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Unknown error occurred';
      print('EmployeeCubit fetchUsers error: $errorMessage');
      emit(UserListError('Failed to fetch employees: $errorMessage'));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      emit(UserDeleting());
      await _employeeServices.deleteUser(userId);
      await fetchUsers(); // Refetch to update the employee list
    } catch (e) {
      final errorMessage = e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Unknown error occurred';
      print('EmployeeCubit deleteUser error: $errorMessage');
      emit(UserListError('Failed to delete employee: $errorMessage'));
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