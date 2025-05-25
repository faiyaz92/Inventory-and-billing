import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/employee_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/data/user_product_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/services/i_user_product_service.dart';

// State for SalesmanOrderCubit
abstract class SalesmanOrderState {}

class SalesmanOrderInitial extends SalesmanOrderState {}

class SalesmanOrderLoading extends SalesmanOrderState {
  final String dialogMessage;

  SalesmanOrderLoading({this.dialogMessage = 'Loading...'});
}

class SalesmanOrderLoaded extends SalesmanOrderState {
  final List<UserInfo> customers;
  final List<UserProduct> products;
  final List<UserProduct> filteredProducts; // Added for search
  final Map<String, int> productQuantities;
  final UserInfo? selectedCustomer;
  final String? customCustomerName;
  final String searchQuery;
  final bool? isLoading; // Added for search

  SalesmanOrderLoaded({
    required this.customers,
    required this.products,
    required this.filteredProducts,
    required this.productQuantities,
    this.selectedCustomer,
    this.customCustomerName,
    this.searchQuery = '',
    this.isLoading = false,
  });
}

class SalesmanOrderError extends SalesmanOrderState {
  final String message;

  SalesmanOrderError(this.message);
}

class SalesmanOrderPlaced extends SalesmanOrderState {}

// Cubit for handling salesman order logic
class SalesmanOrderCubit extends Cubit<SalesmanOrderState> {
  final EmployeeServices employeeServices;
  final IUserProductService productService;
  final AccountRepository accountRepository;
  final CartCubit cartCubit;
  final OrderCubit orderCubit;

  SalesmanOrderCubit({
    required this.employeeServices,
    required this.productService,
    required this.accountRepository,
    required this.cartCubit,
    required this.orderCubit,
  }) : super(SalesmanOrderInitial()) {
    _initialize();
  }

  List<UserInfo> _customers = [];
  List<UserProduct> _products = [];
  List<UserProduct> _filteredProducts = []; // Added for search
  Map<String, int> _productQuantities = {};
  UserInfo? _selectedCustomer;
  String? _customCustomerName;
  String _searchQuery = ''; // Added for search

  Future<void> _initialize() async {
    emit(SalesmanOrderLoading());
    try {
      // Fetch customers
      _customers = await employeeServices.getUsersFromTenantCompany();

      // Fetch products
      _products = await productService.getProducts();
      _filteredProducts = _products; // Initialize filtered products

      // Initialize product quantities
      _productQuantities = {for (var product in _products) product.id: 0};

      emit(SalesmanOrderLoaded(
        customers: _customers,
        products: _products,
        filteredProducts: _filteredProducts,
        productQuantities: _productQuantities,
        selectedCustomer: _selectedCustomer,
        customCustomerName: _customCustomerName,
        searchQuery: _searchQuery,
        isLoading: true,
      ));
    } catch (e) {
      emit(SalesmanOrderError('Failed to load data: $e'));
    }
  }

  void selectCustomer(UserInfo? customer) {
    _selectedCustomer = customer;
    _customCustomerName =
        null; // Reset custom customer name if a customer is selected
    emit(SalesmanOrderLoaded(
      customers: _customers,
      products: _products,
      filteredProducts: _filteredProducts,
      productQuantities: _productQuantities,
      selectedCustomer: _selectedCustomer,
      customCustomerName: _customCustomerName,
      searchQuery: _searchQuery,
    ));
  }

  void setCustomCustomerName(String name) {
    _customCustomerName = name;
    _selectedCustomer = null; // Reset selected customer if custom name is used
    emit(SalesmanOrderLoaded(
      customers: _customers,
      products: _products,
      filteredProducts: _filteredProducts,
      productQuantities: _productQuantities,
      selectedCustomer: _selectedCustomer,
      customCustomerName: _customCustomerName,
      searchQuery: _searchQuery,
    ));
  }

  void updateProductQuantity(String productId, bool increment) {
    if (increment) {
      _productQuantities[productId] = _productQuantities[productId]! + 1;
    } else {
      if (_productQuantities[productId]! > 0) {
        _productQuantities[productId] = _productQuantities[productId]! - 1;
      }
    }
    emit(SalesmanOrderLoaded(
      customers: _customers,
      products: _products,
      filteredProducts: _filteredProducts,
      productQuantities: _productQuantities,
      selectedCustomer: _selectedCustomer,
      customCustomerName: _customCustomerName,
      searchQuery: _searchQuery,
    ));
  }

  // Search functionality
  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    emit(SalesmanOrderLoaded(
      customers: _customers,
      products: _products,
      filteredProducts: _filteredProducts,
      productQuantities: _productQuantities,
      selectedCustomer: _selectedCustomer,
      customCustomerName: _customCustomerName,
      searchQuery: _searchQuery,
    ));
  }

  // Price calculation methods (similar to CartCubit)
  double calculateProductSubtotal(String productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    final quantity = _productQuantities[productId] ?? 0;
    return product.price * quantity;
  }

  double calculateProductTax(String productId) {
    final product = _products.firstWhere((p) => p.id == productId);
    final quantity = _productQuantities[productId] ?? 0;
    return product.taxAmount * quantity;
  }

  double calculateProductTotal(String productId) {
    return calculateProductSubtotal(productId) + calculateProductTax(productId);
  }

  double calculateOverallSubtotal() {
    double subtotal = 0.0;
    for (var product in _products) {
      if (_productQuantities[product.id]! > 0) {
        subtotal += calculateProductSubtotal(product.id);
      }
    }
    return subtotal;
  }

  double calculateOverallTax() {
    double totalTax = 0.0;
    for (var product in _products) {
      if (_productQuantities[product.id]! > 0) {
        totalTax += calculateProductTax(product.id);
      }
    }
    return totalTax;
  }

  double calculateOverallTotal() {
    return calculateOverallSubtotal() + calculateOverallTax();
  }

  Future<void> placeOrder() async {
    if (_selectedCustomer == null &&
        (_customCustomerName == null || _customCustomerName!.isEmpty)) {
      emit(SalesmanOrderError(
          'Please select a customer or enter a new customer name'));
      return;
    }

    emit(SalesmanOrderLoading(
      dialogMessage: 'Wait...'
    ));
    try {
      // Add selected products to cart
      for (var product in _products) {
        final quantity = _productQuantities[product.id]!;
        if (quantity > 0) {
          await cartCubit.addToCart(product, quantity);
        }
      }

      // Calculate total and create order
      final totalAmount = await cartCubit.totalAmount;
      final items = cartCubit.state.items;
      final salesmanId = (await accountRepository.getUserInfo())?.userId;
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _selectedCustomer?.userId ??
            'CUSTOM_${DateTime.now().millisecondsSinceEpoch}',
        userName: _selectedCustomer?.userName ?? _customCustomerName!,
        items: items,
        totalAmount: totalAmount,
        status: 'pending',
        orderDate: DateTime.now(),
        orderTakenBy: salesmanId,
      );

      // Place the order
      await orderCubit.placeOrderBySalesMan(
        order,
      );

      // Clear cart after successful order placement
      await cartCubit.clearCart();
      emit(SalesmanOrderPlaced());
    } catch (e) {
      emit(SalesmanOrderError('Failed to place order: $e'));
    }
  }
}
