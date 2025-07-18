import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/store_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

class AddUserCubit extends Cubit<AddUserState> {
  final UserServices _companyOperationsService;
  final StoreService _storeService;
  final IAccountLedgerService _accountLedgerService;
  final StockService _stockService;

  AddUserCubit(this._companyOperationsService, this._storeService,
      this._accountLedgerService, this._stockService)
      : super(AddUserInitial());

  Future<void> addUser(UserInfo userInfo, String password) async {
    try {
      emit(AddUserLoading());
      // final users = await _companyOperationsService.getUsersFromTenantCompany();

      // if (users.length >= 5) {
      //   emit(AddUserFailure('Cannot add more than 5 users in the free version'));
      //   return;
      // }

      // Validate mandatory fields for Employee
      if (userInfo.userType == UserType.Employee) {
        if (userInfo.email == null || userInfo.email!.isEmpty) {
          emit(AddUserFailure('Email is required for Employee'));
          return;
        }
        if (userInfo.userName == null || userInfo.userName!.isEmpty) {
          emit(AddUserFailure('Username is required for Employee'));
          return;
        }
        if (userInfo.dailyWage == null || userInfo.dailyWage! <= 0) {
          emit(AddUserFailure('Valid daily wage is required for Employee'));
          return;
        }
        if (userInfo.role == null) {
          emit(AddUserFailure('Role is required for Employee'));
          return;
        }
        if (userInfo.storeId == null) {
          emit(AddUserFailure('Store is required for Employee'));
          return;
        }
        if (password.isEmpty || password.length < 6) {
          emit(AddUserFailure(
              'Password must be at least 6 characters for Employee'));
          return;
        }
      } else if (userInfo.name == null || userInfo.name!.isEmpty) {
        emit(AddUserFailure('Name is required for all user types'));
        return;
      }

      // Ensure userType is set
      if (userInfo.userType == null) {
        emit(AddUserFailure('User type is required'));
        return;
      }

      // Fetch default store ID if not provided
      final storeId =
          userInfo.storeId ?? await _storeService.getDefaultStoreId();
      final updatedUserInfo = userInfo.copyWith(
        storeId: storeId,
        dailyWage: userInfo.dailyWage ?? 500.0,
        userType: userInfo.userType ?? UserType.Employee,
      );

    final userId =   await _companyOperationsService.addUserToCompany(
          updatedUserInfo, password);
      if(userInfo.role == Role.SALES_MAN) {
        await _stockService.addSalesmanAsStore(updatedUserInfo.copyWith(userId: userId));
      }
       emit(AddUserSuccess());
    } catch (e) {
      // Ensure the error is a meaningful string
      emit(AddUserFailure('Failed to add user: ${e.toString()}'));
    }
  }

  Future<void> updateUser(UserInfo userInfo) async {
    try {
      emit(AddUserLoading());

      // Validate mandatory fields for Employee
      if (userInfo.userType == UserType.Employee) {
        if (userInfo.email == null || userInfo.email!.isEmpty) {
          emit(AddUserFailure('Email is required for Employee'));
          return;
        }
        if (userInfo.userName == null || userInfo.userName!.isEmpty) {
          emit(AddUserFailure('Username is required for Employee'));
          return;
        }
        if (userInfo.dailyWage == null || userInfo.dailyWage! <= 0) {
          emit(AddUserFailure('Valid daily wage is required for Employee'));
          return;
        }
        if (userInfo.role == null) {
          emit(AddUserFailure('Role is required for Employee'));
          return;
        }
        if (userInfo.storeId == null) {
          emit(AddUserFailure('Store is required for Employee'));
          return;
        }
      } else if (userInfo.name == null || userInfo.name!.isEmpty) {
        emit(AddUserFailure('Name is required for all user types'));
        return;
      }

      // Ensure userType is set
      if (userInfo.userType == null) {
        emit(AddUserFailure('User type is required'));
        return;
      }

      // Fetch default store ID if not provided
      final storeId =
          userInfo.storeId ?? await _storeService.getDefaultStoreId();
      final updatedUserInfo = userInfo.copyWith(
        storeId: storeId,
        dailyWage: userInfo.dailyWage ?? 500.0,
        userType: userInfo.userType ?? UserType.Employee,
      );

      await _companyOperationsService.updateUser(updatedUserInfo);
      emit(AddUserSuccess());
    } catch (e) {
      // Ensure the error is a meaningful string
      emit(AddUserFailure('Failed to update user: ${e.toString()}'));
    }
  }
}

abstract class AddUserState {}

class AddUserInitial extends AddUserState {}

class AddUserLoading extends AddUserState {}

class AddUserSuccess extends AddUserState {}

class AddUserFailure extends AddUserState {
  final String error;

  AddUserFailure(this.error);
}
