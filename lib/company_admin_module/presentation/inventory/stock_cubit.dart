import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/employee_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info_dto.dart';

abstract class StockState {}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<StockModel> stockItems;
  final List<StoreDto> stores;

  StockLoaded(this.stockItems, this.stores);
}

class StockError extends StockState {
  final String error;

  StockError(this.error);
}

class StockCubit extends Cubit<StockState> {
  final StockService stockService;
  final EmployeeServices employeeServices;
  final TransactionService transactionService;
  final AccountRepository accountRepository;

  StockCubit({
    required this.stockService,
    required this.employeeServices,
    required this.transactionService,
    required this.accountRepository,
  }) : super(StockInitial());

  Future<Map<String, String>> _getCurrentUserInfo() async {
    final userInfo = await accountRepository.getUserInfo();
    return {
      'userName': userInfo?.userName ?? 'Unknown User',
      'userId': userInfo?.userId ?? 'unknown',
    };
  }

  Future<void> fetchStock(String storeId) async {
    emit(StockLoading());
    try {
      final stockItems = await stockService.getStock(storeId);
      final stores = await stockService.getStores();
      emit(StockLoaded(stockItems, stores));
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> addStock(StockModel stock) async {
    emit(StockLoading());
    try {
      // Check if stock already exists for this product and store
      final existingStocks = await stockService.getStock(stock.storeId);
      final existingStock = existingStocks.firstWhere(
            (item) => item.productId == stock.productId,
        orElse: () => StockModel(
          id: '${stock.productId}_${stock.storeId}',
          productId: stock.productId,
          storeId: stock.storeId,
          quantity: 0,
          lastUpdated: DateTime.now(),
        ),
      );

      // If stock exists, update the quantity; otherwise, add new stock
      final updatedStock = StockModel(
        id: existingStock.id,
        productId: existingStock.productId,
        storeId: existingStock.storeId,
        quantity: existingStock.quantity + stock.quantity,
        lastUpdated: DateTime.now(),
      );

      if (existingStock.quantity == 0) {
        await stockService.addStock(updatedStock);
      } else {
        await stockService.updateStock(updatedStock);
      }

      // Record the stock addition as a transaction
      final userInfo = await _getCurrentUserInfo();
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'add',
        productId: stock.productId,
        quantity: stock.quantity,
        fromStoreId: stock.storeId,
        toStoreId: null,
        customerId: null,
        timestamp: DateTime.now(),
        userName: userInfo['userName']!,
        userId: userInfo['userId']!,
      );
      await transactionService.addTransaction(transaction);

      await fetchStock(stock.storeId);
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> updateStock(StockModel stock) async {
    emit(StockLoading());
    try {
      // Fetch all stock items for the store and find the existing stock by ID
      final stockItems = await stockService.getStock(stock.storeId);
      final existingStock = stockItems.firstWhere(
            (item) => item.id == stock.id,
        orElse: () => StockModel(
          id: stock.id,
          productId: stock.productId,
          storeId: stock.storeId,
          quantity: 0,
          lastUpdated: DateTime.now(),
        ),
      );
      final quantityAdded = stock.quantity - existingStock.quantity;

      await stockService.updateStock(stock);

      // Record the stock update as a transaction if quantity increased
      if (quantityAdded > 0) {
        final userInfo = await _getCurrentUserInfo();
        final transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'add',
          productId: stock.productId,
          quantity: quantityAdded,
          fromStoreId: stock.storeId,
          toStoreId: null,
          customerId: null,
          timestamp: DateTime.now(),
          userName: userInfo['userName']!,
          userId: userInfo['userId']!,
        );
        await transactionService.addTransaction(transaction);
      }

      await fetchStock(stock.storeId);
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> addStore(StoreDto store) async {
    emit(StockLoading());
    try {
      await stockService.addStore(store);
      await fetchStock('');
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> transferStock(StockModel stock, String targetStoreId, int quantity) async {
    emit(StockLoading());
    try {
      // Reduce stock in the source store
      final updatedSourceStock = StockModel(
        id: stock.id,
        productId: stock.productId,
        storeId: stock.storeId,
        quantity: stock.quantity - quantity,
        lastUpdated: DateTime.now(),
      );
      await stockService.updateStock(updatedSourceStock);

      // Add stock to the target store (or update if it already exists)
      final existingStock = await stockService.getStock(targetStoreId);
      final existingTargetStock = existingStock.firstWhere(
            (item) => item.productId == stock.productId,
        orElse: () => StockModel(
          id: '${stock.productId}_$targetStoreId',
          productId: stock.productId,
          storeId: targetStoreId,
          quantity: 0,
          lastUpdated: DateTime.now(),
        ),
      );

      final updatedTargetStock = StockModel(
        id: existingTargetStock.id,
        productId: existingTargetStock.productId,
        storeId: targetStoreId,
        quantity: existingTargetStock.quantity + quantity,
        lastUpdated: DateTime.now(),
      );

      if (existingTargetStock.quantity == 0) {
        await stockService.addStock(updatedTargetStock);
      } else {
        await stockService.updateStock(updatedTargetStock);
      }

      // Record the transfer as two transactions: 'out' and 'received'
      final userInfo = await _getCurrentUserInfo();
      final timestamp = DateTime.now();

      // Transaction 1: Outgoing from source store
      final outTransaction = TransactionModel(
        id: '${timestamp.millisecondsSinceEpoch}_out',
        type: 'out',
        productId: stock.productId,
        quantity: quantity,
        fromStoreId: stock.storeId,
        toStoreId: targetStoreId,
        customerId: null,
        timestamp: timestamp,
        userName: userInfo['userName']!,
        userId: userInfo['userId']!,
      );
      await transactionService.addTransaction(outTransaction);

      // Transaction 2: Received in target store
      final receivedTransaction = TransactionModel(
        id: '${timestamp.millisecondsSinceEpoch}_received',
        type: 'received',
        productId: stock.productId,
        quantity: quantity,
        fromStoreId: stock.storeId,
        toStoreId: targetStoreId,
        customerId: null,
        timestamp: timestamp,
        userName: userInfo['userName']!,
        userId: userInfo['userId']!,
      );
      await transactionService.addTransaction(receivedTransaction);

      await fetchStock(stock.storeId);
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }
}