import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final UserServices _employeeServices;

  AttendanceCubit(this._employeeServices) : super(AttendanceInitial());

  Future<void> fetchUsers({String? date}) async {
    try {
      emit(AttendanceLoading());
      // Fetch all users and filter for employees only
      final allUsers = await _employeeServices.getUsersFromTenantCompany();
      final employees = allUsers.where((user) => user.userType == UserType.Employee).toList();
      // Fetch attendance for the given date (or today) for employees
      final dateToFetch = date ?? DateFormat('dd-MM-yyyy').format(DateTime.now());
      final attendanceMap = await _fetchAttendanceForUsers(employees, dateToFetch);
      emit(AttendanceLoaded(users: employees, attendance: attendanceMap));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<Map<String, AttendanceModel>> _fetchAttendanceForUsers(List<UserInfo> users, String date) async {
    final attendanceMap = <String, AttendanceModel>{};
    final month = DateFormat('yyyy-MM').format(DateFormat('dd-MM-yyyy').parse(date));
    for (var user in users) {
      // Only process users with a valid userId and of type Employee
      if (user.userId != null && user.userType == UserType.Employee) {
        final attendanceList = await _employeeServices.getAttendance(user.userId!, month);
        // Find attendance for the specific date
        final attendance = attendanceList.firstWhere(
              (a) => a.date == date,
          orElse: () => AttendanceModel(date: date, status: 'absent'), // Default to absent if no record
        );
        attendanceMap[user.userId!] = attendance;
      }
    }
    return attendanceMap;
  }

  Future<void> markAttendance(String userId, AttendanceModel attendance) async {
    try {
      await _employeeServices.markAttendance(userId, attendance);
      // Update attendance map with the new status
      final currentState = state as AttendanceLoaded;
      final updatedAttendance = Map<String, AttendanceModel>.from(currentState.attendance);
      updatedAttendance[userId] = attendance;
      emit(AttendanceLoaded(
        users: currentState.users,
        attendance: updatedAttendance,
      ));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> fetchAttendance(String date) async {
    try {
      emit(AttendanceLoading());
      // Fetch all users and filter for employees only
      final allUsers = await _employeeServices.getUsersFromTenantCompany();
      final employees = allUsers.where((user) => user.userType == UserType.Employee).toList();
      final attendanceMap = await _fetchAttendanceForUsers(employees, date);
      emit(AttendanceLoaded(users: employees, attendance: attendanceMap));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<UserInfo> users;
  final Map<String, AttendanceModel> attendance;

  AttendanceLoaded({required this.users, required this.attendance});

  @override
  List<Object?> get props => [users, attendance];
}

class AttendanceError extends AttendanceState {
  final String error;

  AttendanceError(this.error);

  @override
  List<Object?> get props => [error];
}