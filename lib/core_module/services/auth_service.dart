abstract class AuthService{
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  bool isUserLoggedIn(); //
}