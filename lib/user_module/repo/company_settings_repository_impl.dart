import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/data/company_setting%20_dto.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';
import 'package:requirment_gathering_app/user_module/repo/company_settings_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class CompanySettingRepositoryImpl implements CompanySettingRepository {
  final IFirestorePathProvider _pathProvider;
  final AccountRepository _accountRepository;

    UserInfo? userInfo;

  CompanySettingRepositoryImpl(
    this._pathProvider,
    this._accountRepository,
  );

  @override
  Future<Either<Exception, CompanySettingsUi>> getSettings() async {
    try {
      userInfo ??= await _accountRepository.getUserInfo();

      final doc = await _pathProvider
          .getTenantCompanyRef(userInfo?.companyId ?? '')
          .collection('settings')
          .doc('companySettings')
          .get();
      if (doc.exists) {
        final dto = CompanySettingDto.fromMap(doc.data()!);
        return Right(dto.toUiModel());
      } else {
        return Right(CompanySettingsUi.initial());
      }
    } catch (e) {
      return Left(Exception('Failed to fetch settings: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> updateSettings(
      CompanySettingsUi settings) async {
    userInfo ??= await _accountRepository.getUserInfo();

    try {
      final dto = CompanySettingDto.fromUiModel(settings);
      await _pathProvider
          .getTenantCompanyRef(userInfo?.companyId ?? '')
          .collection('settings')
          .doc('companySettings')
          .set(dto.toMap());
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update settings: $e'));
    }
  }
}
