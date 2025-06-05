import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/taxi/taxi_booking_model.dart';
import 'package:requirment_gathering_app/taxi/visitior_counter_model.dart';

abstract class ITaxiBookingRepository {
  Future<void> createBooking(String companyId, TaxiBooking booking);

  Future<List<TaxiBooking>> getBookings(
    String companyId, {
    String? userId,
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
  });

  Future<void> updateBookingStatus(
      String companyId, String bookingId, String status);

  Future<void> acceptBooking(
      String companyId, String bookingId, UserInfo? driver);

  Future<void> assignBooking(String companyId, String bookingId,
      UserInfo driver, String? currentAcceptedByDriverId);

  Future<VisitorCounter> getVisitorCounter(String companyId, String date);

  Future<void> updateVisitorCounter(String companyId, String date);

  Future<void> unAssignedBooking(String companyId, String bookingId);

  Future<void> updateBookingCompletedTime(String companyId, String id);

  Future<void> updateBookingStartTime(String companyId, String id);
}

class TaxiBookingRepositoryImpl implements ITaxiBookingRepository {
  final IFirestorePathProvider _pathProvider;
  final AccountRepository _accountRepository;

  TaxiBookingRepositoryImpl(this._pathProvider, this._accountRepository);

  @override
  Future<void> createBooking(String companyId, TaxiBooking booking) async {
    final dto = TaxiBookingDto.fromModel(booking);
    await _pathProvider
        .getTaxiBookingsCollectionRef(companyId)
        .add(dto.toFirestore());
  }

  @override
  Future<List<TaxiBooking>> getBookings(
    String companyId, {
    String? userId,
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
  }) async {
    Query<Object?> query =
        _pathProvider.getTaxiBookingsCollectionRef(companyId);

    if (bookingId != null) {
      final doc = await _pathProvider
          .getTaxiBookingsCollectionRef(companyId)
          .doc(bookingId)
          .get();
      if (doc.exists) {
        return [
          TaxiBooking.fromDto(
            TaxiBookingDto.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id),
          )
        ];
      }
      return [];
    }
    if (userId != null) {
      query = query.where('bookedByUserId', isEqualTo: userId);
    }
    /*   if (status != null) {
      query = query.where('tripStatus', isEqualTo: status);
    }
    if (startDate != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }
   if (taxiTypeId != null) {
      query = query.where('taxiTypeId', isEqualTo: taxiTypeId);
    }
    if (serviceTypeId != null) {
      query = query.where('serviceTypeId', isEqualTo: serviceTypeId);
    }
    if (tripTypeId != null) {
      query = query.where('tripTypeId', isEqualTo: tripTypeId);
    }
    if (acceptedByDriverId != null) {
      query = query.where('acceptedByUserId', isEqualTo: acceptedByDriverId);
    }*/
    /* if (minTotalFareAmount != null) {
      query = query.where('totalFareAmount',
          isGreaterThanOrEqualTo: minTotalFareAmount);
    }
    if (maxTotalFareAmount != null) {
      query = query.where('totalFareAmount',
          isLessThanOrEqualTo: maxTotalFareAmount);
    }*/

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return TaxiBooking.fromDto(
        TaxiBookingDto.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id),
      );
    }).toList();
  }

  @override
  Future<void> updateBookingStatus(
      String companyId, String bookingId, String status) async {
    final userInfo = await _accountRepository.getUserInfo();
    final updates = {
      'tripStatus': status,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
      'lastUpdatedBy': userInfo?.userId,
    };
    await _pathProvider
        .getTaxiBookingsCollectionRef(companyId)
        .doc(bookingId)
        .update(updates);
  }

  @override
  Future<void> acceptBooking(
      String companyId, String bookingId, UserInfo? driver) async {
    final userInfo = await _accountRepository.getUserInfo();
    final updates = {
      'accepted': driver != null,
      'acceptedByUserId': driver != null ? driver.userId ?? '' : '',
      'acceptedByUserName': driver != null ? driver.userName ?? '' : '',
      'tripStatus': 'Accepted',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
      'lastUpdatedBy': userInfo?.userId,
    };
    await _pathProvider
        .getTaxiBookingsCollectionRef(companyId)
        .doc(bookingId)
        .update(updates);
  }

  @override
  Future<void> assignBooking(
    String companyId,
    String bookingId,
    UserInfo driver,
    String? currentAcceptedByDriverId,
  ) async {
    final userInfo = await _accountRepository.getUserInfo();
    final docRef =
        _pathProvider.getTaxiBookingsCollectionRef(companyId).doc(bookingId);
    await _pathProvider.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Booking not found');
      }
      final currentData = snapshot.data() as Map<String, dynamic>;
      final currentDriverId = currentData['acceptedByUserId'] as String?;
      if (currentAcceptedByDriverId != null &&
          currentDriverId != currentAcceptedByDriverId) {
        throw Exception('Driver assignment conflict');
      }
      transaction.update(docRef, {
        'accepted': true,
        'acceptedByUserId': driver.userId ?? '',
        'acceptedByUserName': driver.userName ?? '',
        'tripStatus': 'Accepted',
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
        'lastUpdatedBy': userInfo?.userId,
      });
    });
  }

  @override
  Future<VisitorCounter> getVisitorCounter(
      String companyId, String date) async {
    final snapshot = await _pathProvider
        .getVisitorCountersCollectionRef(companyId)
        .doc(date)
        .get();
    if (!snapshot.exists) {
      return VisitorCounter(
        count: 0,
        lastUpdated: DateTime.now(),
        page: 'TaxiBookingPage',
      );
    }
    return VisitorCounter.fromDto(
      VisitorCounterDto.fromFirestore(snapshot.data() as Map<String, dynamic>),
    );
  }

  @override
  Future<void> updateVisitorCounter(String companyId, String date) async {
    final ref =
        _pathProvider.getVisitorCountersCollectionRef(companyId).doc(date);
    await _pathProvider.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        transaction.set(
          ref,
          VisitorCounterDto(
            count: 1,
            lastUpdated: DateTime.now(),
            page: 'TaxiBookingPage',
          ).toFirestore(),
        );
      } else {
        transaction.update(ref, {
          'count': FieldValue.increment(1),
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        });
      }
    });
  }

  @override
  Future<void> unAssignedBooking(String companyId, String bookingId) async {
    final userInfo = await _accountRepository.getUserInfo();
    final updates = {
      'accepted': false,
      'acceptedByUserId': null,
      'acceptedByUserName': null,
      'tripStatus': 'Pending',
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
      'lastUpdatedBy': userInfo?.userId,
    };
    await _pathProvider
        .getTaxiBookingsCollectionRef(companyId)
        .doc(bookingId)
        .update(updates);
  }

  @override
  Future<void> updateBookingCompletedTime(String companyId, String id) async {
    final userInfo = await _accountRepository.getUserInfo();
    final updates = {
      'completedTime': Timestamp.fromDate(DateTime.now()),
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
      'lastUpdatedBy': userInfo?.userId,
    };
    await _pathProvider
        .getTaxiBookingsCollectionRef(companyId)
        .doc(id)
        .update(updates);
  }

  @override
  Future<void> updateBookingStartTime(String companyId, String id) async {
    final userInfo = await _accountRepository.getUserInfo();
    final updates = {
      'actualStartTime': Timestamp.fromDate(DateTime.now()),
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
      'lastUpdatedBy': userInfo?.userId,
    };
    await _pathProvider
        .getTaxiBookingsCollectionRef(companyId)
        .doc(id)
        .update(updates);
  }
}
