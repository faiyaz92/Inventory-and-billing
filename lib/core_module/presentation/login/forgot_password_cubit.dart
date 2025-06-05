import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service.dart';


class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthService _authService;

  ForgotPasswordCubit(this._authService) : super(ForgotPasswordInitial());

  Future<void> resetPassword(String email) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      emit(ForgotPasswordFailure("Invalid or missing email."));
      return;
    }

    emit(ForgotPasswordLoading());
    try {
      await _authService.resetPassword(email);
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
}

abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  ForgotPasswordFailure(this.error);
}