import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

enum StoreType { store, warehouse, salesman }

class StoreDto {
  final String storeId;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final String? accountLedgerId;
  final StoreType storeType;

  StoreDto({
    required this.storeId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.accountLedgerId,
    this.storeType = StoreType.store,
  });

  factory StoreDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreDto(
      storeId: doc.id,
      name: data['name'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      accountLedgerId: data['accountLedgerId'] as String?,
      storeType: data['storeType'] != null
          ? StoreType.values.firstWhere(
            (e) => e.toString().split('.').last == data['storeType'],
        orElse: () => StoreType.store,
      )
          : StoreType.store,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'accountLedgerId': accountLedgerId,
      'storeType': storeType.toString().split('.').last,
    };
  }

  StoreDto copyWith({
    String? storeId,
    String? name,
    String? createdBy,
    DateTime? createdAt,
    String? accountLedgerId,
    StoreType? storeType,
  }) {
    return StoreDto(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      accountLedgerId: accountLedgerId ?? this.accountLedgerId,
      storeType: storeType ?? this.storeType,
    );
  }
}

abstract class StockRepository {
  Future<List<StockDto>> getStock(String companyId, String? storeId);

  Future<void> addStock(String companyId, StockDto stock);

  Future<void> updateStock(String companyId, StockDto stock);

  Future<StockDto?> getStockByProduct(
      String companyId, String storeId, String productId);

  Future<List<StoreDto>> getStores(String companyId);

  Future<String> getDefaultStoreId(String companyId);

  Future<void> addStore(String companyId, StoreDto store);

  Future<void> updateStore(String companyId, StoreDto store); // New method

  Future<StoreDto?> getStoreByName(String companyId, String storeName); // New method
}

class StockRepositoryImpl implements StockRepository {
  final IFirestorePathProvider firestorePathProvider;
  final AccountRepository accountRepository;
  final IAccountLedgerService accountLedgerService;

  StockRepositoryImpl({
    required this.firestorePathProvider,
    required this.accountRepository,
    required this.accountLedgerService,
  });

  @override
  Future<List<StockDto>> getStock(String companyId, String? storeId) async {
    try {
      final effectiveStoreId = (storeId == null || storeId.isEmpty)
          ? await getDefaultStoreId(companyId)
          : storeId;
      final ref = firestorePathProvider.getStockCollectionRef(
          companyId, effectiveStoreId);
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) => StockDto.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch stock: $e');
    }
  }

  @override
  Future<void> addStock(String companyId, StockDto stock) async {
    try {
      final effectiveStoreId = (stock.storeId == null || stock.storeId.isEmpty)
          ? await getDefaultStoreId(companyId)
          : stock.storeId;
      final updatedStock = StockDto(
        id: stock.id.isEmpty
            ? '${stock.productId}_$effectiveStoreId'
            : stock.id,
        productId: stock.productId,
        storeId: effectiveStoreId,
        quantity: stock.quantity,
        lastUpdated: stock.lastUpdated,
        price: stock.price,
        tax: stock.tax,
        name: stock.name,
      );
      final ref = firestorePathProvider.getStockCollectionRef(
          companyId, effectiveStoreId);
      await ref.doc(updatedStock.productId).set(updatedStock.toFirestore());
    } catch (e) {
      throw Exception('Failed to add stock: $e');
    }
  }

  @override
  Future<void> updateStock(String companyId, StockDto stock) async {
    try {
      final effectiveStoreId = (stock.storeId == null || stock.storeId.isEmpty)
          ? await getDefaultStoreId(companyId)
          : stock.storeId;
      final ref = firestorePathProvider.getStockCollectionRef(
          companyId, effectiveStoreId);
      await ref.doc(stock.productId).update(stock.toFirestore());
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  @override
  Future<StoreDto?> getStoreByName(String companyId, String storeName) async {
    try {
      final ref = firestorePathProvider.getStoresCollectionRef(companyId);
      final snapshot = await ref.doc(storeName).get();
      if (!snapshot.exists) return null;
      return StoreDto.fromFirestore(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch store by name: $e');
    }
  }

  @override
  Future<StockDto?> getStockByProduct(
      String companyId, String storeId, String productId) async {
    try {
      final effectiveStoreId = (storeId == null || storeId.isEmpty)
          ? await getDefaultStoreId(companyId)
          : storeId;
      final ref = firestorePathProvider.getStockCollectionRef(
          companyId, effectiveStoreId);
      final snapshot = await ref.where('productId', isEqualTo: productId).get();
      if (snapshot.docs.isEmpty) return null;
      return StockDto.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to fetch stock by product: $e');
    }
  }

  @override
  Future<List<StoreDto>> getStores(String companyId) async {
    try {
      final ref = firestorePathProvider.getStoresCollectionRef(companyId);
      final snapshot = await ref.get();
      return snapshot.docs.map((doc) => StoreDto.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch stores: $e');
    }
  }

  @override
  Future<String> getDefaultStoreId(String companyId) async {
    final stores = await getStores(companyId);
    if (stores.isEmpty) {
      final userInfo = await accountRepository.getUserInfo();
      final adminUserId = userInfo?.userId ?? 'system';
      final ledgerId = await accountLedgerService.createLedger(AccountLedger(
        totalOutstanding: 0,
        promiseAmount: null,
        promiseDate: null,
        transactions: [],
        entityType: UserType.Store,
      ));
      final defaultStore = StoreDto(
        storeId: 'default',
        name: 'Default Store',
        createdBy: adminUserId,
        createdAt: DateTime.now(),
        accountLedgerId: ledgerId,
      );
      await firestorePathProvider
          .getStoresCollectionRef(companyId)
          .doc(defaultStore.storeId)
          .set(defaultStore.toFirestore());
      return defaultStore.storeId;
    }
    return stores.last.storeId;
  }

  @override
  Future<void> addStore(String companyId, StoreDto store) async {
    try {
      final ref = firestorePathProvider.getStoresCollectionRef(companyId);
      await ref.doc(store.name).set(store.toFirestore());
    } catch (e) {
      throw Exception('Failed to add store: $e');
    }
  }

  @override
  Future<void> updateStore(String companyId, StoreDto store) async {
    try {
      final ref = firestorePathProvider.getStoresCollectionRef(companyId);
      await ref.doc(store.name).update(store.toFirestore());
    } catch (e) {
      throw Exception('Failed to update store: $e');
    }
  }
}