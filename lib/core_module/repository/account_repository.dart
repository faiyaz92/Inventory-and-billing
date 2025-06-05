
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';

abstract class AccountRepository {
  Future<UserInfoDto> signIn(String email, String password);
  Future<void> signOut();
  bool isUserLoggedIn();
  Future<UserInfo?> getUserInfo();
  Future<void> resetPassword(String email);
}
