import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

abstract class IUserService {
  Future<UserInfo> getLoggedInUserInfo();
}