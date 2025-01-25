abstract class AccountRepository {
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  bool isUserLoggedIn(); // Check if a user session exists
}
