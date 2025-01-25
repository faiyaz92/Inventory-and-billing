import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/repositories/account_repository.dart';
import 'package:equatable/equatable.dart';

// States for Login
abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class EmailValidationError extends LoginState {
  final String error;

  EmailValidationError(this.error);

  @override
  List<Object?> get props => [error];
}

class PasswordValidationError extends LoginState {
  final String error;

  PasswordValidationError(this.error);

  @override
  List<Object?> get props => [error];
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// LoginCubit
class LoginCubit extends Cubit<LoginState> {
  final AccountRepository _accountRepository;

  LoginCubit(this._accountRepository) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      emit(EmailValidationError("Invalid or missing email."));
      return;
    }

    if (password.isEmpty) {
      emit(PasswordValidationError("Password is required."));
      return;
    }

    emit(LoginLoading());
    try {
      await _accountRepository.signIn(email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _accountRepository.signOut();
    emit(LoginInitial());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
  void validateEmail(String email) {
    if (email.isEmpty) {
      emit(EmailValidationError("Email is required."));
    } else if (!_isValidEmail(email)) {
      emit(EmailValidationError("Invalid email format."));
    } else {
      emit(LoginInitial()); // Clear any previous error
    }
  }
  void validatePassword(String password) {
    if (password.isEmpty) {
      emit(PasswordValidationError("Password is required."));
    } else {
      emit(LoginInitial()); // Clear any previous error
    }
  }

}
