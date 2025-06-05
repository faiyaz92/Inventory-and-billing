import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final AccountRepository _accountRepository;

  AuthServiceImpl(this._accountRepository);

  @override
  Future<void> signIn(String email, String password) async {
    await _accountRepository.signIn(email, password);
  }

  @override
  Future<void> signOut() async {
    await _accountRepository.signOut();
  }

  @override
  bool isUserLoggedIn() {
    return _accountRepository.isUserLoggedIn();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _accountRepository.resetPassword(email);
  }
}
