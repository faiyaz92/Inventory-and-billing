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
  String getStoresCollectionRef(String companyId);
  String getStockCollectionRef(String companyId, String storeId);
  String getTransactionsCollectionRef(String companyId, String storeId);
}
