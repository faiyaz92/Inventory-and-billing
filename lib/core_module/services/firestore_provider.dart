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
  DocumentReference getAccountLedgerRef(String companyId, String ledgerId);
  CollectionReference getTransactionsRef(String companyId, String ledgerId);
}
