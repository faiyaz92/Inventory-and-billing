import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/login/login_state.dart';
import 'package:requirment_gathering_app/services/login_service.dart';



// LoginCubit
class LoginCubit extends Cubit<LoginState> {
  final LoginService _loginService;

  LoginCubit(this._loginService) : super(LoginInitial());

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
      await _loginService.signIn(email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _loginService.signOut();
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
