import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/taxi/taxi_service_type_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_setting_model.dart';
import 'package:requirment_gathering_app/taxi/taxi_type_model.dart';
import 'package:requirment_gathering_app/taxi/trip_status_model.dart';
import 'package:requirment_gathering_app/taxi/trip_type_model.dart';

abstract class ITaxiSettingsRepository {
  Future<TaxiSettings> getSettings(String companyId);

  Future<void> updateSettings(String companyId, TaxiSettings settings);

  Future<void> addTaxiType(String companyId, TaxiType type);

  Future<void> deleteTaxiType(String companyId, String typeId);

  Future<void> addTripType(String companyId, TripType type);

  Future<void> deleteTripType(String companyId, String typeId);

  Future<void> addServiceType(String companyId, ServiceType type);

  Future<void> deleteServiceType(String companyId, String typeId);

  Future<void> addTripStatus(String companyId, TripStatus status);

  Future<void> deleteTripStatus(String companyId, String statusId);
}

class TaxiSettingsRepositoryImpl implements ITaxiSettingsRepository {
  final IFirestorePathProvider _pathProvider;

  TaxiSettingsRepositoryImpl(this._pathProvider);

  // @override
  // Future<TaxiSettings> getSettings(String companyId) async {
  //   try {
  //     // Fetch settings document
  //     final settingsSnapshot =
  //     await _pathProvider.getTaxiBookingSettingsRef(companyId).get();
  //     final settingsData = settingsSnapshot.exists
  //         ? settingsSnapshot.data() as Map<String, dynamic>
  //         : {};
  //
  //     // Fetch subcollections
  //     final taxiTypesSnapshot =
  //     await _pathProvider.getTaxiTypesCollectionRef(companyId).get();
  //     final tripTypesSnapshot =
  //     await _pathProvider.getTripTypesCollectionRef(companyId).get();
  //     final serviceTypesSnapshot =
  //     await _pathProvider.getServiceTypesCollectionRef(companyId).get();
  //     final tripStatusesSnapshot =
  //     await _pathProvider.getTripStatusesCollectionRef(companyId).get();
  //
  //     final taxiTypes = taxiTypesSnapshot.docs
  //         .map((doc) =>
  //         TaxiTypeDto.fromFirestore(doc, doc.data() as Map<String, dynamic>))
  //         .toList();
  //     final tripTypes = tripTypesSnapshot.docs
  //         .map((doc) => TripTypeDto.fromFirestore(doc))
  //         .toList();
  //     final serviceTypes = serviceTypesSnapshot.docs
  //         .map((doc) => ServiceTypeDto.fromFirestore(doc))
  //         .toList();
  //     final tripStatuses = tripStatusesSnapshot.docs
  //         .map((doc) => TripStatusDto.fromFirestore(doc))
  //         .toList();
  //
  //     return TaxiSettings.fromDto(TaxiSettingsDto.fromFirestore(
  //       settingsData: settingsData as Map<String, dynamic>,
  //       taxiTypes: taxiTypes,
  //       tripTypes: tripTypes,
  //       serviceTypes: serviceTypes,
  //       tripStatuses: tripStatuses,
  //     ));
  //   } catch (e) {
  //     throw Exception('Failed to fetch taxi settings: $e');
  //   }
  // }
  @override
  Future<TaxiSettings> getSettings(String companyId) async {
    try {
      // Fetch settings document
      final settingsSnapshot =
      await _pathProvider.getTaxiBookingSettingsRef(companyId).get();
      final settingsData = settingsSnapshot.exists
          ? (settingsSnapshot.data() as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      // Fetch subcollections
      final taxiTypesSnapshot =
      await _pathProvider.getTaxiTypesCollectionRef(companyId).get();
      final tripTypesSnapshot =
      await _pathProvider.getTripTypesCollectionRef(companyId).get();
      final serviceTypesSnapshot =
      await _pathProvider.getServiceTypesCollectionRef(companyId).get();
      final tripStatusesSnapshot =
      await _pathProvider.getTripStatusesCollectionRef(companyId).get();

      final taxiTypes = taxiTypesSnapshot.docs
          .map((doc) =>
          TaxiTypeDto.fromFirestore(doc, (doc.data() as Map).cast<String, dynamic>()))
          .toList();
      final tripTypes = tripTypesSnapshot.docs
          .map((doc) => TripTypeDto.fromFirestore(doc))
          .toList();
      final serviceTypes = serviceTypesSnapshot.docs
          .map((doc) => ServiceTypeDto.fromFirestore(doc))
          .toList();
      final tripStatuses = tripStatusesSnapshot.docs
          .map((doc) => TripStatusDto.fromFirestore(doc))
          .toList();

      return TaxiSettings.fromDto(TaxiSettingsDto.fromFirestore(
        settingsData: settingsData,
        taxiTypes: taxiTypes,
        tripTypes: tripTypes,
        serviceTypes: serviceTypes,
        tripStatuses: tripStatuses,
      ));
    } catch (e) {
      throw Exception('Failed to fetch taxi settings: $e');
    }
  }
  @override
  Future<void> updateSettings(String companyId, TaxiSettings settings) async {
    final dto = TaxiSettingsDto(
      perKmFareRate: settings.perKmFareRate,
      minimumFare: settings.minimumFare,
      whatsappNotificationFareThreshold:
          settings.whatsappNotificationFareThreshold,
      updatedAt: DateTime.now(),
      updatedBy: settings.updatedBy,
      taxiTypes: settings.taxiTypes
          .map((type) => TaxiTypeDto.fromModel(type))
          .toList(),
      tripTypes: settings.tripTypes
          .map((type) => TripTypeDto.fromModel(type))
          .toList(),
      serviceTypes: settings.serviceTypes
          .map((type) => ServiceTypeDto.fromModel(type))
          .toList(),
      tripStatuses: settings.tripStatuses
          .map((status) => TripStatusDto.fromModel(status))
          .toList(),
      mapApiKey: settings.mapApiKey,
      twilioAccountSid: settings.twilioAccountSid,
      twilioAuthToken: settings.twilioAuthToken,
      twilioWhatsAppNumber: settings.twilioWhatsAppNumber,
    );

    // Update settings document
    await _pathProvider
        .getTaxiBookingSettingsRef(companyId)
        .set(dto.toFirestore());

    // Update subcollections
    final taxiTypesRef = _pathProvider.getTaxiTypesCollectionRef(companyId);
    final tripTypesRef = _pathProvider.getTripTypesCollectionRef(companyId);
    final serviceTypesRef =
        _pathProvider.getServiceTypesCollectionRef(companyId);
    final tripStatusesRef =
        _pathProvider.getTripStatusesCollectionRef(companyId);

    // Clear existing documents and set new ones
    /*  await _clearCollection(taxiTypesRef);
    for (var type in dto.taxiTypes) {
      await taxiTypesRef.doc(type.id).set(type.toFirestore());
    }

    await _clearCollection(tripTypesRef);
    for (var type in dto.tripTypes) {
      await tripTypesRef.doc(type.id).set(type.toFirestore());
    }

    await _clearCollection(serviceTypesRef);
    for (var type in dto.serviceTypes) {
      await serviceTypesRef.doc(type.id).set(type.toFirestore());
    }

    await _clearCollection(tripStatusesRef);
    for (var status in dto.tripStatuses) {
      await tripStatusesRef.doc(status.id).set(status.toFirestore());
    }*/
  }

  @override
  Future<void> addTaxiType(String companyId, TaxiType type) async {
    final dto = TaxiTypeDto.fromModel(type);
    await _pathProvider
        .getTaxiTypesCollectionRef(companyId)
        .doc(type.name)
        .set(dto.toFirestore());
  }

  @override
  Future<void> deleteTaxiType(String companyId, String typeId) async {
    await _pathProvider
        .getTaxiTypesCollectionRef(companyId)
        .doc(typeId)
        .delete();
  }

  @override
  Future<void> addTripType(String companyId, TripType type) async {
    final dto = TripTypeDto.fromModel(type);
    await _pathProvider
        .getTripTypesCollectionRef(companyId)
        .doc(type.name)
        .set(dto.toFirestore());
  }

  @override
  Future<void> deleteTripType(String companyId, String typeId) async {
    await _pathProvider
        .getTripTypesCollectionRef(companyId)
        .doc(typeId)
        .delete();
  }

  @override
  Future<void> addServiceType(String companyId, ServiceType type) async {
    final dto = ServiceTypeDto.fromModel(type);
    await _pathProvider
        .getServiceTypesCollectionRef(companyId)
        .doc(type.name)
        .set(dto.toFirestore());
  }

  @override
  Future<void> deleteServiceType(String companyId, String typeId) async {
    await _pathProvider
        .getServiceTypesCollectionRef(companyId)
        .doc(typeId)
        .delete();
  }

  @override
  Future<void> addTripStatus(String companyId, TripStatus status) async {
    final dto = TripStatusDto.fromModel(status);
    await _pathProvider
        .getTripStatusesCollectionRef(companyId)
        .doc(status.name)
        .set(dto.toFirestore());
  }

  @override
  Future<void> deleteTripStatus(String companyId, String statusId) async {
    await _pathProvider
        .getTripStatusesCollectionRef(companyId)
        .doc(statusId)
        .delete();
  }

  Future<void> _clearCollection(CollectionReference ref) async {
    final snapshot = await ref.get();
    final batch = ref.firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
