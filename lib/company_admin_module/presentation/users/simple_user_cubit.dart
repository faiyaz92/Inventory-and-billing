import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

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

class SimpleUserCubit extends Cubit<EmployeesState> {
  final UserServices _employeeServices;
  String searchQuery = '';
  UserType? selectedUserType;
  Role? selectedRole;
  List<UserInfo> allUsers = [];

  SimpleUserCubit(this._employeeServices) : super(UserListInitial());

  Future<void> fetchUsers() async {
    try {
      emit(UserListLoading());
      allUsers = await _employeeServices.getUsersFromTenantCompany();
      filterUsers(searchQuery: searchQuery, userType: selectedUserType, role: selectedRole);
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  void filterUsers({String? searchQuery, UserType? userType, Role? role}) {
    this.searchQuery = searchQuery ?? this.searchQuery;
    this.selectedUserType = userType ?? this.selectedUserType;
    this.selectedRole = role ?? this.selectedRole;

    List<UserInfo> filteredUsers = allUsers;

    // Apply search filter
    if (this.searchQuery.isNotEmpty) {
      final query = this.searchQuery.toLowerCase();
      filteredUsers = filteredUsers.where((user) {
        final name = user.name?.toLowerCase() ?? '';
        final email = user.email?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    // Apply user type filter
    if (this.selectedUserType != null) {
      filteredUsers = filteredUsers.where((user) => user.userType == this.selectedUserType).toList();
    }

    // Apply role filter if Employee is selected
    if (this.selectedUserType == UserType.Employee && this.selectedRole != null) {
      filteredUsers = filteredUsers.where((user) => user.role == this.selectedRole).toList();
    }

    emit(UserListLoaded(filteredUsers));
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