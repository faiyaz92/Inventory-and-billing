import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

import '../data/inventory/transaction_dto.dart' show TransactionDto;

/// Repository interface for managing transactions in Firestore.
abstract class TransactionRepository {
  /// Fetches all transactions for a specific store.
  Future<List<TransactionDto>> getTransactions(
    String companyId,
    String storeId, {
    String? userId,
    String? fromStoreId,
    String? toStoreId,
    DateTime? startDate,
    DateTime? endDate,
    required int page,
    required int pageSize,
  });

  /// Adds a new transaction to Firestore.
  Future<void> addTransaction(String companyId, TransactionDto transaction);

  /// Updates an existing transaction in Firestore.
  Future<void> updateTransaction(String companyId, TransactionDto transaction);

  /// Deletes a transaction from Firestore.
  Future<void> deleteTransaction(
      String companyId, String storeId, String transactionId);
}

/// Implementation of TransactionRepository using Firestore.
class TransactionRepositoryImpl implements TransactionRepository {
  final IFirestorePathProvider firestorePathProvider;

  TransactionRepositoryImpl({
    required this.firestorePathProvider,
  });
  Future<List<TransactionDto>> getTransactions(
      String companyId,
      String storeId, {
        String? userId,
        String? fromStoreId,
        String? toStoreId,
        DateTime? startDate,
        DateTime? endDate,
        required int page,
        required int pageSize,
      }) async {
    Query<Map<String, dynamic>> query =
    firestorePathProvider.getTransactionsCollectionRef(companyId, storeId)
    as Query<Map<String, dynamic>>;

    // Apply filters
    // if (userId != null) {
    //   query = query.where('userId', isEqualTo: userId);
    // }
    // if (fromStoreId != null) {
    //   query = query.where('fromStoreId', isEqualTo: fromStoreId);
    // }
    // if (toStoreId != null) {
    //   query = query.where('toStoreId', isEqualTo: toStoreId);
    // }
    // if (startDate != null) {
    //   query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    // }
    // if (endDate != null) {
    //   query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    // }

    // Apply sorting and pagination
    query = query.orderBy('timestamp', descending: true).limit(pageSize);

    // Handle pagination
    if (page > 1) {
      final lastSnapshot = await firestorePathProvider
          .getTransactionsCollectionRef(companyId, storeId)
          .orderBy('timestamp', descending: true)
          .limit(pageSize * (page - 1))
          .get();

      if (lastSnapshot.docs.isNotEmpty) {
        final lastDoc = lastSnapshot.docs.last;
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => TransactionDto.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addTransaction(
      String companyId, TransactionDto transaction) async {
    try {
      final ref = firestorePathProvider.getTransactionsCollectionRef(
          companyId,
          transaction.type == 'received'
              ? transaction.toStoreId ?? ''
              : transaction.fromStoreId);
      await ref.doc(transaction.id).set(transaction.toFirestore());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(
      String companyId, TransactionDto transaction) async {
    try {
      final ref = firestorePathProvider.getTransactionsCollectionRef(
          companyId, transaction.fromStoreId);
      await ref.doc(transaction.id).update(transaction.toFirestore());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(
      String companyId, String storeId, String transactionId) async {
    try {
      final ref = firestorePathProvider.getTransactionsCollectionRef(
          companyId, storeId);
      await ref.doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
