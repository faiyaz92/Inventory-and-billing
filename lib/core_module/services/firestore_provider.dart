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
  DocumentReference getSingleOrderRef(String companyId, String orderId); // New
  CollectionReference getInvoicesCollectionRef(String companyId); // New
  DocumentReference getSingleInvoiceRef(String companyId, String invoiceId); // New
  CollectionReference getCartsCollectionRef(String companyId);
  DocumentReference getUserCartRef(String companyId, String userId);
  CollectionReference getWishlistCollectionRef(String companyId);
  DocumentReference getUserWishlistRef(String companyId, String userId);

  CollectionReference getTaxiBookingsCollectionRef(String companyId);

  CollectionReference getTaxiTypesCollectionRef(String companyId);

  CollectionReference getTripTypesCollectionRef(String companyId);

  CollectionReference getServiceTypesCollectionRef(String companyId);

  CollectionReference getTripStatusesCollectionRef(String companyId);

  DocumentReference getTaxiBookingSettingsRef(String companyId);

  CollectionReference getVisitorCountersCollectionRef(String companyId);


  CollectionReference getPurchaseOrdersCollectionRef(String companyId);


  DocumentReference getSinglePurchaseOrderRef(String companyId, String orderId) ;


  CollectionReference getPurchaseInvoicesCollectionRef(String companyId);


  DocumentReference getSinglePurchaseInvoiceRef(String companyId, String invoiceId) ;
}
