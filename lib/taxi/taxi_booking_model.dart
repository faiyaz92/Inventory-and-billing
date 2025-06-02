import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaxiBooking extends Equatable {
  final String id;
  final int passengerNumbers;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String taxiTypeId;
  final String tripTypeId;
  final String serviceTypeId;
  final String additionalInfo;
  final String pickupAddress;
  final String dropAddress;
  final String tripStatus;
  final bool accepted;
  final String? acceptedByDriverId;
  final String? acceptedByDriverName;
  final double totalFareAmount;
  final String lastUpdatedBy;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final DateTime tripDate;
  final DateTime? actualStartTime;
  final DateTime? completedTime;
  final String tripStartTime;

  const TaxiBooking({
    required this.id,
    required this.passengerNumbers,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.taxiTypeId,
    required this.tripTypeId,
    required this.serviceTypeId,
    required this.additionalInfo,
    required this.pickupAddress,
    required this.dropAddress,
    required this.tripDate,
    required this.tripStartTime,
    this.actualStartTime,
    required this.tripStatus,
    required this.accepted,
    this.acceptedByDriverId,
    this.acceptedByDriverName,
    this.completedTime,
    required this.totalFareAmount,
    required this.createdAt,
    required this.lastUpdatedBy,
    required this.lastUpdatedAt,
  });

  TaxiBooking copyWith({
    String? id,
    int? passengerNumbers,
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    String? mobileNumber,
    String? taxiTypeId,
    String? tripTypeId,
    String? serviceTypeId,
    String? additionalInfo,
    String? pickupAddress,
    String? dropAddress,
    DateTime? date,
    String? startTime,
    DateTime? actualStartTime,
    String? tripStatus,
    bool? accepted,
    String? acceptedByUserId,
    String? acceptedByUserName,
    DateTime? completedTime,
    double? totalFareAmount,
    DateTime? loggedDate,
    String? lastUpdatedBy,
    DateTime? lastUpdatedAt,
  }) {
    return TaxiBooking(
      id: id ?? this.id,
      passengerNumbers: passengerNumbers ?? this.passengerNumbers,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      taxiTypeId: taxiTypeId ?? this.taxiTypeId,
      tripTypeId: tripTypeId ?? this.tripTypeId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      tripDate: date ?? this.tripDate,
      tripStartTime: startTime ?? this.tripStartTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      tripStatus: tripStatus ?? this.tripStatus,
      accepted: accepted ?? this.accepted,
      acceptedByDriverId: acceptedByUserId ?? this.acceptedByDriverId,
      acceptedByDriverName: acceptedByUserName ?? this.acceptedByDriverName,
      completedTime: completedTime ?? this.completedTime,
      totalFareAmount: totalFareAmount ?? this.totalFareAmount,
      createdAt: loggedDate ?? this.createdAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  factory TaxiBooking.fromDto(TaxiBookingDto dto) {
    return TaxiBooking(
      id: dto.id,
      passengerNumbers: dto.passengerNumbers,
      firstName: dto.firstName,
      lastName: dto.lastName,
      email: dto.email,
      countryCode: dto.countryCode,
      mobileNumber: dto.mobileNumber,
      taxiTypeId: dto.taxiTypeId,
      tripTypeId: dto.tripTypeId,
      serviceTypeId: dto.serviceTypeId,
      additionalInfo: dto.additionalInfo,
      pickupAddress: dto.pickupAddress,
      dropAddress: dto.dropAddress,
      tripDate: dto.date,
      tripStartTime: dto.startTime,
      actualStartTime: dto.actualStartTime,
      tripStatus: dto.tripStatus,
      accepted: dto.accepted,
      acceptedByDriverId: dto.acceptedByUserId,
      acceptedByDriverName: dto.acceptedByUserName,
      completedTime: dto.completedTime,
      totalFareAmount: dto.totalFareAmount,
      createdAt: dto.loggedDate,
      lastUpdatedBy: dto.lastUpdatedBy,
      lastUpdatedAt: dto.lastUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        passengerNumbers,
        firstName,
        lastName,
        email,
        countryCode,
        mobileNumber,
        taxiTypeId,
        tripTypeId,
        serviceTypeId,
        additionalInfo,
        pickupAddress,
        dropAddress,
        tripDate,
        tripStartTime,
        actualStartTime,
        tripStatus,
        accepted,
        acceptedByDriverId,
        acceptedByDriverName,
        completedTime,
        totalFareAmount,
        createdAt,
        lastUpdatedBy,
        lastUpdatedAt,
      ];
}

class TaxiBookingDto {
  final String id;
  final int passengerNumbers;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String taxiTypeId;
  final String tripTypeId;
  final String serviceTypeId;
  final String additionalInfo;
  final String pickupAddress;
  final String dropAddress;
  final DateTime date;
  final String startTime;
  final DateTime? actualStartTime;
  final String tripStatus;
  final bool accepted;
  final String? acceptedByUserId;
  final String? acceptedByUserName;
  final DateTime? completedTime;
  final double totalFareAmount;
  final DateTime loggedDate;
  final String lastUpdatedBy;
  final DateTime lastUpdatedAt;

  TaxiBookingDto({
    required this.id,
    required this.passengerNumbers,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.taxiTypeId,
    required this.tripTypeId,
    required this.serviceTypeId,
    required this.additionalInfo,
    required this.pickupAddress,
    required this.dropAddress,
    required this.date,
    required this.startTime,
    this.actualStartTime,
    required this.tripStatus,
    required this.accepted,
    this.acceptedByUserId,
    this.acceptedByUserName,
    this.completedTime,
    required this.totalFareAmount,
    required this.loggedDate,
    required this.lastUpdatedBy,
    required this.lastUpdatedAt,
  });

  factory TaxiBookingDto.fromFirestore(Map<String, dynamic> data) {
    return TaxiBookingDto(
      id: data['id'] ?? '',
      passengerNumbers: data['passengerNumbers'] ?? 1,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      countryCode: data['countryCode'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      taxiTypeId: data['taxiTypeId'] ?? '',
      tripTypeId: data['tripTypeId'] ?? '',
      serviceTypeId: data['serviceTypeId'] ?? '',
      additionalInfo: data['additionalInfo'] ?? '',
      pickupAddress: data['pickupAddress'] ?? '',
      dropAddress: data['dropAddress'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      actualStartTime: (data['actualStartTime'] as Timestamp?)?.toDate(),
      tripStatus: data['tripStatus'] ?? 'pending',
      accepted: data['accepted'] ?? false,
      acceptedByUserId: data['acceptedByUserId'],
      acceptedByUserName: data['acceptedByUserName'],
      completedTime: (data['completedTime'] as Timestamp?)?.toDate(),
      totalFareAmount: (data['totalFareAmount'] as num?)?.toDouble() ?? 0.0,
      loggedDate:
          (data['loggedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedBy: data['lastUpdatedBy'] ?? '',
      lastUpdatedAt:
          (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'passengerNumbers': passengerNumbers,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'countryCode': countryCode,
      'mobileNumber': mobileNumber,
      'taxiTypeId': taxiTypeId,
      'tripTypeId': tripTypeId,
      'serviceTypeId': serviceTypeId,
      'additionalInfo': additionalInfo,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'actualStartTime':
          actualStartTime != null ? Timestamp.fromDate(actualStartTime!) : null,
      'tripStatus': tripStatus,
      'accepted': accepted,
      'acceptedByUserId': acceptedByUserId,
      'acceptedByUserName': acceptedByUserName,
      'completedTime':
          completedTime != null ? Timestamp.fromDate(completedTime!) : null,
      'totalFareAmount': totalFareAmount,
      'loggedDate': Timestamp.fromDate(loggedDate),
      'lastUpdatedBy': lastUpdatedBy,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  factory TaxiBookingDto.fromModel(TaxiBooking model) {
    return TaxiBookingDto(
      id: model.id,
      passengerNumbers: model.passengerNumbers,
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      countryCode: model.countryCode,
      mobileNumber: model.mobileNumber,
      taxiTypeId: model.taxiTypeId,
      tripTypeId: model.tripTypeId,
      serviceTypeId: model.serviceTypeId,
      additionalInfo: model.additionalInfo,
      pickupAddress: model.pickupAddress,
      dropAddress: model.dropAddress,
      date: model.tripDate,
      startTime: model.tripStartTime,
      actualStartTime: model.actualStartTime,
      tripStatus: model.tripStatus,
      accepted: model.accepted,
      acceptedByUserId: model.acceptedByDriverId,
      acceptedByUserName: model.acceptedByDriverName,
      completedTime: model.completedTime,
      totalFareAmount: model.totalFareAmount,
      loggedDate: model.createdAt,
      lastUpdatedBy: model.lastUpdatedBy,
      lastUpdatedAt: model.lastUpdatedAt,
    );
  }
}
