import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

class AddUserCubit extends Cubit<AddUserState> {
  final UserServices _companyOperationsService;

  AddUserCubit(this._companyOperationsService) : super(AddUserInitial());

  Future<void> addUser(UserInfo userInfo, String password) async {
    try {
      emit(AddUserLoading());

      await _companyOperationsService.addUserToCompany(userInfo, password);

      emit(AddUserSuccess());
    } catch (e) {
      emit(AddUserFailure(e.toString()));
    }
  }
}

/// 🔹 States for `AddUserCubit`
abstract class AddUserState {}

class AddUserInitial extends AddUserState {}

class AddUserLoading extends AddUserState {}

class AddUserSuccess extends AddUserState {}

class AddUserFailure extends AddUserState {
  final String error;
  AddUserFailure(this.error);
}
