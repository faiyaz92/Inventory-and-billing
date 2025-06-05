import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/services/user_service.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final Role role;

  HomeLoaded(this.userName, this.role);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final IUserService _userService;

  HomeCubit(this._userService) : super(HomeInitial());

  Future<void> fetchUserInfo() async {
    emit(HomeLoading());
    try {
      final userInfo = await _userService.getLoggedInUserInfo();
      emit(HomeLoaded(userInfo.userName ?? '', userInfo.role ?? Role.USER));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}