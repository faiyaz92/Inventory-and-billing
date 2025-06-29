import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';

class OverallStockState {
  final List<ProductStock> productStocks;
  final String? searchQuery;
  final bool isLoading;
  final String? error;

  OverallStockState({
    required this.productStocks,
    this.searchQuery,
    this.isLoading = false,
    this.error,
  });

  OverallStockState copyWith({
    List<ProductStock>? productStocks,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return OverallStockState(
      productStocks: productStocks ?? this.productStocks,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProductStock {
  final String productId;
  final String productName;
  int totalStock; // Non-final as in original
  final Map<String, int> storeStocks;
  final Map<String, String> storeNames;

  ProductStock({
    required this.productId,
    required this.productName,
    required this.totalStock,
    required this.storeStocks,
    required this.storeNames,
  });
}

class OverallStockCubit extends Cubit<OverallStockState> {
  final StockService stockService;

  OverallStockCubit({
    required this.stockService,
  }) : super(OverallStockState(productStocks: []));

  Future<void> loadOverallStock() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Fetch all stores
      final stores = await stockService.getStores();
      final storeNames = {for (var store in stores) store.storeId: store.name};
      final allStockItems = <StockModel>[];
      for (final store in stores) {
        final stockItems = await stockService.getStock(store.storeId);
        allStockItems.addAll(stockItems);
      }

      // Aggregate stock by product
      final productStocks = _aggregateStockByProduct(allStockItems, storeNames);
      emit(state.copyWith(productStocks: productStocks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void searchProducts(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  List<ProductStock> _aggregateStockByProduct(List<StockModel> stockItems, Map<String, String> storeNames) {
    final Map<String, ProductStock> productMap = {};
    for (final stock in stockItems) {
      if (!productMap.containsKey(stock.productId)) {
        productMap[stock.productId] = ProductStock(
          productId: stock.productId,
          productName: stock.name ?? 'Unknown', // Use name from StockModel
          totalStock: 0,
          storeStocks: {},
          storeNames: storeNames,
        );
      }
      final productStock = productMap[stock.productId]!;
      productStock.totalStock += stock.quantity;
      productStock.storeStocks[stock.storeId] = stock.quantity;
    }
    return productMap.values.toList();
  }
}