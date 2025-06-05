import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_repository.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';

abstract class ITaxiBookingService {
  Future<void> createBooking(TaxiBooking booking);

  Future<List<TaxiBooking>> getBookings({
    String? bookingId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? taxiTypeId,
    String? serviceTypeId,
    String? tripTypeId,
    String? acceptedByDriverId,
    double? minTotalFareAmount,
    double? maxTotalFareAmount,
    String? userId,
  });

  Future<void> updateBookingStatus(String bookingId, String status);

  Future<void> acceptBooking(String bookingId, UserInfo? driver);

  Future<void> assignBooking(
      String bookingId, UserInfo driver, String? currentAcceptedByDriverId);

  Future<void> unAssignBooking(
    String bookingId,
  );

  Future<VisitorCounter> getVisitorCounter(String date);

  Future<void> updateBookingCompletedTime(String id);

  Future<void> updateBookingStartTime(String id);
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
    final userInfo = await _accountRepository.getUserInfo();

    await _repository.createBooking(
        companyId, booking.copyWith(bookedByUserId: userInfo?.userId ?? ''));
  }

  @override
  Future<List<TaxiBooking>> getBookings({
    String? bookingId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? taxiTypeId,
    String? serviceTypeId,
    String? tripTypeId,
    String? acceptedByDriverId,
    double? minTotalFareAmount,
    double? maxTotalFareAmount,
    String? userId,
  }) async {
    final companyId = await _getCompanyId();
    return await _repository.getBookings(
      companyId,
      bookingId: bookingId,
      status: status,
      startDate: startDate,
      endDate: endDate,
      taxiTypeId: taxiTypeId,
      serviceTypeId: serviceTypeId,
      tripTypeId: tripTypeId,
      acceptedByDriverId: acceptedByDriverId,
      minTotalFareAmount: minTotalFareAmount,
      maxTotalFareAmount: maxTotalFareAmount,
    );
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final companyId = await _getCompanyId();
    await _repository.updateBookingStatus(companyId, bookingId, status);
  }

  @override
  Future<void> acceptBooking(String bookingId, UserInfo? driver) async {
    final companyId = await _getCompanyId();
    final userInfo = await _accountRepository.getUserInfo();
    await _repository.acceptBooking(companyId, bookingId, driver ?? userInfo);
  }

  @override
  Future<void> assignBooking(String bookingId, UserInfo driver,
      String? currentAcceptedByDriverId) async {
    final companyId = await _getCompanyId();
    await _repository.assignBooking(
        companyId, bookingId, driver, currentAcceptedByDriverId);
  }

  @override
  Future<VisitorCounter> getVisitorCounter(String date) async {
    final companyId = await _getCompanyId();
    return await _repository.getVisitorCounter(companyId, date);
  }

  @override
  Future<void> unAssignBooking(
    String bookingId,
  ) async {
    final companyId = await _getCompanyId();
    await _repository.unAssignedBooking(
      companyId,
      bookingId,
    );
  }

  @override
  Future<void> updateBookingCompletedTime(String id) async {
    final companyId = await _getCompanyId();
    await _repository.updateBookingCompletedTime(
      companyId,
      id,
    );
  }

  @override
  Future<void> updateBookingStartTime(String id) async {
    final companyId = await _getCompanyId();
    await _repository.updateBookingStartTime(
      companyId,
      id,
    );
  }
}
