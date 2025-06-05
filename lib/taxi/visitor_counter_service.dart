import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_repository.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';

abstract class IVisitorCounterService {
  Future<void> updateVisitorCounter(String date);
  Future<VisitorCounter> getVisitorCounter(String date);
}

class VisitorCounterServiceImpl implements IVisitorCounterService {
  final ITaxiBookingRepository _repository;
  final AccountRepository _accountRepository;

  VisitorCounterServiceImpl(this._repository, this._accountRepository);

  Future<String> _getCompanyId() async {
    final userInfo = await _accountRepository.getUserInfo();
    return userInfo?.companyId ?? '';
  }

  @override
  Future<void> updateVisitorCounter(String date) async {
    final companyId = await _getCompanyId();
    await _repository.updateVisitorCounter(companyId, date);
  }

  @override
  Future<VisitorCounter> getVisitorCounter(String date) async {
    final companyId = await _getCompanyId();
    return await _repository.getVisitorCounter(companyId, date);
  }
}