import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';

// Abstract OverallStockState
abstract class OverallStockState extends Equatable {
  final List<ProductStock> productStocks;
  final List<ProductStock> filteredProductStocks;
  final double totalStockValue; // Added to store total stock value
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedSubcategory;
  final List<String> availableCategories;
  final List<String> availableSubcategories;
  final bool isLoading;
  final String? error;

  const OverallStockState({
    required this.productStocks,
    required this.filteredProductStocks,
    required this.totalStockValue,
    this.searchQuery,
    this.selectedCategory,
    this.selectedSubcategory,
    required this.availableCategories,
    required this.availableSubcategories,
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
    productStocks,
    filteredProductStocks,
    totalStockValue,
    searchQuery,
    selectedCategory,
    selectedSubcategory,
    availableCategories,
    availableSubcategories,
    isLoading,
    error,
  ];
}

// Initial state
class OverallStockInitial extends OverallStockState {
  const OverallStockInitial()
      : super(
    productStocks: const [],
    filteredProductStocks: const [],
    totalStockValue: 0.0,
    searchQuery: null,
    selectedCategory: null,
    selectedSubcategory: null,
    availableCategories: const [],
    availableSubcategories: const [],
    isLoading: false,
    error: null,
  );
}

// Loading state
class OverallStockLoading extends OverallStockState {
  const OverallStockLoading({
    required super.productStocks,
    required super.filteredProductStocks,
    required super.totalStockValue,
    super.searchQuery,
    super.selectedCategory,
    super.selectedSubcategory,
    required super.availableCategories,
    required super.availableSubcategories,
    super.error,
  }) : super(isLoading: true);
}

// Success state
class OverallStockSuccess extends OverallStockState {
  const OverallStockSuccess({
    required super.productStocks,
    required super.filteredProductStocks,
    required super.totalStockValue,
    super.searchQuery,
    super.selectedCategory,
    super.selectedSubcategory,
    required super.availableCategories,
    required super.availableSubcategories,
  }) : super(isLoading: false, error: null);
}

// Error state
class OverallStockError extends OverallStockState {
  const OverallStockError({
    required super.productStocks,
    required super.filteredProductStocks,
    required super.totalStockValue,
    super.searchQuery,
    super.selectedCategory,
    super.selectedSubcategory,
    required super.availableCategories,
    required super.availableSubcategories,
    required String super.error,
  }) : super(isLoading: false);
}

class ProductStock {
  final String productId;
  final String productName;
  final String? category;
  final String? subcategory;
  int totalStock;
  final Map<String, int> storeStocks;
  final Map<String, String> storeNames;

  ProductStock({
    required this.productId,
    required this.productName,
    this.category,
    this.subcategory,
    required this.totalStock,
    required this.storeStocks,
    required this.storeNames,
  });
}

class OverallStockCubit extends Cubit<OverallStockState> {
  final StockService stockService;

  OverallStockCubit({
    required this.stockService,
  }) : super(const OverallStockInitial());

