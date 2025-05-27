import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class StoreDto {
  final String storeId;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  StoreDto({
    required this.storeId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  factory StoreDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreDto(
      storeId: doc.id,
      name: data['name'] as String,
      createdBy: data['createdBy'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  StoreDto copyWith({
    String? storeId,
    String? name,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StoreDto(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
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
}

class StockRepositoryImpl implements StockRepository {
  final IFirestorePathProvider firestorePathProvider;
  final AccountRepository accountRepository;

  StockRepositoryImpl({
    required this.firestorePathProvider,
    required this.accountRepository,
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
      final defaultStore = StoreDto(
        storeId: 'default',
        name: 'Default Store',
        createdBy: adminUserId,
        createdAt: DateTime.now(),
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
}
