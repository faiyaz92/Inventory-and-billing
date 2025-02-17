import 'package:dartz/dartz.dart';
import 'package:requirment_gathering_app/user_module/data/company_settings.dart';

abstract class CompanySettingRepository {
  Future<Either<Exception, CompanySettingsUi>> getSettings();
  Future<Either<Exception, void>> updateSettings(CompanySettingsUi settings);
}
