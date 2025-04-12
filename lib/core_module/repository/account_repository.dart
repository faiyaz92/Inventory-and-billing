
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';

abstract class AccountRepository {
  Future<UserInfoDto> signIn(String email, String password); // Fixed return type
  Future<void> signOut();
  bool isUserLoggedIn(); // Check if a user session exists
  Future<UserInfo?> getUserInfo(); // ✅ Added missing method
}
