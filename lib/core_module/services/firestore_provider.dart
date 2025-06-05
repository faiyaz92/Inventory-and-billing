import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IFirestorePathProvider {
  DocumentReference get basePath;

  CollectionReference get superAdminPath;

  FirebaseFirestore get firestore;

  DocumentReference getTenantCompanyRef(String companyId);

  CollectionReference getTenantUsersRef(String companyId);

  CollectionReference getSuperAdminPath();

  Future<bool> checkCompanyExists(String companyId);

  DocumentReference getTenantUserRef(String companyId, String userId);

  DocumentReference getSingleCustomerCompanyRef(
      String companyId, String customerCompanyId);

  CollectionReference getCustomerCompanyRef(String companyId);

  CollectionReference getTaskCollectionRef(String companyId);

  DocumentReference getSingleTaskRef(String companyId, String taskId);

  CollectionReference getCommonUsersPath();

  CollectionReference getAccountLedger(String companyId);

  DocumentReference getAccountLedgerRef(String companyId, String ledgerId);

  CollectionReference getTransactionsRef(String companyId, String ledgerId);

  CollectionReference getProductCollectionRef(String companyId);

  CollectionReference getCategoryCollectionRef(String companyId);

  CollectionReference getSubcategoryCollectionRef(
    String companyId,
  );
  CollectionReference getStoresCollectionRef(String companyId);
  CollectionReference getStockCollectionRef(String companyId, String storeId);
  CollectionReference getTransactionsCollectionRef(String companyId, String storeId);

  CollectionReference getOrdersCollectionRef(String companyId);
  CollectionReference getCartsCollectionRef(String companyId); // New
  DocumentReference getUserCartRef(String companyId, String userId); // New
  CollectionReference getWishlistCollectionRef(String companyId);
  DocumentReference getUserWishlistRef(String companyId, String userId);

  CollectionReference getTaxiBookingsCollectionRef(String companyId);

// Taxi Types Collection
  CollectionReference getTaxiTypesCollectionRef(String companyId);

// Trip Types Collection
  CollectionReference getTripTypesCollectionRef(String companyId) ;

// Service Types Collection
  CollectionReference getServiceTypesCollectionRef(String companyId) ;

// Trip Statuses Collection
  CollectionReference getTripStatusesCollectionRef(String companyId) ;

// Taxi Booking Settings Document
  DocumentReference getTaxiBookingSettingsRef(String companyId) ;

// Visitor Counter Collection
  CollectionReference getVisitorCountersCollectionRef(String companyId) ;
}
