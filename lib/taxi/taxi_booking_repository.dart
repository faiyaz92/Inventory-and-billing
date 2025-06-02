import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider_impl.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';


abstract class ITaxiBookingRepository {
  Future<void> createBooking(String companyId,TaxiBooking booking);

  Future<List<TaxiBooking>> getBookings(String companyId,
      {String? status, DateTime? startDate, DateTime? endDate});

  Future<void> updateBookingStatus(String companyId, String bookingId,
      String status);

  Future<void> acceptBooking(String companyId, String bookingId,
      UserInfo driver);

  Future<void> updateVisitorCounter(String companyId, String date);

  Future<VisitorCounter> getVisitorCounter(String companyId, String date);
}

class TaxiBookingRepositoryImpl implements ITaxiBookingRepository {
  final IFirestorePathProvider _pathProvider;
  TaxiBookingRepositoryImpl(this._pathProvider,);

  @override
  Future<void> createBooking(String companyId,TaxiBooking booking) async {
    final dto = TaxiBookingDto.fromModel(booking);
    await _pathProvider.getTaxiBookingsCollectionRef(companyId).add(dto.toFirestore());
  }

  @override
  Future<List<TaxiBooking>> getBookings(
      String companyId, {String? status, DateTime? startDate, DateTime? endDate}) async {

    Query<Object?> query = _pathProvider.getTaxiBookingsCollectionRef(companyId);
    if (status != null) query = query.where('tripStatus', isEqualTo: status);
    if (startDate != null) {
      query = query.where(
          'date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query =
          query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TaxiBooking.fromDto(
        TaxiBookingDto.fromFirestore(doc.data() as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<void> updateBookingStatus(String companyId, String bookingId,
      String status) async {
    await _pathProvider.getTaxiBookingsCollectionRef(companyId)
        .doc(bookingId)
        .update({'tripStatus': status});
  }

  @override
  Future<void> acceptBooking(String companyId, String bookingId,
      UserInfo driver) async {
    await _pathProvider.getTaxiBookingsCollectionRef(companyId)
        .doc(bookingId)
        .update({
      'accepted': true,
      'acceptedByUserId': driver.userId,
      'acceptedByUserName': driver.userName,
      'tripStatus': 'confirmed',
    });
  }

  @override
  Future<void> updateVisitorCounter(String companyId, String date) async {
    final ref = _pathProvider.getVisitorCountersCollectionRef(companyId).doc(
        date);
    await _pathProvider.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        transaction.set(ref, VisitorCounterDto(
            count: 1, lastUpdated: DateTime.now(), page: 'TaxiBookingPage')
            .toFirestore());
      } else {
        transaction.update(ref, {
          'count': FieldValue.increment(1),
          'lastUpdated': Timestamp.fromDate(DateTime.now())
        });
      }
    });
  }

  @override
  Future<VisitorCounter> getVisitorCounter(String companyId,
      String date) async {
    final snapshot = await _pathProvider.getVisitorCountersCollectionRef(
        companyId).doc(date).get();
    if (!snapshot.exists) {
      return VisitorCounter(
          count: 0, lastUpdated: DateTime.now(), page: 'TaxiBookingPage');
    }
    return VisitorCounter.fromDto(VisitorCounterDto.fromFirestore(
        snapshot.data() as Map<String, dynamic>));
  }
}
