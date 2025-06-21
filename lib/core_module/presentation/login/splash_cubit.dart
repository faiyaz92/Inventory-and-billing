import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class SplashState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class NavigateToDashboard extends SplashState {}

class NavigateToLogin extends SplashState {}


class SplashCubit extends Cubit<SplashState> {
  final AccountRepository _accountRepository;

  SplashCubit(this._accountRepository) : super(SplashInitial());

  void checkSession() {
    final isLoggedIn = _accountRepository.isUserLoggedIn();
    // emit(NavigateToLogin());

    if (isLoggedIn) {
      emit(NavigateToLogin());

      // emit(NavigateToDashboard());
    } else {
      emit(NavigateToLogin());
    }
  }
}
