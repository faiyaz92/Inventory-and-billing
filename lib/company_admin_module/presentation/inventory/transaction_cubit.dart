import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionState {
  final String error;
  TransactionError(this.error);
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionService transactionService;
  TransactionCubit({required this.transactionService}) : super(TransactionInitial());

  Future<void> fetchTransactions(String storeId) async {
    emit(TransactionLoading());
    try {
      final transactions = await transactionService.getTransactions(storeId);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }


  Future<void> createBilling(TransactionModel transaction) async {
    emit(TransactionLoading());
    try {
      await transactionService.createBilling(transaction);
      await fetchTransactions(transaction.fromStoreId);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}