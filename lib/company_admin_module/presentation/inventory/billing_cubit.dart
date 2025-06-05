// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
// import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
// import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';
// import 'package:requirment_gathering_app/company_admin_module/service/product_service.dart';
// import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
// import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';
//
// class BillingState {
//   final String? selectedStoreId;
//   final String? selectedCustomerId;
//   final List<BillItem> items;
//   final double taxPercentage;
//   final bool isLoading;
//   final String? error;
//   final bool isBillGenerated;
//
//   BillingState({
//     this.selectedStoreId,
//     this.selectedCustomerId,
//     this.items = const [],
//     this.taxPercentage = 5.0, // Default tax percentage
//     this.isLoading = false,
//     this.error,
//     this.isBillGenerated = false,
//   });
//
//   BillingState copyWith({
//     String? selectedStoreId,
//     String? selectedCustomerId,
//     List<BillItem>? items,
//     double? taxPercentage,
//     bool? isLoading,
//     String? error,
//     bool? isBillGenerated,
//   }) {
//     return BillingState(
//       selectedStoreId: selectedStoreId ?? this.selectedStoreId,
//       selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
//       items: items ?? this.items,
//       taxPercentage: taxPercentage ?? this.taxPercentage,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       isBillGenerated: isBillGenerated ?? this.isBillGenerated,
//     );
//   }
// }
//
// class BillItem {
//   final StockModel stock;
//   final Product product;
//   int quantity;
//
//   BillItem({
//     required this.stock,
//     required this.product,
//     this.quantity = 1,
//   });
//
//   double get totalPrice => quantity * product.price;
// }
//
// class BillingCubit extends Cubit<BillingState> {
//   final StockService stockService;
//   final ProductService productService;
//   final TransactionService transactionService;
//
//   BillingCubit({
//     required this.stockService,
//     required this.productService,
//     required this.transactionService,
//   }) : super(BillingState());
//
//   void selectStore(String storeId) {
//     emit(state.copyWith(selectedStoreId: storeId));
//   }
//
//   void selectCustomer(String customerId) {
//     emit(state.copyWith(selectedCustomerId: customerId));
//   }
//
//   Future<void> addItem(StockModel stock) async {
//     try {
//       final product = await productService.fetchProductById(stock.productId);
//       if (product == null) throw Exception('Product not found');
//       final items = List<BillItem>.from(state.items);
//       final existingItemIndex = items.indexWhere((item) => item.stock.productId == stock.productId);
//       if (existingItemIndex != -1) {
//         // Item already exists, increase quantity if stock allows
//         if (items[existingItemIndex].quantity < stock.quantity) {
//           items[existingItemIndex].quantity += 1;
//         } else {
//           throw Exception('Cannot add more: Insufficient stock');
//         }
//       } else {
//         items.add(BillItem(stock: stock, product: product));
//       }
//       emit(state.copyWith(items: items));
//     } catch (e) {
//       emit(state.copyWith(error: e.toString()));
//     }
//   }
//
//   void updateQuantity(int index, int newQuantity) {
//     final items = List<BillItem>.from(state.items);
//     if (index >= 0 && index < items.length) {
//       final item = items[index];
//       if (newQuantity <= 0) {
//         items.removeAt(index);
//       } else if (newQuantity <= item.stock.quantity) {
//         items[index].quantity = newQuantity;
//       } else {
//         emit(state.copyWith(error: 'Cannot exceed available stock: ${item.stock.quantity}'));
//         return;
//       }
//       emit(state.copyWith(items: items));
//     }
//   }
//
//   void setTaxPercentage(double taxPercentage) {
//     emit(state.copyWith(taxPercentage: taxPercentage));
//   }
//
//   double get subtotal => state.items.fold(0.0, (sum, item) => sum + item.totalPrice);
//
//   double get taxAmount => subtotal * (state.taxPercentage / 100);
//
//   double get grandTotal => subtotal + taxAmount;
//
//   Future<void> createBill() async {
//     if (state.selectedStoreId == null || state.selectedCustomerId == null || state.items.isEmpty) {
//       emit(state.copyWith(error: 'Please select a store, customer, and add at least one product'));
//       return;
//     }
//
//     emit(state.copyWith(isLoading: true));
//     try {
//       // Create a single billing transaction for all items
//       final transaction = TransactionModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         type: 'billing',
//         productId: state.items.map((item) => item.stock.productId).join(','), // Store all product IDs
//         quantity: state.items.fold(0, (sum, item) => sum + item.quantity),
//         fromStoreId: state.selectedStoreId!,
//         customerId: state.selectedCustomerId!,
//         timestamp: DateTime.now(),
//         userName: '',
//         userId: '',
//         totalPrice: grandTotal,
//       );
//       await transactionService.createBilling(transaction);
//
//       // Reduce stock for each item
//       for (final item in state.items) {
//         final updatedStock = StockModel(
//           id: item.stock.id,
//           productId: item.stock.productId,
//           storeId: item.stock.storeId,
//           quantity: item.stock.quantity - item.quantity,
//           lastUpdated: DateTime.now(),
//         );
//         await stockService.updateStock(updatedStock);
//       }
//
//       emit(state.copyWith(isLoading: false, isBillGenerated: true));
//     } catch (e) {
//       emit(state.copyWith(isLoading: false, error: e.toString()));
//     }
//   }
//
//   void reset() {
//     emit(BillingState());
//   }
// }