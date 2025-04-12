import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class FirestorePathProviderImpl implements IFirestorePathProvider {
  final FirebaseFirestore _firestore;

  /// 🔹 Define root path to avoid hardcoding
  static const String rootPath = 'Easy2Solutions';
  static const String companyDirectory = 'companyDirectory';
  static const String tenantCompanies = 'tenantCompanies';
  static const String usersCollection = 'users';
  static const String superAdmins = 'superAdmins';
  static const String companiesCollection = 'companies';
  static const String tasksCollection =
      'tasks'; // ✅ New Task Collection Constant
  static const String productCollection =
      'products'; // ✅ New Task Collection Constant
  static const String users = 'users'; // ✅ New Task Collection Constant
  static const String categoriesCollection = 'categories';
  static const String subcategoriesCollection = 'subcategories';
  static const String accountLedgers = 'accountLedgers';
  static const String transactions = 'transactions';
  FirestorePathProviderImpl(this._firestore);

  @override
  DocumentReference get basePath =>
      _firestore.collection(rootPath).doc(companyDirectory);

  @override
  CollectionReference get superAdminPath => basePath.collection(superAdmins);

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  DocumentReference getTenantCompanyRef(String companyId) {
    return basePath.collection(tenantCompanies).doc(companyId);
  }

  @override
  CollectionReference getTenantUsersRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(usersCollection);
  }

  @override
  DocumentReference getTenantUserRef(String companyId, String userId) {
    return getTenantCompanyRef(companyId)
        .collection(usersCollection)
        .doc(userId);
  }

  @override
  CollectionReference getSuperAdminPath() {
    return basePath.collection(superAdmins);
  }

  @override
  CollectionReference getCommonUsersPath() {
    return basePath.collection(users); // 🔥 Global users ke liye
  }

  @override
  Future<bool> checkCompanyExists(String companyId) async {
    final snapshot = await getTenantCompanyRef(companyId).get();
    return snapshot.exists;
  }

  /// ✅ Now referring to `companies` as `customerCompany` in variables
  @override
  CollectionReference getCustomerCompanyRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(
        companiesCollection); // 🔹 Actual collection name remains `companies`
  }

  @override
  DocumentReference getSingleCustomerCompanyRef(
      String companyId, String customerCompanyId) {
    return getCustomerCompanyRef(companyId).doc(customerCompanyId);
  }

  /// ✅ Task Collection Under Tenant Company
  @override
  CollectionReference getTaskCollectionRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(tasksCollection);
  }

  /// ✅ Task Collection Under Tenant Company
  @override
  CollectionReference getProductCollectionRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(productCollection);
  }

  @override
  DocumentReference getSingleTaskRef(String companyId, String taskId) {
    return getTaskCollectionRef(companyId).doc(taskId);
  }

  // 🔹 Path for Account Ledger
  @override
  DocumentReference getAccountLedgerRef(String companyId, String ledgerId) {
    return getTenantCompanyRef(companyId)
        .collection(accountLedgers)
        .doc(ledgerId);
  }

  @override
  CollectionReference getAccountLedger(
    String companyId,
  ) {
    return getTenantCompanyRef(companyId).collection(accountLedgers);
  }

// 🔹 Path for Transactions under a Ledger
  @override
  CollectionReference getTransactionsRef(String companyId, String ledgerId) {
    return getAccountLedgerRef(companyId, ledgerId).collection(transactions);
  }

  @override
  CollectionReference getCategoryCollectionRef(String companyId) {
    // Category collection will be under each tenant company
    return _firestore
        .collection(rootPath) // Root path
        .doc(companyDirectory) // Company directory
        .collection(tenantCompanies) // Tenant companies collection
        .doc(companyId) // Specific company document
        .collection(categoriesCollection); // Categories subcollection
  }

  @override
  CollectionReference getSubcategoryCollectionRef(String companyId) {
    // Now the subcategories collection is at the company level, not under category.
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection(subcategoriesCollection);  // Top-level subcategories collection
  }
}
