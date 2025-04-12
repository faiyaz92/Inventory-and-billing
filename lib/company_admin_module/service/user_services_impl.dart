import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart'; // ✅ Import UserInfo
import 'package:requirment_gathering_app/super_admin_module/repository/tenant_company_repository.dart';

class UserServicesImpl implements UserServices {
  final ITenantCompanyRepository _tenantCompanyRepository;
  final AccountRepository _accountRepository;

  UserServicesImpl(this._tenantCompanyRepository, this._accountRepository);

  @override
  Future<void> addUserToCompany(UserInfo userInfo, String password) async {
    final loggedInUserInfo = await _accountRepository.getUserInfo();
    userInfo = userInfo.copyWith(companyId: loggedInUserInfo?.companyId ?? '');
    await _tenantCompanyRepository.addUserToCompany(userInfo.toDto(), password);
  }

  @override
  Future<List<UserInfo>> getUsersFromTenantCompany() async {
    final userInfo = await _accountRepository.getUserInfo();
    final userDtos = await _tenantCompanyRepository
        .getUsersFromTenantCompany(userInfo?.companyId ?? '');
    return userDtos.map((dto) => UserInfo.fromDto(dto)).toList();
  }

  @override
  Future<void> deleteUser(String userId) async {
    final userInfo = await _accountRepository.getUserInfo();
    await _tenantCompanyRepository.deleteUser(
        userId, userInfo?.companyId ?? '');
  }
}
