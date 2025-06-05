import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

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
  final UserServices employeeServices;
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

  Future<void> addStock(StockModel stock, {Product? product}) async {
    emit(StockLoading());
    try {
      // Check if stock exists
      final existingStocks = await stockService.getStock(stock.storeId);
      final existingStock = existingStocks.firstWhere(
            (item) => item.productId == stock.productId,
        orElse: () => StockModel(
          id: '${stock.productId}_${stock.storeId}',
          productId: stock.productId,
          storeId: stock.storeId,
          quantity: 0,
          lastUpdated: DateTime.now(),
          name: product?.name,
          price: product?.price,
          stock: null, // Ignore Product.stock
          category: product?.category,
          categoryId: product?.categoryId,
          subcategoryId: product?.subcategoryId,
          subcategoryName: product?.subcategoryName,
          tax: product?.tax,
        ),
      );

      // Update or add stock
      final updatedStock = StockModel(
        id: existingStock.id,
        productId: existingStock.productId,
        storeId: existingStock.storeId,
        quantity: existingStock.quantity + stock.quantity, // Use StockModel.quantity
        lastUpdated: DateTime.now(),
        name: product?.name ?? existingStock.name,
        price: product?.price ?? existingStock.price,
        stock: null, // Ignore Product.stock
        category: product?.category ?? existingStock.category,
        categoryId: product?.categoryId ?? existingStock.categoryId,
        subcategoryId: product?.subcategoryId ?? existingStock.subcategoryId,
        subcategoryName: product?.subcategoryName ?? existingStock.subcategoryName,
        tax: product?.tax ?? existingStock.tax,
      );

      if (existingStock.quantity == 0) {
        await stockService.addStock(updatedStock);
      } else {
        await stockService.updateStock(updatedStock);
      }

      // Record transaction
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

  Future<void> updateStock(StockModel stock, {Product? product}) async {
    emit(StockLoading());
    try {
      // Find existing stock
      final stockItems = await stockService.getStock(stock.storeId);
      final existingStock = stockItems.firstWhere(
            (item) => item.id == stock.id,
        orElse: () => StockModel(
          id: stock.id,
          productId: stock.productId,
          storeId: stock.storeId,
          quantity: 0,
          lastUpdated: DateTime.now(),
          name: product?.name,
          price: product?.price,
          stock: null,
          category: product?.category,
          categoryId: product?.categoryId,
          subcategoryId: product?.subcategoryId,
          subcategoryName: product?.subcategoryName,
          tax: product?.tax,
        ),
      );
      final quantityAdded = stock.quantity - existingStock.quantity;

      // Update stock
      final updatedStock = StockModel(
        id: stock.id,
        productId: stock.productId,
        storeId: stock.storeId,
        quantity: stock.quantity,
        lastUpdated: DateTime.now(),
        name: product?.name ?? stock.name ?? existingStock.name,
        price: product?.price ?? stock.price ?? existingStock.price,
        stock: null,
        category: product?.category ?? stock.category ?? existingStock.category,
        categoryId: product?.categoryId ?? stock.categoryId ?? existingStock.categoryId,
        subcategoryId: product?.subcategoryId ?? stock.subcategoryId ?? existingStock.subcategoryId,
        subcategoryName: product?.subcategoryName ?? stock.subcategoryName ?? existingStock.subcategoryName,
        tax: product?.tax ?? stock.tax ?? existingStock.tax,
      );
      await stockService.updateStock(updatedStock);

      // Record transaction if quantity increased
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

  Future<void> transferStock(StockModel stock, String targetStoreId, int quantity, {Product? product}) async {
    emit(StockLoading());
    try {
      // Update source stock
      final updatedSourceStock = StockModel(
        id: stock.id,
        productId: stock.productId,
        storeId: stock.storeId,
        quantity: stock.quantity - quantity,
        lastUpdated: DateTime.now(),
        name: product?.name ?? stock.name,
        price: product?.price ?? stock.price,
        stock: null,
        category: product?.category ?? stock.category,
        categoryId: product?.categoryId ?? stock.categoryId,
        subcategoryId: product?.subcategoryId ?? stock.subcategoryId,
        subcategoryName: product?.subcategoryName ?? stock.subcategoryName,
        tax: product?.tax ?? stock.tax,
      );
      await stockService.updateStock(updatedSourceStock);

      // Update target stock
      final existingStock = await stockService.getStock(targetStoreId);
      final existingTargetStock = existingStock.firstWhere(
            (item) => item.productId == stock.productId,
        orElse: () => StockModel(
          id: '${stock.productId}_$targetStoreId',
          productId: stock.productId,
          storeId: targetStoreId,
          quantity: 0,
          lastUpdated: DateTime.now(),
          name: product?.name,
          price: product?.price,
          stock: null,
          category: product?.category,
          categoryId: product?.categoryId,
          subcategoryId: product?.subcategoryId,
          subcategoryName: product?.subcategoryName,
          tax: product?.tax,
        ),
      );

      final updatedTargetStock = StockModel(
        id: existingTargetStock.id,
        productId: existingTargetStock.productId,
        storeId: targetStoreId,
        quantity: existingTargetStock.quantity + quantity,
        lastUpdated: DateTime.now(),
        name: product?.name ?? existingTargetStock.name,
        price: product?.price ?? existingTargetStock.price,
        stock: null,
        category: product?.category ?? existingTargetStock.category,
        categoryId: product?.categoryId ?? existingTargetStock.categoryId,
        subcategoryId: product?.subcategoryId ?? existingTargetStock.subcategoryId,
        subcategoryName: product?.subcategoryName ?? existingTargetStock.subcategoryName,
        tax: product?.tax ?? existingTargetStock.tax,
      );

      if (existingTargetStock.quantity == 0) {
        await stockService.addStock(updatedTargetStock);
      } else {
        await stockService.updateStock(updatedTargetStock);
      }

      // Record transactions
      final userInfo = await _getCurrentUserInfo();
      final timestamp = DateTime.now();

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