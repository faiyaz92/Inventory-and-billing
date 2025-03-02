import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/user_service.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';


class UserServiceImpl implements IUserService {
  final AccountRepository _accountRepository;

  UserServiceImpl(this._accountRepository);

  @override
  Future<UserInfo> getLoggedInUserInfo() async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null) {
      throw Exception("User not found");
    }
    return userInfo;
  }
}