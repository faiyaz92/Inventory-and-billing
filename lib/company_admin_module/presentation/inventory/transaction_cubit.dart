import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final bool hasMore;
  TransactionLoaded(this.transactions, {this.hasMore = false});
}

class TransactionError extends TransactionState {
  final String error;
  TransactionError(this.error);
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionService transactionService;
  List<TransactionModel> _allTransactions = [];

  TransactionCubit({required this.transactionService}) : super(TransactionInitial());

  Future<void> fetchTransactions({
    required String storeId,
    String? type,
    String? fromStoreId,
    String? toStoreId,
    String? userId,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
    required int page,
    required int pageSize,
  }) async {
    if (page == 1) {
      emit(TransactionLoading());
    }
    try {
      final transactions = await transactionService.getTransactions(
        storeId,
        type: type,
        fromStoreId: fromStoreId,
        toStoreId: toStoreId,
        userId: userId,
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      // Sort transactions by timestamp (latest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (page == 1) {
        _allTransactions = transactions;
      } else {
        _allTransactions.addAll(transactions);
      }

      emit(TransactionLoaded(
        _allTransactions,
        hasMore: transactions.length == pageSize,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> createBilling(TransactionModel transaction) async {
    emit(TransactionLoading());
    try {
      await transactionService.createBilling(transaction);
      await fetchTransactions(
        storeId: transaction.fromStoreId,
        page: 1,
        pageSize: 20,
      );
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}