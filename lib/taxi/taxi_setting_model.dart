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
  final String? mapApiKey; // Added mapApiKey
  final String? twilioAccountSid; // Added twilioAccountSid
  final String? twilioAuthToken; // Added twilioAuthToken
  final String? twilioWhatsAppNumber; // Added twilioWhatsAppNumber

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
    this.mapApiKey,
    this.twilioAccountSid,
    this.twilioAuthToken,
    this.twilioWhatsAppNumber,
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
      mapApiKey: dto.mapApiKey, // Added to fromDto
      twilioAccountSid: dto.twilioAccountSid, // Added to fromDto
      twilioAuthToken: dto.twilioAuthToken, // Added to fromDto
      twilioWhatsAppNumber: dto.twilioWhatsAppNumber, // Added to fromDto
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
    String? mapApiKey,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? twilioWhatsAppNumber,
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
      mapApiKey: mapApiKey ?? this.mapApiKey, // Added to copyWith
      twilioAccountSid: twilioAccountSid ?? this.twilioAccountSid, // Added to copyWith
      twilioAuthToken: twilioAuthToken ?? this.twilioAuthToken, // Added to copyWith
      twilioWhatsAppNumber: twilioWhatsAppNumber ?? this.twilioWhatsAppNumber, // Added to copyWith
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
  final String? mapApiKey; // Added mapApiKey
  final String? twilioAccountSid; // Added twilioAccountSid
  final String? twilioAuthToken; // Added twilioAuthToken
  final String? twilioWhatsAppNumber; // Added twilioWhatsAppNumber

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
    this.mapApiKey,
    this.twilioAccountSid,
    this.twilioAuthToken,
    this.twilioWhatsAppNumber,
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
      whatsappNotificationFareThreshold:
      (settingsData['whatsappNotificationFareThreshold'] as num?)?.toDouble() ?? 200.0,
      updatedAt: (settingsData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy: settingsData['updatedBy'] ?? '',
      taxiTypes: taxiTypes,
      tripTypes: tripTypes,
      serviceTypes: serviceTypes,
      tripStatuses: tripStatuses,
      mapApiKey: settingsData['mapApiKey'] as String?, // Added to fromFirestore
      twilioAccountSid: settingsData['twilioAccountSid'] as String?, // Added to fromFirestore
      twilioAuthToken: settingsData['twilioAuthToken'] as String?, // Added to fromFirestore
      twilioWhatsAppNumber: settingsData['twilioWhatsAppNumber'] as String?, // Added to fromFirestore
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
      mapApiKey: model.mapApiKey, // Added to fromModel
      twilioAccountSid: model.twilioAccountSid, // Added to fromModel
      twilioAuthToken: model.twilioAuthToken, // Added to fromModel
      twilioWhatsAppNumber: model.twilioWhatsAppNumber, // Added to fromModel
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'perKmFareRate': perKmFareRate,
      'minimumFare': minimumFare,
      'whatsappNotificationFareThreshold': whatsappNotificationFareThreshold,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
      'mapApiKey': mapApiKey, // Added to toFirestore
      'twilioAccountSid': twilioAccountSid, // Added to toFirestore
      'twilioAuthToken': twilioAuthToken, // Added to toFirestore
      'twilioWhatsAppNumber': twilioWhatsAppNumber, // Added to toFirestore
    };
  }
}