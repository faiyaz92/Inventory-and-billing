import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class FirestorePathProviderImpl implements IFirestorePathProvider {
  final FirebaseFirestore _firestore;

  static const String rootPath = 'Easy2Solutions';
  static const String companyDirectory = 'companyDirectory';
  static const String tenantCompanies = 'tenantCompanies';
  static const String usersCollection = 'users';
  static const String superAdmins = 'superAdmins';
  static const String companiesCollection = 'companies';
  static const String tasksCollection = 'tasks';
  static const String productCollection = 'products';
  static const String users = 'users';
  static const String categoriesCollection = 'categories';
  static const String subcategoriesCollection = 'subcategories';
  static const String accountLedgers = 'accountLedgers';
  static const String transactions = 'transactions';
  static const String cartsCollection = 'carts';

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
    return basePath.collection(users);
  }

  @override
  Future<bool> checkCompanyExists(String companyId) async {
    final snapshot = await getTenantCompanyRef(companyId).get();
    return snapshot.exists;
  }

  @override
  CollectionReference getCustomerCompanyRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(companiesCollection);
  }

  @override
  DocumentReference getSingleCustomerCompanyRef(
      String companyId, String customerCompanyId) {
    return getCustomerCompanyRef(companyId).doc(customerCompanyId);
  }

  @override
  CollectionReference getTaskCollectionRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(tasksCollection);
  }

  @override
  CollectionReference getProductCollectionRef(String companyId) {
    return getTenantCompanyRef(companyId).collection(productCollection);
  }

  @override
  DocumentReference getSingleTaskRef(String companyId, String taskId) {
    return getTaskCollectionRef(companyId).doc(taskId);
  }

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

  @override
  CollectionReference getTransactionsRef(String companyId, String ledgerId) {
    return getAccountLedgerRef(companyId, ledgerId).collection(transactions);
  }

  @override
  CollectionReference getCategoryCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection(categoriesCollection);
  }

  @override
  CollectionReference getSubcategoryCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection(subcategoriesCollection);
  }

  @override
  CollectionReference getStoresCollectionRef(String companyId) => _firestore
      .collection(rootPath)
      .doc(companyDirectory)
      .collection(tenantCompanies)
      .doc(companyId)
      .collection('stores');

  @override
  CollectionReference getStockCollectionRef(String companyId, String storeId) =>
      getStoresCollectionRef(companyId).doc(storeId).collection('stock');

  @override
  CollectionReference getTransactionsCollectionRef(
      String companyId, String storeId) =>
      getStoresCollectionRef(companyId).doc(storeId).collection('transactions');

  @override
  CollectionReference getOrdersCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('orders');
  }

  @override
  CollectionReference getCartsCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection(cartsCollection);
  }

  @override
  DocumentReference getUserCartRef(String companyId, String userId) {
    return getCartsCollectionRef(companyId).doc(userId);
  }

  static const String wishlistCollection = 'wishlists';

  @override
  CollectionReference getWishlistCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection(wishlistCollection);
  }

  @override
  DocumentReference getUserWishlistRef(String companyId, String userId) {
    return getWishlistCollectionRef(companyId).doc(userId);
  }

  @override
  CollectionReference getTaxiBookingsCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('taxiBookings');
  }

  @override
  CollectionReference getTaxiTypesCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('settings')
        .doc('taxiBookingSettings')
        .collection('taxiTypes');
  }

  @override
  CollectionReference getTripTypesCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('settings')
        .doc('taxiBookingSettings')
        .collection('tripTypes');
  }

  @override
  CollectionReference getServiceTypesCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('settings')
        .doc('taxiBookingSettings')
        .collection('serviceTypes');
  }

  @override
  CollectionReference getTripStatusesCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('settings')
        .doc('taxiBookingSettings')
        .collection('tripStatuses');
  }

  @override
  DocumentReference getTaxiBookingSettingsRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('settings')
        .doc('taxiBookingSettings');
  }

  @override
  CollectionReference getVisitorCountersCollectionRef(String companyId) {
    return _firestore
        .collection(rootPath)
        .doc(companyDirectory)
        .collection(tenantCompanies)
        .doc(companyId)
        .collection('analytics')
        .doc('visitorCounters')
        .collection('daily');
  }
}