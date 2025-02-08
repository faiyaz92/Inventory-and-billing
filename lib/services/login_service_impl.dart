import 'package:requirment_gathering_app/repositories/account_repository.dart';
import 'package:requirment_gathering_app/services/login_service.dart';

class LoginServiceImpl implements LoginService {
  final AccountRepository _accountRepository;

  LoginServiceImpl(this._accountRepository);

  @override
  Future<void> signIn(String email, String password) async {
    await _accountRepository.signIn(
       email,
       password,
    );
  }

  @override
  Future<void> signOut() async {
    await _accountRepository.signOut();
  }

  @override
  bool isUserLoggedIn() {
    return _accountRepository.isUserLoggedIn(); // Check if the user is logged in
  }
}
