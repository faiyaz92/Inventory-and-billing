import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/data/company_setting%20_dto.dart';
import 'package:requirment_gathering_app/data/company_settings.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';

class CompanySettingRepositoryImpl implements CompanySettingRepository {
  final FirebaseFirestore _firestore;

  CompanySettingRepositoryImpl(this._firestore);

  @override
  Future<CompanySettingsUi> getSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('companySettings').get();
      if (doc.exists) {
        // Fetch data as DTO and convert to UI model
        final dto = CompanySettingDto.fromMap(doc.data()!);
        return dto.toUiModel();
      } else {
        return CompanySettingsUi.initial();
      }
    } catch (e) {
      throw Exception('Failed to fetch settings: $e');
    }
  }

  @override
  Future<void> updateSettings(CompanySettingsUi settings) async {
    try {
      // Convert UI model to DTO and save
      final dto = CompanySettingDto.fromUiModel(settings);
      await _firestore.collection('settings').doc('companySettings').set(dto.toMap());
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
}
