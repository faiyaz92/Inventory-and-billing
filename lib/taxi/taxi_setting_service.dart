import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_repository.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';

abstract class ITaxiSettingsService {
  Future<TaxiSettings> getSettings();
  Future<void> updateSettings(TaxiSettings settings);
  Future<void> addTaxiType(TaxiType type);
  Future<void> deleteTaxiType(String typeId);
  Future<void> addTripType(TripType type);
  Future<void> deleteTripType(String typeId);
  Future<void> addServiceType(ServiceType type);
  Future<void> deleteServiceType(String typeId);
  Future<void> addTripStatus(TripStatus status);
  Future<void> deleteTripStatus(String statusId);
}

class TaxiSettingsServiceImpl implements ITaxiSettingsService {
  final ITaxiSettingsRepository _repository;
  final AccountRepository _accountRepository;

  TaxiSettingsServiceImpl(this._repository, this._accountRepository);

  Future<String> _getCompanyId() async {
    final userInfo = await _accountRepository.getUserInfo();
    return userInfo?.companyId ?? '';
  }

  @override
  Future<TaxiSettings> getSettings() async {
    final companyId = await _getCompanyId();
    return await _repository.getSettings(companyId);
  }

  @override
  Future<void> updateSettings(TaxiSettings settings) async {
    final companyId = await _getCompanyId();
    final userInfo = await _accountRepository.getUserInfo();
    await _repository.updateSettings(
      companyId,
      settings.copyWith(
        updatedAt: DateTime.now(),
        updatedBy: userInfo?.userId ?? '',
      ),
    );
  }

  @override
  Future<void> addTaxiType(TaxiType type) async {
    final companyId = await _getCompanyId();
    final userInfo = await _accountRepository.getUserInfo();
    await _repository.addTaxiType(
      companyId,
      type.copyWith(
        createdAt: DateTime.now(),
        createdBy: userInfo?.userId ?? '',
      ),
    );
  }

  @override
  Future<void> deleteTaxiType(String typeId) async {
    final companyId = await _getCompanyId();
    await _repository.deleteTaxiType(companyId, typeId);
  }

  @override
  Future<void> addTripType(TripType type) async {
    final companyId = await _getCompanyId();
    final userInfo = await _accountRepository.getUserInfo();
    await _repository.addTripType(
      companyId,
      type.copyWith(
        createdAt: DateTime.now(),
        createdBy: userInfo?.userId ?? '',
      ),
    );
  }

  @override
  Future<void> deleteTripType(String typeId) async {
    final companyId = await _getCompanyId();
    await _repository.deleteTripType(companyId, typeId);
  }

  @override
  Future<void> addServiceType(ServiceType type) async {
    final companyId = await _getCompanyId();
    final userInfo = await _accountRepository.getUserInfo();
    await _repository.addServiceType(
      companyId,
      type.copyWith(
        createdAt: DateTime.now(),
        createdBy: userInfo?.userId ?? '',
      ),
    );
  }

  @override
  Future<void> deleteServiceType(String typeId) async {
    final companyId = await _getCompanyId();
    await _repository.deleteServiceType(companyId, typeId);
  }

  @override
  Future<void> addTripStatus(TripStatus status) async {
    final companyId = await _getCompanyId();
    final userInfo = await _accountRepository.getUserInfo();
    await _repository.addTripStatus(
      companyId,
      status.copyWith(
        createdAt: DateTime.now(),
        createdBy: userInfo?.userId ?? '',
      ),
    );
  }

  @override
  Future<void> deleteTripStatus(String statusId) async {
    final companyId = await _getCompanyId();
    await _repository.deleteTripStatus(companyId, statusId);
  }
}