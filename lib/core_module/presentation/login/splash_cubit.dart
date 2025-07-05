import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

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

class SplashError extends SplashState {
  final String message;
  SplashError(this.message);

  @override
  List<Object?> get props => [message];
}

class SplashCubit extends Cubit<SplashState> {
  final AccountRepository _accountRepository;

  SplashCubit(this._accountRepository) : super(SplashInitial());

  Future<void> checkSession() async {
    print('SplashCubit: Starting session check');
    try {
      final isLoggedIn = _accountRepository.isUserLoggedIn();
      print('SplashCubit: isLoggedIn result: $isLoggedIn');
      if (isLoggedIn) {
        emit(NavigateToDashboard());
      } else {
        emit(NavigateToLogin());
      }
    } catch (e) {
      print('SplashCubit: Error in checkSession: $e');
      emit(SplashError('Failed to check session: $e'));
    }
  }

  void emitError(String message) {
    print('SplashCubit: Emitting error: $message');
    emit(SplashError(message));
  }
}