  Future<void> loadOverallStock() async {
    emit(OverallStockLoading(
      productStocks: state.productStocks,
      filteredProductStocks: state.filteredProductStocks,
      totalStockValue: state.totalStockValue,
      searchQuery: state.searchQuery,
      selectedCategory: state.selectedCategory,
      selectedSubcategory: state.selectedSubcategory,
      availableCategories: state.availableCategories,
      availableSubcategories: state.availableSubcategories,
    ));
    try {
      // Fetch all stores
      final stores = await stockService.getStores();
      final storeNames = {for (var store in stores) store.storeId: store.name};
      final allStockItems = <StockModel>[];
      for (final store in stores) {
        final stockItems = await stockService.getStock(store.storeId);
        allStockItems.addAll(stockItems);
      }

      // Aggregate stock by product and calculate total stock value
      final productStocks = <ProductStock>[];
      final Map<String, ProductStock> productMap = {};
      double totalStockValue = 0.0;

      for (final stock in allStockItems) {
        if (!productMap.containsKey(stock.productId)) {
          print('Processing stock item: ${stock.productId}, name: ${stock.name}');
          productMap[stock.productId] = ProductStock(
            productId: stock.productId.isNotEmpty ? stock.productId : 'Unknown_${stock.hashCode}',
            productName: stock.name?.isNotEmpty == true ? stock.name! : 'Unknown',
            category: stock.category,
            subcategory: stock.subcategoryName,
            totalStock: 0,
            storeStocks: {},
            storeNames: storeNames,
          );
        }
        final productStock = productMap[stock.productId]!;
        productStock.totalStock += stock.quantity;
        productStock.storeStocks[stock.storeId] = stock.quantity;
        final price = stock.price ?? 0.0;
        totalStockValue += stock.quantity * price;
      }
      productStocks.addAll(productMap.values);

      // Extract unique categories and subcategories
      final categories = productStocks
          .map((p) => p.category)
          .where((c) => c != null)
          .cast<String>()
          .toSet()
          .toList()
        ..sort();
      final subcategories = productStocks
          .map((p) => p.subcategory)
          .where((s) => s != null)
          .cast<String>()
          .toSet()
          .toList()
        ..sort();

      print('Loaded ${productStocks.length} products, '
          '${categories.length} categories, '
          '${subcategories.length} subcategories, '
          'Total Stock Value: IQD $totalStockValue');
      emit(OverallStockSuccess(
        productStocks: productStocks,
        filteredProductStocks: List.from(productStocks),
        totalStockValue: totalStockValue,
        searchQuery: null,
        selectedCategory: null,
        selectedSubcategory: null,
        availableCategories: categories,
        availableSubcategories: subcategories,
      ));
    } catch (e) {
      print('Error loading stock: $e');
      emit(OverallStockError(
        productStocks: state.productStocks,
        filteredProductStocks: state.filteredProductStocks,
        totalStockValue: state.totalStockValue,
        searchQuery: state.searchQuery,
        selectedCategory: state.selectedCategory,
        selectedSubcategory: state.selectedSubcategory,
        availableCategories: state.availableCategories,
        availableSubcategories: state.availableSubcategories,
        error: e.toString(),
      ));
    }
  }

  void filterProducts({
    String? query,
    String? category,
    String? subcategory,
  }) {
    final trimmedQuery = (query ?? state.searchQuery)?.trim().toLowerCase();
    final selectedCategory = category ?? state.selectedCategory;
    final selectedSubcategory = subcategory ?? state.selectedSubcategory;

    print('Filtering with query: $trimmedQuery, '
        'category: $selectedCategory, '
        'subcategory: $selectedSubcategory');

    final filteredProducts = state.productStocks.where((product) {
      final matchesQuery = trimmedQuery == null || trimmedQuery.isEmpty
          ? true
          : product.productName.toLowerCase().contains(trimmedQuery) ||
          product.productId.toLowerCase().contains(trimmedQuery);
      final matchesCategory = selectedCategory == null || selectedCategory.isEmpty
          ? true
          : product.category == selectedCategory;
      final matchesSubcategory =
      selectedSubcategory == null || selectedSubcategory.isEmpty
          ? true
          : product.subcategory == selectedSubcategory;
      return matchesQuery && matchesCategory && matchesSubcategory;
    }).toList();

    print('Filtered ${filteredProducts.length} products');
    emit(OverallStockSuccess(
      productStocks: state.productStocks,
      filteredProductStocks: List.from(filteredProducts),
      totalStockValue: state.totalStockValue,
      searchQuery: trimmedQuery,
      selectedCategory: selectedCategory,
      selectedSubcategory: selectedSubcategory,
      availableCategories: state.availableCategories,
      availableSubcategories: state.availableSubcategories,
    ));
  }
}