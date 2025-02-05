import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/data/company_setting%20_dto.dart';
import 'package:requirment_gathering_app/data/company_settings.dart';
import 'package:requirment_gathering_app/repositories/company_settings_repository.dart';


class CompanySettingRepositoryImpl implements CompanySettingRepository {
  final FirebaseFirestore _firestore;

  CompanySettingRepositoryImpl(this._firestore);

  @override
  Future<Either<Exception, CompanySettingsUi>> getSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('companySettings').get();
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
  Future<Either<Exception, void>> updateSettings(CompanySettingsUi settings) async {
    try {
      final dto = CompanySettingDto.fromUiModel(settings);
      await _firestore.collection('settings').doc('companySettings').set(dto.toMap());
      return Right(null);
    } catch (e) {
      return Left(Exception('Failed to update settings: $e'));
    }
  }
}
