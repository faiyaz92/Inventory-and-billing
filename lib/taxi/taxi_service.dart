import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_repository.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';

abstract class ITaxiBookingService {
  Future<void> createBooking(TaxiBooking booking);
  Future<List<TaxiBooking>> getBookings({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> updateBookingStatus(String bookingId, String status);
  Future<void> acceptBooking(String bookingId, UserInfo driver);
  Future<VisitorCounter> getVisitorCounter(String date);
}

class TaxiBookingServiceImpl implements ITaxiBookingService {
  final ITaxiBookingRepository _repository;
  final AccountRepository _accountRepository;

  TaxiBookingServiceImpl(this._repository, this._accountRepository);

  Future<String> _getCompanyId() async {
    final userInfo = await _accountRepository.getUserInfo();
    return userInfo?.companyId ?? '';
  }

  @override
  Future<void> createBooking(TaxiBooking booking) async {
    final companyId = await _getCompanyId();
    await _repository.createBooking(companyId,booking);
  }

  @override
  Future<List<TaxiBooking>> getBookings({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final companyId = await _getCompanyId();

    return await _repository.getBookings(
      companyId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final companyId = await _getCompanyId();
    await _repository.updateBookingStatus(companyId, bookingId, status);
  }

  @override
  Future<void> acceptBooking(String bookingId, UserInfo driver) async {
    final companyId = await _getCompanyId();
    await _repository.acceptBooking(companyId, bookingId, driver);
  }

  @override
  Future<VisitorCounter> getVisitorCounter(String date) async {
    final companyId = await _getCompanyId();
    return await _repository.getVisitorCounter(companyId, date);
  }
}