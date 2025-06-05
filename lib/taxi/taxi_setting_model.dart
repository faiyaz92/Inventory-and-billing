import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';

class TaxiSettings {
  final double perKmFareRate;
  final double minimumFare;
  final double whatsappNotificationFareThreshold;
  final DateTime updatedAt;
  final String updatedBy;
  final List<TaxiType> taxiTypes;
  final List<TripType> tripTypes;
  final List<ServiceType> serviceTypes;
  final List<TripStatus> tripStatuses;

  TaxiSettings({
    required this.perKmFareRate,
    required this.minimumFare,
    required this.whatsappNotificationFareThreshold,
    required this.updatedAt,
    required this.updatedBy,
    required this.taxiTypes,
    required this.tripTypes,
    required this.serviceTypes,
    required this.tripStatuses,
  });

  factory TaxiSettings.fromDto(TaxiSettingsDto dto) {
    return TaxiSettings(
      perKmFareRate: dto.perKmFareRate,
      minimumFare: dto.minimumFare,
      whatsappNotificationFareThreshold: dto.whatsappNotificationFareThreshold,
      updatedAt: dto.updatedAt,
      updatedBy: dto.updatedBy,
      taxiTypes: dto.taxiTypes.map((dto) => TaxiType.fromDto(dto)).toList(),
      tripTypes: dto.tripTypes.map((dto) => TripType.fromDto(dto)).toList(),
      serviceTypes: dto.serviceTypes.map((dto) => ServiceType.fromDto(dto)).toList(),
      tripStatuses: dto.tripStatuses.map((dto) => TripStatus.fromDto(dto)).toList(),
    );
  }

  TaxiSettings copyWith({
    double? perKmFareRate,
    double? minimumFare,
    double? whatsappNotificationFareThreshold,
    DateTime? updatedAt,
    String? updatedBy,
    List<TaxiType>? taxiTypes,
    List<TripType>? tripTypes,
    List<ServiceType>? serviceTypes,
    List<TripStatus>? tripStatuses,
  }) {
    return TaxiSettings(
      perKmFareRate: perKmFareRate ?? this.perKmFareRate,
      minimumFare: minimumFare ?? this.minimumFare,
      whatsappNotificationFareThreshold:
      whatsappNotificationFareThreshold ?? this.whatsappNotificationFareThreshold,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      taxiTypes: taxiTypes ?? this.taxiTypes,
      tripTypes: tripTypes ?? this.tripTypes,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      tripStatuses: tripStatuses ?? this.tripStatuses,
    );
  }
}

class TaxiSettingsDto {
  final double perKmFareRate;
  final double minimumFare;
  final double whatsappNotificationFareThreshold;
  final DateTime updatedAt;
  final String updatedBy;
  final List<TaxiTypeDto> taxiTypes;
  final List<TripTypeDto> tripTypes;
  final List<ServiceTypeDto> serviceTypes;
  final List<TripStatusDto> tripStatuses;

  TaxiSettingsDto({
    required this.perKmFareRate,
    required this.minimumFare,
    required this.whatsappNotificationFareThreshold,
    required this.updatedAt,
    required this.updatedBy,
    required this.taxiTypes,
    required this.tripTypes,
    required this.serviceTypes,
    required this.tripStatuses,
  });

  factory TaxiSettingsDto.fromFirestore({
    required Map<String, dynamic> settingsData,
    required List<TaxiTypeDto> taxiTypes,
    required List<TripTypeDto> tripTypes,
    required List<ServiceTypeDto> serviceTypes,
    required List<TripStatusDto> tripStatuses,
  }) {
    return TaxiSettingsDto(
      perKmFareRate: (settingsData['perKmFareRate'] as num?)?.toDouble() ?? 10.0,
      minimumFare: (settingsData['minimumFare'] as num?)?.toDouble() ?? 50.0,
      whatsappNotificationFareThreshold: (settingsData['whatsappNotificationFareThreshold'] as num?)
          ?.toDouble() ?? 200.0,
      updatedAt: (settingsData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy: settingsData['updatedBy'] ?? '',
      taxiTypes: taxiTypes,
      tripTypes: tripTypes,
      serviceTypes: serviceTypes,
      tripStatuses: tripStatuses,
    );
  }

  factory TaxiSettingsDto.fromModel(TaxiSettings model) {
    return TaxiSettingsDto(
      perKmFareRate: model.perKmFareRate,
      minimumFare: model.minimumFare,
      whatsappNotificationFareThreshold: model.whatsappNotificationFareThreshold,
      updatedAt: model.updatedAt,
      updatedBy: model.updatedBy,
      taxiTypes: model.taxiTypes.map((type) => TaxiTypeDto.fromModel(type)).toList(),
      tripTypes: model.tripTypes.map((type) => TripTypeDto.fromModel(type)).toList(),
      serviceTypes: model.serviceTypes.map((type) => ServiceTypeDto.fromModel(type)).toList(),
      tripStatuses: model.tripStatuses.map((status) => TripStatusDto.fromModel(status)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'perKmFareRate': perKmFareRate,
      'minimumFare': minimumFare,
      'whatsappNotificationFareThreshold': whatsappNotificationFareThreshold,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
    };
  }
}