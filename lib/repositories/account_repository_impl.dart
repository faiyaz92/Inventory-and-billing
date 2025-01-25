import 'package:firebase_auth/firebase_auth.dart';
import 'account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirebaseAuth _firebaseAuth;

  AccountRepositoryImpl(this._firebaseAuth);

  @override
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null; // Check if the user is logged in
  }
}
