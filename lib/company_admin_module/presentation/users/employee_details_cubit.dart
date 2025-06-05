import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/attendance/attendance_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  final UserServices _employeeServices;

  EmployeeDetailsCubit(this._employeeServices) : super(EmployeeDetailsInitial());

  Future<void> loadData(String userId, {String? month}) async {
    try {
      emit(EmployeeDetailsLoading());
      final users = await _employeeServices.getUsersFromTenantCompany();
      final user = users.firstWhere((u) => u.userId == userId);
      final attendance = await _employeeServices.getAttendance(userId, month ?? DateTime.now().toIso8601String().substring(0, 7));
      final ledger = await _employeeServices.getLedger(userId, month);
      final advanceBalance = await _employeeServices.getAdvanceBalance(userId);
      emit(EmployeeDetailsLoaded(user, attendance, ledger, advanceBalance));
    } catch (e) {
      emit(EmployeeDetailsError(e.toString()));
    }
  }

  Future<void> recordSalaryPayment(String userId, double amount, String month) async {
    try {
      await _employeeServices.recordSalaryPayment(userId, amount, month);
      await loadData(userId, month: month);
    } catch (e) {
      emit(EmployeeDetailsError(e.toString()));
    }
  }

  Future<void> recordAdvanceSalary(String userId, double amount, String date) async {
    try {
      await _employeeServices.recordAdvanceSalary(userId, amount, date);
      await loadData(userId, month: date.substring(0, 7));
    } catch (e) {
      emit(EmployeeDetailsError(e.toString()));
    }
  }

  Future<void> finalizeMonth(String userId, String month) async {
    try {
      await _employeeServices.finalizeMonth(userId, month);
      await loadData(userId, month: month);
    } catch (e) {
      emit(EmployeeDetailsError(e.toString()));
    }
  }
}

abstract class EmployeeDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeDetailsInitial extends EmployeeDetailsState {}

class EmployeeDetailsLoading extends EmployeeDetailsState {}

class EmployeeDetailsLoaded extends EmployeeDetailsState {
  final UserInfo user;
  final List<AttendanceModel> attendance;
  final List<Map<String, dynamic>> ledger;
  final double advanceBalance;

  EmployeeDetailsLoaded(this.user, this.attendance, this.ledger, this.advanceBalance);

  @override
  List<Object?> get props => [user, attendance, ledger, advanceBalance];
}

class EmployeeDetailsError extends EmployeeDetailsState {
  final String error;
  EmployeeDetailsError(this.error);

  @override
  List<Object?> get props => [error];
}