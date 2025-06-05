import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/store_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

class AddUserCubit extends Cubit<AddUserState> {
  final UserServices _companyOperationsService;
  final StoreService _storeService;
  final IAccountLedgerService _accountLedgerService;

  AddUserCubit(this._companyOperationsService, this._storeService,
      this._accountLedgerService)
      : super(AddUserInitial());

  Future<void> addUser(UserInfo userInfo, String password) async {
    try {
      emit(AddUserLoading());
      final users = await _companyOperationsService.getUsersFromTenantCompany();

      if (users.length <= 5) {
        // Fetch default store ID if storeId is not provided
        final storeId =
            userInfo.storeId ?? await _storeService.getDefaultStoreId();
        final updatedUserInfo = userInfo.copyWith(
          storeId: storeId,
          dailyWage: userInfo.dailyWage ?? 500.0, // Default daily wage
        );
        String userId = await _companyOperationsService.addUserToCompany(
            updatedUserInfo, password);
        final newLedger = AccountLedger(
          totalOutstanding: 0,
          promiseAmount: null,
          promiseDate: null,
          transactions: [],
        );
        String ledgerId = await _accountLedgerService.createLedger(newLedger);
        _companyOperationsService.updateUser(
            userInfo.copyWith(userId: userId, accountLedgerId: ledgerId));
        emit(AddUserSuccess());
      } else {
        emit(AddUserFailure('Cannot add more than 5 users in free version'));
      }
    } catch (e) {
      emit(AddUserFailure(e.toString()));
    }
  }

  Future<void> updateUser(UserInfo userInfo) async {
    try {
      emit(AddUserLoading());
      // Fetch default store ID if storeId is not provided
      final storeId =
          userInfo.storeId ?? await _storeService.getDefaultStoreId();
      final updatedUserInfo = userInfo.copyWith(
        storeId: storeId,
        dailyWage: userInfo.dailyWage ?? 500.0, // Default daily wage
      );
      await _companyOperationsService.updateUser(updatedUserInfo);
      emit(AddUserSuccess());
    } catch (e) {
      emit(AddUserFailure(e.toString()));
    }
  }
}

/// States for `AddUserCubit`
abstract class AddUserState {}

class AddUserInitial extends AddUserState {}

class AddUserLoading extends AddUserState {}

class AddUserSuccess extends AddUserState {}

class AddUserFailure extends AddUserState {
  final String error;

  AddUserFailure(this.error);
}
