import 'package:requirment_gathering_app/data/company_settings.dart';

abstract class CompanySettingRepository {
  Future<CompanySettingsUi> getSettings();
  Future<void> updateSettings(CompanySettingsUi settings);
}
