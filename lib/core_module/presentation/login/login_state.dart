// States for Login
import 'package:equatable/equatable.dart';

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