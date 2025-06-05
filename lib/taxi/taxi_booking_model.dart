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
  final String? bookedByUserId; // Added optional bookedByUserId

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
    this.bookedByUserId, // Added to constructor
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
    DateTime? tripDate,
    String? tripStartTime,
    DateTime? actualStartTime,
    String? tripStatus,
    bool? accepted,
    String? acceptedByDriverId,
    String? acceptedByDriverName,
    DateTime? completedTime,
    double? totalFareAmount,
    DateTime? createdAt,
    String? lastUpdatedBy,
    DateTime? lastUpdatedAt,
    String? bookedByUserId, // Added to copyWith
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
      tripDate: tripDate ?? this.tripDate,
      tripStartTime: tripStartTime ?? this.tripStartTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      tripStatus: tripStatus ?? this.tripStatus,
      accepted: accepted ?? this.accepted,
      acceptedByDriverId: acceptedByDriverId ?? this.acceptedByDriverId,
      acceptedByDriverName: acceptedByDriverName ?? this.acceptedByDriverName,
      completedTime: completedTime ?? this.completedTime,
      totalFareAmount: totalFareAmount ?? this.totalFareAmount,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      bookedByUserId: bookedByUserId ?? this.bookedByUserId,
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
      tripDate: dto.tripDate,
      tripStartTime: dto.tripStartTime,
      actualStartTime: dto.actualStartTime,
      tripStatus: dto.tripStatus,
      accepted: dto.accepted,
      acceptedByDriverId: dto.acceptedByDriverId,
      acceptedByDriverName: dto.acceptedByDriverName, // Fixed typo
      completedTime: dto.completedTime,
      totalFareAmount: dto.totalFareAmount,
      createdAt: dto.createdAt,
      lastUpdatedBy: dto.lastUpdatedBy,
      lastUpdatedAt: dto.lastUpdatedAt,
      bookedByUserId: dto.bookedByUserId, // Added
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
    bookedByUserId, // Added to props
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
  final DateTime tripDate;
  final String tripStartTime;
  final DateTime? actualStartTime;
  final String tripStatus;
  final bool accepted;
  final String? acceptedByDriverId;
  final String? acceptedByDriverName; // Fixed typo
  final DateTime? completedTime;
  final double totalFareAmount;
  final DateTime createdAt;
  final String lastUpdatedBy;
  final DateTime lastUpdatedAt;
  final String? bookedByUserId; // Added optional bookedByUserId

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
    required this.tripDate,
    required this.tripStartTime,
    this.actualStartTime,
    required this.tripStatus,
    required this.accepted,
    this.acceptedByDriverId,
    this.acceptedByDriverName, // Fixed typo
    this.completedTime,
    required this.totalFareAmount,
    required this.createdAt,
    required this.lastUpdatedBy,
    required this.lastUpdatedAt,
    this.bookedByUserId, // Added to constructor
  });

  factory TaxiBookingDto.fromFirestore(Map<String, dynamic> data, String docId) {
    return TaxiBookingDto(
      id: docId,
      passengerNumbers: data['passengerNumbers'] as int? ?? 1,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? '',
      mobileNumber: data['mobileNumber'] as String? ?? '',
      taxiTypeId: data['taxiTypeId'] as String? ?? '',
      tripTypeId: data['tripTypeId'] as String? ?? '',
      serviceTypeId: data['serviceTypeId'] as String? ?? '',
      additionalInfo: data['additionalInfo'] as String? ?? '',
      pickupAddress: data['pickupAddress'] as String? ?? '',
      dropAddress: data['dropAddress'] as String? ?? '',
      tripDate: (data['tripDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tripStartTime: data['tripStartTime'] as String? ?? '',
      actualStartTime: (data['actualStartTime'] as Timestamp?)?.toDate(),
      tripStatus: data['tripStatus'] as String? ?? 'pending',
      accepted: data['accepted'] as bool? ?? false,
      acceptedByDriverId: data['acceptedByDriverId'] as String?, // Fixed to use correct field
      acceptedByDriverName: data['acceptedByDriverName'] as String?, // Fixed to use correct field
      completedTime: (data['completedTime'] as Timestamp?)?.toDate(),
      totalFareAmount: (data['totalFareAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedBy: data['lastUpdatedBy'] as String? ?? '',
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookedByUserId: data['bookedByUserId'] as String?, // Added
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
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
      'tripDate': Timestamp.fromDate(tripDate),
      'tripStartTime': tripStartTime,
      'actualStartTime': actualStartTime != null ? Timestamp.fromDate(actualStartTime!) : null,
      'tripStatus': tripStatus,
      'accepted': accepted,
      'acceptedByDriverId': acceptedByDriverId, // Fixed
      'acceptedByDriverName': acceptedByDriverName, // Fixed
      'completedTime': completedTime != null ? Timestamp.fromDate(completedTime!) : null,
      'totalFareAmount': totalFareAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedBy': lastUpdatedBy,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'bookedByUserId': bookedByUserId, // Added
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
      tripDate: model.tripDate,
      tripStartTime: model.tripStartTime,
      actualStartTime: model.actualStartTime,
      tripStatus: model.tripStatus,
      accepted: model.accepted,
      acceptedByDriverId: model.acceptedByDriverId, // Fixed
      acceptedByDriverName: model.acceptedByDriverName, // Fixed
      completedTime: model.completedTime,
      totalFareAmount: model.totalFareAmount,
      createdAt: model.createdAt,
      lastUpdatedBy: model.lastUpdatedBy,
      lastUpdatedAt: model.lastUpdatedAt,
      bookedByUserId: model.bookedByUserId, // Added
    );
  }
}